#!/usr/bin/env bash
# grnvs-connect.sh – start or wake the GRNVS VM and ssh straight in

set -euo pipefail

# ── CONFIGURE ME ───────────────────────────────────────────────────────────────
CONTROL="svm@grnvs.net"                                 # GRNVS controller account
SSH_OPTS="-o StrictHostKeyChecking=accept-new -o LogLevel=ERROR"
SSH_CONTROL_OPTS="-T"                                   # <-- disable PTY on controller SSH
# ── /CONFIGURE ME ──────────────────────────────────────────────────────────────

###############################################################################
#  🎨  MODERN HEADER / WATERMARK                                               #
###############################################################################
print_header() {
  # Basic colour palette (falls back to white if the terminal only supports 8)
  local bold reset cyan magenta
  bold=$(tput bold)             # bold on            :contentReference[oaicite:0]{index=0}
  reset=$(tput sgr0)            # reset all attrs    :contentReference[oaicite:1]{index=1}
  cyan=$(tput setaf 6 2>/dev/null || echo "")        # bright-cyan
  magenta=$(tput setaf 5 2>/dev/null || echo "")     # bright-magenta

  printf "\n${bold}${cyan}╔═══════════════════════════════════════════════════════╗\n"
  printf "║                   ${magenta}GRNVS VM CONNECTOR${cyan}                  ║\n"
  printf "║           Made with ❤️ by Justin Lanfermann           ║\n"
  printf "╚═══════════════════════════════════════════════════════╝${reset}\n\n"
}
print_header   # ⭐ run header immediately on start-up

# ── SPINNER SETUP ──────────────────────────────────────────────────────────────
# Unicode “braille” spinner frames – compact and smooth on most fonts
# Idea borrowed from common CLI spinners 🄫 (e.g. Figlet/TOIlet banners) :contentReference[oaicite:2]{index=2}
spinner_frames=( '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏' )
spin() {
  local msg="$1" i=0
  tput civis                                  # hide cursor
  while :; do
    printf "\r%s %s" "${spinner_frames[i]}" "$msg"
    i=$(( (i+1) % ${#spinner_frames[@]} ))
    sleep 0.12
  done
}
# Ensure spinner is killed & cursor restored on exit or interrupt:
cleanup() {
  if [[ -n "${sp_pid-}" ]]; then
    kill "$sp_pid" 2>/dev/null || true
    wait "$sp_pid" 2>/dev/null || true
    printf "\r\033[K"
  fi
  tput cnorm                                  # show cursor again
}
trap cleanup EXIT
# ── /SPINNER SETUP ─────────────────────────────────────────────────────────────

echo "⏳ Requesting your personal VM from $CONTROL …"
spin "Contacting controller…" & sp_pid=$!

# Talk to the controller (no PTY, so it never blocks on “PTY allocation failed”)
response="$(ssh $SSH_OPTS $SSH_CONTROL_OPTS "$CONTROL" 2>&1 || true)"

cleanup   # stop first spinner

# Extract the hostname, e.g. svm1234.net.in.tum.de
vm_host="$(grep -Eo 'root@[^[:space:]]+' <<<"$response" \
            | head -n1 | cut -d@ -f2)"

if [[ -z "$vm_host" ]]; then
  echo "❌  Could not detect VM hostname. Controller said:"
  echo "$response"
  exit 1
fi
echo "✅  VM hostname is $vm_host"

echo "⏳ Waiting for sshd inside the VM to become reachable …"
spin "Booting VM…" & sp_pid=$!

# Wait up to ~60 s for sshd
for _ in {1..30}; do
  if ssh $SSH_OPTS -o ConnectTimeout=3 root@"$vm_host" 'echo ok' \
     >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

cleanup
echo "🚀  VM is up — logging you in now!"

# Replace this process with interactive SSH
exec ssh $SSH_OPTS -t root@"$vm_host"

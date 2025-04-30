# grnvsvm 🎉

A tiny helper script that wakes up your personal TUM GRNVS VM and logs you in via SSH—no copy-pasting hostnames or accepting host-keys every time. Once installed, just run `grnvsvm` from **any** directory on macOS or Linux, and enjoy a slick spinner while your VM boots.

---

## 🚀 Prerequisites

- **OpenSSH ≥ 7.6**  
  Needed for `-o StrictHostKeyChecking=accept-new`.
    - macOS: Built-in since macOS 12 (Monterey) 
    - Linux: Usually pre-installed (`sudo apt install openssh-client` or `sudo dnf install openssh-clients`)  

- **A writable directory in your `$PATH`**  
  Most systems include `/usr/local/bin` by default
   
- **A POSIX shell** (`bash`, `zsh`, etc.) – no fancy dependencies required.

---

## 🔧 Installation

Choose one of the methods below to make `grnvsvm` available everywhere:

### 1. Copy to `/usr/local/bin` (system-wide)

```bash
sudo cp grnvsvm.sh /usr/local/bin/grnvsvm
sudo chmod 755 /usr/local/bin/grnvsvm
```

> **Why `/usr/local/bin`?**  
> It’s reserved for admin-installed tools, safe from OS updates, and always early in the shell’s search path.

### 2. Symlink from your personal `~/bin` (no sudo)

1. Create your personal bin directory if needed:
   ```bash
   mkdir -p ~/bin
   ```
2. Move & link the script:
   ```bash
   mv grnvs-connect.sh ~/bin/grnvsvm
   chmod +x ~/bin/grnvsvm
   ln -s ~/bin/grnvsvm /usr/local/bin/grnvsvm
   ```

> On Linux, you can also add `~/.local/bin` to your `$PATH` if you prefer  ([How To View and Update the Linux PATH Environment Variable](https://www.digitalocean.com/community/tutorials/how-to-view-and-update-the-linux-path-environment-variable?utm_source=chatgpt.com)).

---

## ✅ Verification

Confirm it’s on your `PATH`:

```bash
which grnvsvm   # → /usr/local/bin/grnvsvm
```

If nothing appears, add `/usr/local/bin` (or your chosen directory) to your shell profile:

- **macOS (zsh)**
  ```shell
  echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
  ```
- **Linux (bash)**
  ```shell
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
  ```

---

## 🎉 Usage

```bash
grnvsvm
```

- **Starts or wakes** your GRNVS VM via `ssh svm@grnvs.net`
- **Logs you in** as `root@svmXXXX.net.in.tum.de` automatically

---

## 🛠️ Updating & Uninstalling

- **Update manually**
  ```bash
  sudo curl -sSL https://gitlab.lrz.de/<you>/grnvsvm/-/raw/main/grnvs-connect.sh \
    -o /usr/local/bin/grnvsvm && chmod 755 /usr/local/bin/grnvsvm
  ```

- **Remove**
  ```bash
  sudo rm /usr/local/bin/grnvsvm
  ```

---

## ❓ Troubleshooting

- **`command not found: grnvsvm`**  
  Your install directory isn’t in `$PATH`. See **Verification** above.

- **Spinner hangs / VM never boots**
    - Check network: SSH (port 22) to `*.net.in.tum.de` must be allowed.
    - Try from another network or VPN.

- **“Host key verification failed”**  
  VM host‐keys changed. Remove the old entry with:
  ```bash
  ssh-keygen -R svmXXXX.net.in.tum.de
  ```

---

Made with ❤️ by Justin Lanfermann. Happy hacking!
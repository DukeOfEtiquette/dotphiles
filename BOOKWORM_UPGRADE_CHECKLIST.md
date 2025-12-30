# Debian 12 (Bookworm) Upgrade Checklist

Upgrading from Debian 11 (Bullseye) to Debian 12 (Bookworm).

This is **Part 1** of a sequential upgrade path: Bullseye → Bookworm → Trixie.

---

## Pre-Upgrade Checklist

### Create Backup Directory

```bash
sudo mkdir -p /backup
sudo chown $USER:$USER /backup
```

### Backups

- [ ] Backup /etc:
  ```bash
  sudo tar czf /backup/etc-backup-bullseye.tar.gz /etc
  ```

- [ ] Backup /home:
  ```bash
  tar czf /backup/home-backup-bullseye.tar.gz ~
  ```

- [ ] Verify dotfiles repo is clean (required):
  ```bash
  git -C ~/.everc/dotfiles status
  ```
  **Must show "nothing to commit, working tree clean"** - commit or stash changes first if not.

### System Inventory

- [ ] List manually installed packages:
  ```bash
  apt-mark showmanual > /backup/my-packages-bullseye.txt
  ```

- [ ] Document current kernel:
  ```bash
  uname -r | tee /backup/kernel-bullseye.txt
  ```

- [ ] Document Python version:
  ```bash
  python3 --version | tee /backup/python-bullseye.txt
  ```

- [ ] Document zsh version:
  ```bash
  zsh --version | tee /backup/zsh-bullseye.txt
  ```

- [ ] Verify no failed systemd units:
  ```bash
  systemctl --failed
  ```
  Fix any failures before proceeding.

- [ ] Verify no held packages:
  ```bash
  apt-mark showhold
  ```
  Should return empty. If not, evaluate each hold.

- [ ] Verify disk space (need 5-10GB free):
  ```bash
  df -h /
  ```

### Ensure Package System Health

```bash
sudo dpkg --configure -a
sudo apt --fix-broken install
sudo apt update && sudo apt upgrade
```

---

## Remove Unused Applications

Remove these applications and their repositories before upgrade:

```bash
# Remove azure-cli
sudo apt remove --purge azure-cli
sudo rm /etc/apt/sources.list.d/azure-cli.list

# Remove lutris
sudo apt remove --purge lutris
sudo rm /etc/apt/sources.list.d/lutris.list

# Remove opera
sudo apt remove --purge opera-stable
sudo rm /etc/apt/sources.list.d/opera-stable.list

# Remove skype (both apt and snap)
sudo apt remove --purge skypeforlinux
sudo rm /etc/apt/sources.list.d/skype-stable.list
sudo snap remove skype

# Remove teams
sudo apt remove --purge teams
sudo rm /etc/apt/sources.list.d/teams.list

# Clean up orphaned dependencies
sudo apt autoremove
```

---

## Switch Seafile to Official Debian Package

The third-party Seafile repo may not support Bookworm. Switch to Debian's official package:

```bash
# Remove third-party seafile
sudo apt remove --purge seafile-gui seafile-daemon
sudo rm /etc/apt/sources.list.d/seafile.list

# Install from Debian repos (already available in bullseye)
sudo apt update
sudo apt install seafile-gui
```

Note: Version will be 7.0.10 on Bullseye, upgrading to 8.0.10 on Bookworm.

---

## Clean Up Repository Files

Remove stale `.save` backup files:

```bash
sudo rm -f /etc/apt/sources.list.d/*.save
```

---

## Disable Third-Party Repositories

Disable these repos before upgrade (will re-enable with updated URLs after):

```bash
# Docker (references bullseye)
sudo mv /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.disabled

# pgAdmin4 (references bullseye)
sudo mv /etc/apt/sources.list.d/pgadmin4.list /etc/apt/sources.list.d/pgadmin4.list.disabled

# VirtualBox (references bullseye)
sudo mv /etc/apt/sources.list.d/virtualbox.list /etc/apt/sources.list.d/virtualbox.list.disabled
```

These repos use generic "stable" and should work without changes:
- brave-browser-release.list (no action needed)
- google-chrome.list (no action needed)
- steam-stable.list (no action needed)
- vscode.sources (no action needed)

---

## Upgrade Procedure

### Start tmux Session

Run the upgrade in tmux to protect against terminal disconnect:

```bash
tmux new -s upgrade
```

**If disconnected**, reattach with:
```bash
tmux attach -t upgrade
```

### Update sources.list

```bash
# Backup current sources.list
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bullseye.bak

# Update to bookworm
sudo sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list

# Add non-free-firmware component (new in Bookworm)
# Edit sources.list and add 'non-free-firmware' after 'non-free' on each line
sudo nano /etc/apt/sources.list
```

Your sources.list should look like this after editing:

```
deb http://deb.debian.org/debian bookworm main non-free non-free-firmware
deb-src http://deb.debian.org/debian bookworm main non-free non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware

deb http://deb.debian.org/debian bookworm-backports main non-free non-free-firmware
```

### Run the Upgrade

```bash
sudo apt update
sudo apt full-upgrade
```

**During upgrade:**
- When prompted about config file conflicts: **show diff and decide case-by-case**
- Review changes carefully before accepting maintainer's version or keeping yours

### Post-Upgrade Cleanup

```bash
sudo apt autoremove
sudo apt autoclean
```

### Reboot

```bash
sudo reboot
```

---

## Re-Enable Third-Party Repositories

After reboot, update and re-enable the disabled repositories:

### Docker

```bash
# Create updated docker.list for bookworm
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Remove old disabled file
sudo rm /etc/apt/sources.list.d/docker.list.disabled
```

### pgAdmin4

```bash
# Create updated pgadmin4.list for bookworm
echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/bookworm pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list

# Remove old disabled file
sudo rm /etc/apt/sources.list.d/pgadmin4.list.disabled
```

### VirtualBox

```bash
# Create updated virtualbox.list for bookworm
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle_vbox_2016.gpg] http://download.virtualbox.org/virtualbox/debian bookworm contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

# Remove old disabled file
sudo rm /etc/apt/sources.list.d/virtualbox.list.disabled
```

### Update Package Lists

```bash
sudo apt update
sudo apt upgrade
```

---

## Post-Upgrade Verification

### System Basics

- [ ] System boots successfully
- [ ] Can log in (GDM works)
- [ ] Network connectivity works:
  ```bash
  ping -c 3 google.com
  ```

### Critical Services

Verify these services are running:

```bash
systemctl status docker.service
systemctl status ssh.service
systemctl status gdm.service
systemctl status NetworkManager.service
systemctl status apache2.service
systemctl status cups.service
```

### Shell and Terminal

- [ ] Shell works (zsh loads, oh-my-zsh themes work):
  ```bash
  echo $SHELL
  zsh --version
  ```

- [ ] Terminal emulator works (xfce4-terminal or gnome-terminal)

- [ ] Secrets loading from `secrets/` directory:
  ```bash
  # Verify your secrets are loaded (check for expected env vars)
  env | grep -i your_expected_secret_prefix
  ```

### Development Tools

- [ ] GCC/C++ compiler works:
  ```bash
  g++ --version
  ```

- [ ] Python version:
  ```bash
  python3 --version
  ```

- [ ] Docker works:
  ```bash
  docker --version
  docker ps
  ```

### Applications

- [ ] Brave browser launches
- [ ] Google Chrome launches
- [ ] Seafile client works (may need to re-login)
- [ ] VirtualBox works (if you use VMs)
- [ ] pgAdmin4 works
- [ ] Steam launches

### Snap Applications

- [ ] Snap service running:
  ```bash
  systemctl status snapd.service
  ```

- [ ] Snaps work (test ones you use frequently):
  - blender
  - pinta
  - plex-desktop
  - notepad-plus-plus
  - tradingview

### Hardware

- [ ] Trezor hardware wallet works (if applicable):
  ```bash
  systemctl status trezord.service
  ```

### System Settings

- [ ] Timezone correct:
  ```bash
  timedatectl
  ```

- [ ] Locale correct:
  ```bash
  localectl
  ```

### Dotfiles

- [ ] Re-run dotfiles installer:
  ```bash
  cd ~/.everc/dotfiles
  ./installDotfiles.sh --profile rogue
  ```

---

## Rollback Notes

If upgrade fails badly:

1. Boot from Debian live USB
2. Mount root partition
3. Restore /etc backup:
   ```bash
   sudo tar xzf /backup/etc-backup-bullseye.tar.gz -C /
   ```
4. Chroot and fix package issues, or reinstall

---

## Next Steps

After completing this checklist and verifying everything works on Bookworm:

1. Use the system normally for a few days to ensure stability
2. Proceed to `TRIXIE_UPGRADE_CHECKLIST.md` for the Bookworm → Trixie upgrade

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

- [ ] Backup /var/lib/dpkg (critical for package system recovery):
  ```bash
  sudo tar czf /backup/var-lib-dpkg-bullseye.tar.gz /var/lib/dpkg
  ```

- [ ] Backup /var/lib/apt/extended_states:
  ```bash
  sudo cp /var/lib/apt/extended_states /backup/extended_states-bullseye
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

- [ ] Save complete package selections (for full restoration if needed):
  ```bash
  dpkg --get-selections '*' > /backup/pkg-selections-bullseye.txt
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

- [ ] Verify kernel metapackage is installed:
  ```bash
  dpkg -l 'linux-image*' | grep ^ii | grep -i meta
  ```
  Should show `linux-image-amd64` or similar. If missing, install it:
  ```bash
  sudo apt install linux-image-amd64
  ```

- [ ] Check for APT pinning (must be disabled for upgrade):
  ```bash
  ls -la /etc/apt/preferences /etc/apt/preferences.d/ 2>/dev/null
  ```
  If pinning exists, disable or remove it before proceeding.

- [ ] Check for proposed-updates in sources (should be removed):
  ```bash
  grep -r proposed-updates /etc/apt/sources.list /etc/apt/sources.list.d/
  ```
  Remove any proposed-updates lines before upgrading.

### Ensure Package System Health

```bash
sudo dpkg --audit
sudo dpkg --configure -a
sudo apt --fix-broken install
sudo apt update && sudo apt upgrade
```

`dpkg --audit` should return nothing. If it reports packages in Half-Installed or Failed-Config states, fix them before proceeding.

### Clean Up Leftover Config Files

Check for stale config backups that may cause confusion:

```bash
sudo find /etc -name '*.dpkg-*' -o -name '*.ucf-*' -o -name '*.merge-error' | head -20
```

Review and remove any that are no longer needed.

### Identify Non-Debian Packages

List packages not from official Debian repos (may cause upgrade conflicts):

```bash
apt list '?narrow(?installed, ?not(?origin(Debian)))' 2>/dev/null || \
  aptitude search '?narrow(?installed, ?not(?origin(Debian)))'
```

Evaluate each package - remove or ensure compatibility with Bookworm.

### Remove Obsolete Packages

Identify packages that are no longer in any repository (can cause upgrade complications):

```bash
apt list '~o' 2>/dev/null
```

If any are found, review and remove them:

```bash
sudo apt purge '~o'
```

### Remove Backports from Sources

Bullseye backports must be disabled before upgrading:

```bash
grep -r backports /etc/apt/sources.list /etc/apt/sources.list.d/
```

Comment out or remove any lines containing `bullseye-backports` or `bullseye-backports-sloppy`.

### Verify Console Switching Works

Test that you can switch virtual terminals (needed if display issues occur during upgrade):

- From GUI: Press `Ctrl+Alt+F2` to switch to tty2, then `Ctrl+Alt+F1` or `Ctrl+Alt+F7` to return
- From console: Press `Alt+F2` to switch, then `Alt+F1` to return

If these don't work, troubleshoot before proceeding.

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

### Start Session Recording

Record the entire upgrade session for troubleshooting (run inside tmux):

```bash
script -t 2>~/upgrade-bookworm.time -a ~/upgrade-bookworm.script
```

This creates a typescript log you can replay later with:
```bash
scriptreplay ~/upgrade-bookworm.time ~/upgrade-bookworm.script
```

APT also logs to `/var/log/apt/history.log` and `/var/log/apt/term.log`.

### Verify Root Filesystem is Writable

Ensure the root partition isn't mounted read-only (can happen after filesystem errors):

```bash
mount | grep ' / '
```

If it shows `ro`, remount as read-write:
```bash
sudo mount -o remount,rw /
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

**WARNING:** Do NOT use NFS for the package cache during upgrade. Network interruption during NFS access can corrupt the upgrade process.

```bash
sudo apt update
```

**Note:** If you see errors about repository information changing, use:
```bash
sudo apt update --allow-releaseinfo-change
```

**Check disk space requirements before committing:**

```bash
sudo apt -o APT::Get::Trivial-Only=true full-upgrade
```

This shows how much space is needed without making changes. Ensure you have enough free space.

**Phase 1 - Minimal upgrade (safer, no package removals):**

```bash
sudo apt upgrade --without-new-pkgs
```

**Phase 2 - Full upgrade:**

```bash
sudo apt full-upgrade
```

**During upgrade:**
- When prompted about config file conflicts: **show diff and decide case-by-case**
- **Exception:** For `/etc/init.d/*` scripts, generally accept the maintainer's version (old version saved as `.dpkg-old`)
- Review changes carefully before accepting maintainer's version or keeping yours
- **If the display switches away** (common with kernel/graphics updates): use `Ctrl+Alt+F1` (from GUI) or `Alt+F1` (from console) to return to the upgrade terminal

### Troubleshooting Upgrade Errors

If you encounter errors during upgrade:

**"Could not perform immediate configuration" error:**
```bash
sudo apt full-upgrade -o APT::Immediate-Configure=0
```

**Dependency loop blocking upgrade:**
```bash
sudo apt full-upgrade -o APT::Force-LoopBreak=1
```

**File conflicts from non-standard packages:**
```bash
sudo dpkg -r --force-depends <conflicting-package>
# Then retry apt full-upgrade
```

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
  ./updateDotfiles.sh --profile rogue
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

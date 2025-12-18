# Debian 13 (Trixie) Upgrade Checklist

Upgrading from Debian 11 (bullseye) to Debian 13 (trixie).

## Profile-Specific Notes

- **rogue**: i3wm configs in this profile are cruft/unused - can be ignored or cleaned up before upgrade

## Pre-Upgrade Checklist

### Backups
- [ ] Backup /etc: `sudo tar czf /backup/etc-backup.tar.gz /etc`
- [ ] Backup /home: `tar czf /backup/home-backup.tar.gz ~`
- [ ] Backup dotfiles repo state: `git -C ~/.everc/dotfiles status` (ensure clean)

### System Inventory
- [ ] List manually installed packages: `apt-mark showmanual > ~/my-packages.txt`
- [ ] Document current kernel: `uname -r`
- [ ] Note custom kernel modules/drivers in use (NVIDIA, VirtualBox, etc.)
- [ ] Check disk space (need several GB free): `df -h /`

### Third-Party Sources
- [ ] List third-party repos: `grep -r "^deb " /etc/apt/sources.list.d/`
- [ ] Disable or remove third-party repos before upgrade
- [ ] Note which repos to re-enable after upgrade

---

## Risk Assessment

### High Risk
- **Custom kernel modules/drivers** - NVIDIA, VirtualBox, out-of-tree modules need rebuilding
- **Third-party repos** - May not have trixie packages, cause dependency conflicts
- **Boot failures** - GRUB misconfigurations, especially dual-boot or UEFI
- **Desktop environment** - Major version jumps can break configs/extensions

### Medium Risk
- **Python version changes** - System Python may jump versions, breaking scripts
- **Service config changes** - Systemd units may need manual migration
- **Library ABI changes** - Locally compiled software may need rebuilding
- **SSH stricter defaults** - Older key types or ciphers may be disabled

### Lower Risk
- **Config file conflicts** - Prompts asking to keep your version vs maintainer's
- **Removed packages** - Some packages dropped or renamed
- **Font/theme changes** - GTK or font rendering can look different

---

## Upgrade Commands

```bash
# 1. Update current system first
sudo apt update && sudo apt upgrade

# 2. Change sources to trixie
sudo sed -i 's/bullseye/trixie/g' /etc/apt/sources.list

# 3. Upgrade
sudo apt update
sudo apt full-upgrade

# 4. Reboot
sudo reboot
```

---

## Post-Upgrade Verification

- [ ] System boots successfully
- [ ] Can log in as all users
- [ ] Network connectivity works
- [ ] Critical services running
- [ ] Shell works (zsh loads, oh-my-zsh themes work)
- [ ] Terminal emulator works (xfce4-terminal)
- [ ] GCC/C++ compiler works: `g++ --version`
- [ ] Secrets still loading from `secrets/` directory

---

## Rollback Notes

If upgrade fails badly:
1. Boot from Debian live USB
2. Mount root partition
3. Restore /etc backup
4. Chroot and fix package issues, or reinstall

Consider: Take a full disk image before upgrading if system is critical.

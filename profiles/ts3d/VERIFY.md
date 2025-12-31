# ts3d Profile - Post-Bootstrap Verification

## Manual Checks (after logout/login)

### Shell & Environment
- [ ] Shell is zsh: `echo $SHELL`
- [ ] oh-my-zsh theme loads correctly
- [ ] LS_COLORS working: `ls` shows colors

### Docker
- [ ] Works without sudo: `docker run hello-world`

### Git & GitHub
- [ ] SSH key added to GitHub
- [ ] Test SSH: `ssh -T git@github.com`

### VS Code
- [ ] Settings Sync enabled
- [ ] Extensions synced

### Profile-Specific: i3 Window Manager
- [ ] Can login to i3 session (select at login screen)
- [ ] i3status shows correct network interface
- [ ] Keybindings work ($mod+Return opens terminal)
- [ ] Workspaces function correctly

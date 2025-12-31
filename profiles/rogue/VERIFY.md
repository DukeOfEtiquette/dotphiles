# Rogue Profile - Post-Bootstrap Verification

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

### Profile-Specific: Maverick
- [ ] ROGUE_ROOT set: `echo $ROGUE_ROOT`
- [ ] ROGUE_BUILDS set: `echo $ROGUE_BUILDS`
- [ ] Build scripts available: `which mavBuild`

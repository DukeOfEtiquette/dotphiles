# Troubleshooting

Common issues and solutions for the dotfiles bootstrap system.

## Bootstrap Issues

### "Permission denied" running bootstrap.sh

```bash
chmod +x bootstrap.sh
chmod +x setup/*.sh
```

### Stage fails partway through

Resume from the failed stage:
```bash
./bootstrap.sh --profile rogue --stage <N>
```

### Want to re-run a completed stage

Clear the state marker and re-run:
```bash
# Edit ~/.everc/.setup-state and remove the relevant line
# Or use --reset to clear all state
./bootstrap.sh --profile rogue --reset
```

## Shell Issues

### zsh not the default shell after install

The shell change requires logout/login. If still not working:
```bash
chsh -s $(which zsh)
# Then log out and back in
```

### oh-my-zsh prompts are slow

The git prompt can be slow on large repos. Disable async prompt:
```bash
# Add to ~/.zshrc before oh-my-zsh is sourced:
zstyle ':omz:alpha:lib:git' async-prompt no
```

### Command not found after install

Source the new shell config:
```bash
source ~/.zshrc
```

Or open a new terminal.

## Docker Issues

### "permission denied" with docker commands

Add yourself to the docker group:
```bash
sudo usermod -aG docker $USER
```
Then **log out and back in**.

Verify:
```bash
groups | grep docker
```

### Docker service not running

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

## i3 Issues

### i3status shows wrong network interface

Find your interfaces:
```bash
# Wireless
iw dev | grep Interface
# or
ls /sys/class/net/ | grep wl

# Wired
ls /sys/class/net/ | grep -E '^(eth|enp|eno)'
```

Edit `~/.config/i3status/config` and update the interface names.

### i3 keybindings not working

Reload i3 config:
```
Mod+Shift+r
```

## NVM/Node Issues

### "nvm: command not found"

Source nvm manually:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

Or open a new terminal after install.

### Node not found after nvm install

Install Node LTS:
```bash
nvm install --lts
nvm use --lts
```

## Git Issues

### SSH key not working with GitHub

1. Check key exists: `ls -la ~/.ssh/id_ed25519.pub`
2. Add to ssh-agent:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```
3. Add public key to GitHub: https://github.com/settings/keys
4. Test: `ssh -T git@github.com`

### Git config not set

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## Package Issues

### apt packages fail to install

Update package cache:
```bash
sudo apt update
sudo apt upgrade
```

### Package not found

Check if you're on a supported Debian version:
```bash
cat /etc/os-release
```

Some packages have different names on Debian:
- `bat` is `batcat` on older Debian

## Dotfiles Issues

### Symlinks not created

Run installDotfiles.sh manually:
```bash
cd ~/.everc/dotfiles
./installDotfiles.sh --profile rogue
```

### Conflicts with existing files

The install script backs up existing files to:
```
~/.everc/dotfiles_bck/
```

Check there for your original files.

## VS Code Issues

### VS Code not launching

Try launching from terminal to see errors:
```bash
code --verbose
```

### Extensions not syncing

Enable Settings Sync:
1. Open VS Code
2. Click the person icon (bottom left)
3. Sign in with GitHub
4. Turn on Settings Sync

## Hardware-Specific Issues

### Display/resolution problems

Use arandr for GUI configuration:
```bash
arandr
```

Save the configuration, then copy the generated script.

### Audio not working

Check PulseAudio:
```bash
pavucontrol
```

Make sure the correct output device is selected.

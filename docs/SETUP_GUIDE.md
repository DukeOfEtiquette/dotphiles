# Setup Guide

This guide explains how to use the bootstrap system to set up a fresh Debian machine.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/DukeOfEtiquette/dotfiles.git ~/.everc/dotfiles
cd ~/.everc/dotfiles

# Run bootstrap
./bootstrap.sh --profile rogue
```

## Prerequisites

- Fresh Debian 11 (bullseye), 12 (bookworm), or 13 (trixie) installation
- User account with sudo access
- Network connectivity

## Bootstrap Options

```
./bootstrap.sh --profile <profile> [options]

Required:
  --profile, -p <name>   Profile: rogue, gomez, ts3d

Options:
  --yes, -y              Skip prompts (auto-confirm)
  --stage, -s <N>        Start from stage N
  --dry-run              Preview without changes
  --reset                Clear state and start fresh
```

## Stages

The bootstrap runs through 11 stages:

| Stage | Script | Description |
|-------|--------|-------------|
| 0 | 00-preflight.sh | System checks (OS, sudo, network, disk) |
| 1 | 01-packages-core.sh | Core packages (curl, wget, git) |
| 2 | 02-shell.sh | zsh and oh-my-zsh |
| 3 | 03-git-config.sh | Git user config, SSH key generation |
| 4 | 04-packages-dev.sh | Build toolchain (cmake, make, gcc) |
| 5 | 05-packages-desktop.sh | Desktop environment (i3, terminal) |
| 6 | 06-nvm.sh | Node Version Manager |
| 7 | 07-docker.sh | Docker CE |
| 8 | 08-apps-external.sh | Chrome, VSCode, Discord |
| 9 | 09-dotfiles.sh | Runs installDotfiles.sh |
| 10 | 10-post-install.sh | Font cache, final verification |

## Idempotency

The bootstrap is idempotent - safe to run multiple times. Progress is tracked in `~/.everc/.setup-state`.

To re-run a specific stage:
```bash
./bootstrap.sh --profile rogue --stage 5
```

To start completely fresh:
```bash
./bootstrap.sh --profile rogue --reset
```

## Profiles

### rogue
Full Maverick development environment with:
- Complete build toolchain (cmake, make, gcc)
- Maverick directory structure at `~/rogue/`
- All desktop utilities

### ts3d
TS3D development focus:
- Docker for containerized builds
- git-lfs for large files
- Conan package manager path

### gomez
General workstation setup.

## Post-Installation

After bootstrap completes:

1. **Log out and back in** - Required for docker group and zsh shell
2. **Add SSH key to GitHub** - `cat ~/.ssh/id_ed25519.pub`
3. **Update i3status config** - Set correct network interface names in `~/.config/i3status/config`
4. **Enable VS Code Settings Sync** - For your extensions and settings

## Secrets

Secrets are NOT stored in this repository. After setup:

1. Copy the template: `cp secrets/.env.example secrets/.env`
2. Edit with your credentials
3. Secrets are loaded automatically by `secrets.sh`

See `profiles/shared/home/secrets.sh` for the loading mechanism.

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles management system for Linux workstations using zsh, i3wm, and xfce4-terminal. The repository manages configuration files across multiple machine profiles and provides automated fresh machine setup.

## Key Commands

### Fresh Machine Setup (Debian 11/12/13)

Bootstrap a fresh machine with everything installed:
```bash
./bootstrap.sh --profile <profile_name>
```

Options:
- `--yes` - Skip prompts (auto-confirm)
- `--stage N` - Resume from stage N (0-10)
- `--dry-run` - Preview without changes
- `--reset` - Clear state and start fresh

### Existing Systems

Install/update dotfiles only (assumes packages already installed):
```bash
./updateDotfiles.sh --profile <profile_name>
```

Preview changes without making them:
```bash
./updateDotfiles.sh --profile <profile_name> --dry-run
```

Valid profiles: `gomez`, `rogue`, `ts3d`

The install script backs up existing dotfiles to `~/.everc/dotfiles_bck/` before creating symlinks.

## Architecture

### Directory Structure

- `bootstrap.sh` - Entry point for fresh machine setup
- `updateDotfiles.sh` - Dotfile symlink/copy installer
- `setup/` - Modular setup scripts for bootstrap
  - `lib/` - Shared functions (common.sh, packages.sh, verify.sh)
  - `manifests/` - Package lists (packages-core.txt, packages-dev.txt, packages-desktop.txt)
  - `00-10-*.sh` - Stage scripts (preflight, packages, shell, git, docker, etc.)
- `profiles/` - Machine-specific configurations
  - `gomez/`, `rogue/`, `ts3d/` - Individual machine profiles
  - `shared/` - Common files used across all profiles (backgrounds, i3 config, oh-my-zsh themes, tmux sessions)
- `docs/` - Documentation
  - `SETUP_GUIDE.md` - Detailed setup walkthrough
  - `TROUBLESHOOTING.md` - Common issues and solutions
  - `UPGRADE_DEBIAN.md` - Version upgrade checklists

### Profile Structure

Each profile contains:
- `home/` - Files symlinked to `$HOME` as dotfiles (e.g., `zshrc` → `~/.zshrc`)
- `bin/` - Scripts copied to `$HOME/bin`
- `.config/` - Config directories copied to `~/.config/` (i3status, dunst, xfce4/terminal)

Shared resources (in `profiles/shared/`):
- `.fonts/` - Custom fonts (Cascadia, FiraCode, Hack)
- `.config/i3/` - i3 window manager config
- `bin/` - Common scripts (lscolors.sh, backup_linux.sh)
- `omz_themes/` - Oh-My-Zsh themes (wezm-duke)

Note: i3status configs remain profile-specific as they reference hardware-specific interfaces.

### Profile-Specific Notes

**rogue:**
- Has `zprofile` for login shell initialization (other profiles use only `zshrc`)
- Uses async git prompt disabled: `zstyle ':omz:alpha:lib:git' async-prompt no`
- Contains Maverick build scripts (mavBuild, mavPull, mavRebuild, etc.)

**ts3d:**
- Focused on TS3D development with specialized clone/docker scripts
- Uses `bat` aliased to `batcat` (Debian naming convention)

**gomez:**
- Contains some macOS-specific aliases in bashrc (legacy)

### Bootstrap Stages

The `bootstrap.sh` script runs these stages in order:

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
| 9 | 09-dotfiles.sh | Runs updateDotfiles.sh |
| 10 | 10-post-install.sh | Font cache, final verification |

Progress is tracked in `~/.everc/.setup-state` for idempotency.

### Installation Behavior

The `updateDotfiles.sh` script:
1. Expects to run from `$HOME/.everc/dotfiles`
2. Sets up the `secrets/` directory with proper permissions
3. Backs up existing configs before installing
4. Creates symlinks for home directory dotfiles
5. Copies (not symlinks) bin scripts and .config directories

## Secrets Management

**NEVER commit API keys, tokens, or credentials to this repository.**

Secrets are stored in `secrets/` (gitignored) and loaded via `profiles/shared/home/secrets.sh`:
- `secrets/.env` - Shared secrets for all profiles
- `secrets/.env.<profile>` - Profile-specific secrets (e.g., `.env.rogue`)

The `.env.example` template shows expected secret formats. Secrets are automatically sourced when opening a new shell.

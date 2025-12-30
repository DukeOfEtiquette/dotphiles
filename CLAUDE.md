# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles management system for Linux workstations using zsh, i3wm, and xfce4-terminal. The repository manages configuration files across multiple machine profiles.

## Key Commands

Install dotfiles for a specific profile:
```bash
./installDotfiles.sh --profile <profile_name>
```

Preview changes without making them:
```bash
./installDotfiles.sh --profile <profile_name> --dry-run
```

Valid profiles: `gomez`, `rogue`, `ts3d`

The install script backs up existing dotfiles to `~/.everc/dotfiles_bck/` before creating symlinks.

## Architecture

### Directory Structure

- `profiles/` - Machine-specific configurations
  - `gomez/`, `rogue/`, `ts3d/` - Individual machine profiles
  - `shared/` - Common files used across all profiles (backgrounds, i3 config, oh-my-zsh themes, tmux sessions)
- `installDotfiles.sh` - Main installation script

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

### Installation Behavior

The `installDotfiles.sh` script:
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

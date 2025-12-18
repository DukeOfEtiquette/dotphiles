# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles management system for Linux workstations using zsh, i3wm, and xfce4-terminal. The repository manages configuration files across multiple machine profiles.

## Key Commands

Install dotfiles for a specific profile:
```bash
./installDotfiles.sh --profile <profile_name>
```

Valid profiles: `gomez`, `rogue`

The install script backs up existing dotfiles to `~/.everc/dotfiles_bck/` before creating symlinks.

## Architecture

### Directory Structure

- `profiles/` - Machine-specific configurations
  - `gomez/`, `rogue/` - Individual machine profiles
  - `shared/` - Common files used across all profiles (backgrounds, oh-my-zsh themes, tmux sessions)
- `installDotfiles.sh` - Main installation script

### Profile Structure

Each profile contains:
- `home/` - Files symlinked to `$HOME` as dotfiles (e.g., `zshrc` → `~/.zshrc`)
- `bin/` - Scripts copied to `$HOME/bin`
- `.config/` - Config directories copied to `~/.config/` (i3, i3status, dunst, xfce4/terminal)
- `.fonts/` - Custom fonts copied to `~/.fonts/`

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

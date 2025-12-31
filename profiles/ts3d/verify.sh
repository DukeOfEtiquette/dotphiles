#!/bin/bash
# Automated verification for ts3d profile
# Run this script to check installation status

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_ROOT/setup/lib/common.sh"
source "$DOTFILES_ROOT/setup/lib/verify.sh"

echo ""
echo "============================================"
echo "  TS3D PROFILE VERIFICATION"
echo "============================================"
echo ""

# Shell
echo "Shell:"
verify_command_exists zsh && echo "  [OK] zsh installed" || echo "  [!!] zsh NOT installed"
verify_zsh_default && echo "  [OK] zsh is default shell" || echo "  [--] zsh not default (requires logout/login)"
verify_omz_installed && echo "  [OK] oh-my-zsh installed" || echo "  [!!] oh-my-zsh NOT installed"

# Git
echo ""
echo "Git:"
verify_git_user_name && echo "  [OK] git user.name: $(git config --global user.name)" || echo "  [!!] git user.name NOT configured"
verify_git_user_email && echo "  [OK] git user.email: $(git config --global user.email)" || echo "  [!!] git user.email NOT configured"
verify_ssh_key && echo "  [OK] SSH key exists" || echo "  [!!] SSH key NOT found"

# Development tools
echo ""
echo "Development:"
for cmd in cmake make g++ ccmake; do
    verify_command_exists "$cmd" && echo "  [OK] $cmd" || echo "  [!!] $cmd NOT found"
done

# Desktop
echo ""
echo "Desktop:"
for cmd in xfce4-terminal xclip flameshot tmux; do
    verify_command_exists "$cmd" && echo "  [OK] $cmd" || echo "  [!!] $cmd NOT found"
done

# i3 (ts3d-specific)
echo ""
echo "i3 Window Manager (ts3d-specific):"
verify_command_exists i3 && echo "  [OK] i3 installed" || echo "  [!!] i3 NOT installed"
verify_command_exists i3status && echo "  [OK] i3status installed" || echo "  [!!] i3status NOT installed"
verify_command_exists i3lock && echo "  [OK] i3lock installed" || echo "  [!!] i3lock NOT installed"
verify_command_exists dmenu && echo "  [OK] dmenu installed" || echo "  [!!] dmenu NOT installed"
[[ -f "$HOME/.config/i3/config" ]] && echo "  [OK] i3 config exists" || echo "  [!!] i3 config NOT found"
[[ -f "$HOME/.config/i3status/config" ]] && echo "  [OK] i3status config exists" || echo "  [!!] i3status config NOT found"

# Node
echo ""
echo "Node.js:"
[[ -d "$HOME/.nvm" ]] && echo "  [OK] nvm installed" || echo "  [!!] nvm NOT installed"
verify_command_exists node && echo "  [OK] node: $(node --version 2>/dev/null)" || echo "  [--] node not in PATH (source ~/.zshrc)"

# Docker
echo ""
echo "Docker:"
verify_command_exists docker && echo "  [OK] docker installed" || echo "  [!!] docker NOT installed"
verify_group_membership docker && echo "  [OK] user in docker group" || echo "  [--] user NOT in docker group (requires logout/login)"

# Applications (optional)
echo ""
echo "Applications (optional):"
for cmd in google-chrome code discord; do
    verify_command_exists "$cmd" && echo "  [OK] $cmd" || echo "  [--] $cmd not found"
done

echo ""

#!/bin/bash
# Automated verification for gomez profile
# Run this script to check installation status

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_ROOT/setup/lib/common.sh"
source "$DOTFILES_ROOT/setup/lib/verify.sh"

echo ""
echo "============================================"
echo "  GOMEZ PROFILE VERIFICATION"
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

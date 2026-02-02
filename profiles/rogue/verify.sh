#!/bin/bash
# Automated verification for rogue profile
# Run this script to check installation status

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_ROOT/setup/lib/common.sh"
source "$DOTFILES_ROOT/setup/lib/verify.sh"

echo ""
echo "============================================"
echo "  ROGUE PROFILE VERIFICATION"
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

# Profile-specific: Maverick
echo ""
echo "Maverick (rogue-specific):"
[[ -d "${ROGUE_ROOT:-$HOME/rogue}/src" ]] && echo "  [OK] ~/rogue/src exists" || echo "  [!!] ~/rogue/src NOT found"
[[ -d "${ROGUE_ROOT:-$HOME/rogue}/builds" ]] && echo "  [OK] ~/rogue/builds exists" || echo "  [!!] ~/rogue/builds NOT found"
[[ -n "${ROGUE_ROOT:-}" ]] && echo "  [OK] ROGUE_ROOT=$ROGUE_ROOT" || echo "  [--] ROGUE_ROOT not set (source ~/.zshrc)"
[[ -n "${ROGUE_BUILDS:-}" ]] && echo "  [OK] ROGUE_BUILDS=$ROGUE_BUILDS" || echo "  [--] ROGUE_BUILDS not set (source ~/.zshrc)"
verify_command_exists mavBuild && echo "  [OK] mavBuild in PATH" || echo "  [--] mavBuild not in PATH (check ~/bin)"

# Applications (optional)
echo ""
echo "Applications (optional):"
for cmd in google-chrome code discord; do
    verify_command_exists "$cmd" && echo "  [OK] $cmd" || echo "  [--] $cmd not found"
done

echo ""

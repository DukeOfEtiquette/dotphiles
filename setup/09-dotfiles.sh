#!/bin/bash
# setup/09-dotfiles.sh - Install dotfiles
# Runs: installDotfiles.sh, installs LS_COLORS

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/verify.sh"

# Get the dotfiles root (parent of setup/)
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

main() {
    stage_start "Dotfiles Installation"

    local profile="${PROFILE:-rogue}"

    # Verify we're in the right place
    log_step "Verifying dotfiles repository..."
    if [[ ! -f "$DOTFILES_ROOT/installDotfiles.sh" ]]; then
        log_error "installDotfiles.sh not found at $DOTFILES_ROOT"
        log_error "Make sure you're running from the dotfiles repository"
        exit 1
    fi
    log_substep "Dotfiles root: $DOTFILES_ROOT"

    # Install dotfiles
    log_step "Installing dotfiles for profile: $profile..."
    if ! check_complete "dotfiles-installed-$profile"; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY RUN] Would run: ./installDotfiles.sh --profile $profile"
        else
            cd "$DOTFILES_ROOT"
            ./installDotfiles.sh --profile "$profile"
            log_success "Dotfiles installed for profile: $profile"
        fi
        mark_complete "dotfiles-installed-$profile"
    else
        log_substep "Dotfiles already installed for profile: $profile"
    fi

    # Install LS_COLORS (dircolors)
    log_step "Installing LS_COLORS..."
    if ! check_complete "lscolors-installed"; then
        if [[ -f "$HOME/.dircolors" ]]; then
            log_substep "LS_COLORS already installed"
        else
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_info "[DRY RUN] Would install LS_COLORS"
            else
                log_substep "Downloading LS_COLORS..."
                # Save raw database format (NOT dircolors -b output which is shell code)
                curl -sL https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/LS_COLORS -o "$HOME/.dircolors"
                log_success "LS_COLORS installed"
            fi
        fi
        mark_complete "lscolors-installed"
    else
        log_substep "LS_COLORS already installed"
    fi

    # Verify
    log_step "Verifying installation..."

    # Check key symlinks
    local symlinks_ok=true
    for file in .zshrc .vimrc; do
        if [[ -L "$HOME/$file" ]]; then
            log_success "Symlink exists: ~/$file"
        else
            log_warn "Missing symlink: ~/$file"
            symlinks_ok=false
        fi
    done

    # Check key directories
    if [[ -d "$HOME/.oh-my-zsh/themes" ]]; then
        log_success "oh-my-zsh themes directory exists"
    fi

    if [[ -d "$HOME/bin" ]]; then
        log_success "~/bin directory exists"
    fi

    stage_end
}

main "$@"

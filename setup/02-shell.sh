#!/bin/bash
# setup/02-shell.sh - zsh and oh-my-zsh installation
# Installs: zsh, sets as default shell, installs oh-my-zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/verify.sh"

main() {
    stage_start "Shell Setup"

    # Install zsh if needed
    log_step "Installing zsh..."
    if ! check_complete "zsh-installed"; then
        install_apt_package "zsh"
        mark_complete "zsh-installed"
    else
        log_substep "zsh already installed"
    fi

    # Set zsh as default shell
    log_step "Setting zsh as default shell..."
    if ! check_complete "zsh-default"; then
        if verify_zsh_default; then
            log_substep "zsh is already the default shell"
        else
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_info "[DRY RUN] Would run: chsh -s $(which zsh)"
            else
                log_substep "Changing default shell to zsh..."
                sudo chsh -s "$(which zsh)" "$USER"
                log_success "Default shell changed to zsh"
                log_warn "You will need to log out and back in for this to take effect"
            fi
        fi
        mark_complete "zsh-default"
    else
        log_substep "zsh already set as default"
    fi

    # Install oh-my-zsh
    log_step "Installing oh-my-zsh..."
    if ! check_complete "omz-installed"; then
        if verify_omz_installed; then
            log_substep "oh-my-zsh already installed"
        else
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_info "[DRY RUN] Would install oh-my-zsh"
            else
                log_substep "Downloading and installing oh-my-zsh..."
                # Use unattended install - don't change shell (already done) or start zsh
                RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
                log_success "oh-my-zsh installed"
            fi
        fi
        mark_complete "omz-installed"
    else
        log_substep "oh-my-zsh already installed"
    fi

    # Verify
    log_step "Verifying installation..."
    stage_verify "zsh installed" "verify_command_exists zsh"
    stage_verify "oh-my-zsh installed" "verify_omz_installed"

    stage_end
}

main "$@"

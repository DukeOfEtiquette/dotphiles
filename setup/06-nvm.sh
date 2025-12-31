#!/bin/bash
# setup/06-nvm.sh - Node Version Manager
# Installs: nvm, latest LTS Node.js

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/verify.sh"

NVM_VERSION="v0.39.7"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

main() {
    stage_start "Node Version Manager"

    # Install nvm
    log_step "Installing nvm..."
    if ! check_complete "nvm-installed"; then
        if [[ -d "$NVM_DIR" ]]; then
            log_substep "nvm directory already exists"
        else
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_info "[DRY RUN] Would install nvm $NVM_VERSION"
            else
                log_substep "Downloading nvm $NVM_VERSION..."
                curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
                log_success "nvm installed"
            fi
        fi
        mark_complete "nvm-installed"
    else
        log_substep "nvm already installed"
    fi

    # Source nvm for this session (disable nounset - nvm doesn't handle it well)
    export NVM_DIR="$HOME/.nvm"
    set +u
    # shellcheck source=/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
    set -u

    # Install latest LTS Node
    log_step "Installing Node.js LTS..."
    if ! check_complete "node-lts-installed"; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY RUN] Would install Node.js LTS"
        else
            if command -v nvm &>/dev/null; then
                log_substep "Installing latest LTS version..."
                set +u  # nvm commands don't handle nounset
                nvm install --lts
                nvm use --lts
                nvm alias default 'lts/*'
                set -u
                log_success "Node.js LTS installed and set as default"
            else
                log_warn "nvm not available in this session"
                log_warn "Node.js will be installed on next shell session"
            fi
        fi
        mark_complete "node-lts-installed"
    else
        log_substep "Node.js LTS already installed"
    fi

    # Verify
    log_step "Verifying installation..."
    if [[ -d "$NVM_DIR" ]]; then
        log_success "nvm directory exists: $NVM_DIR"
    else
        log_warn "nvm directory not found"
    fi

    if command -v node &>/dev/null; then
        verify_command_version "node" "--version"
        verify_command_version "npm" "--version"
    else
        log_info "Node.js will be available after sourcing ~/.zshrc or opening a new terminal"
    fi

    stage_end
}

main "$@"

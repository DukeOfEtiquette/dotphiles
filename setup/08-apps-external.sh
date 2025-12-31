#!/bin/bash
# setup/08-apps-external.sh - External applications
# Installs: Google Chrome, VSCode, Discord

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/verify.sh"

main() {
    stage_start "External Applications"

    # Google Chrome
    log_step "Installing Google Chrome..."
    if ! check_complete "chrome-installed"; then
        if verify_command_exists google-chrome || verify_command_exists google-chrome-stable; then
            log_substep "Google Chrome already installed"
        else
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_info "[DRY RUN] Would install Google Chrome"
            else
                install_deb_from_url \
                    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
                    "google-chrome"
            fi
        fi
        mark_complete "chrome-installed"
    else
        log_substep "Google Chrome installation already done"
    fi

    # Visual Studio Code
    log_step "Installing Visual Studio Code..."
    if ! check_complete "vscode-installed"; then
        if verify_command_exists code; then
            log_substep "VS Code already installed"
        else
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_info "[DRY RUN] Would install VS Code"
            else
                # Add Microsoft GPG key
                log_substep "Adding Microsoft GPG key..."
                curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
                sudo chmod a+r /etc/apt/keyrings/packages.microsoft.gpg

                # Add VS Code repository
                log_substep "Adding VS Code repository..."
                echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | \
                    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

                # Install VS Code
                log_substep "Installing VS Code..."
                sudo apt update
                sudo apt install -y code
                log_success "VS Code installed"
            fi
        fi
        mark_complete "vscode-installed"
    else
        log_substep "VS Code installation already done"
    fi

    # Discord
    log_step "Installing Discord..."
    if ! check_complete "discord-installed"; then
        if verify_command_exists discord; then
            log_substep "Discord already installed"
        else
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_info "[DRY RUN] Would install Discord"
            else
                install_deb_from_url \
                    "https://discord.com/api/download?platform=linux&format=deb" \
                    "discord"
            fi
        fi
        mark_complete "discord-installed"
    else
        log_substep "Discord installation already done"
    fi

    # Verify
    log_step "Verifying installations..."
    if verify_command_exists google-chrome || verify_command_exists google-chrome-stable; then
        log_success "Google Chrome: installed"
    else
        log_warn "Google Chrome: not found"
    fi

    if verify_command_exists code; then
        log_success "VS Code: installed"
        log_info "Remember to enable Settings Sync in VS Code!"
    else
        log_warn "VS Code: not found"
    fi

    if verify_command_exists discord; then
        log_success "Discord: installed"
    else
        log_warn "Discord: not found"
    fi

    stage_end
}

main "$@"

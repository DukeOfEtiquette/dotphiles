#!/bin/bash
# setup/05-packages-desktop.sh - Desktop environment packages
# Installs: terminal, utilities, and i3 (ts3d profile only)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/verify.sh"

MANIFEST="$SCRIPT_DIR/manifests/packages-desktop.txt"
MANIFEST_I3="$SCRIPT_DIR/manifests/packages-desktop-i3.txt"

main() {
    stage_start "Desktop Packages"

    if check_complete "packages-desktop"; then
        log_info "Desktop packages already installed (skipping)"
        stage_end
        return 0
    fi

    # Install base desktop packages (all profiles)
    log_step "Installing desktop packages..."
    install_apt_packages "$MANIFEST"

    # Install i3 packages (ts3d profile only)
    if [[ "${PROFILE:-}" == "ts3d" ]]; then
        log_step "Installing i3 window manager packages..."
        install_apt_packages "$MANIFEST_I3"
    fi

    # Create required directories
    log_step "Creating user directories..."
    ensure_directory "$HOME/screenshots"
    ensure_directory "$HOME/backgrounds"
    ensure_directory "$HOME/.fonts"

    # Verify installation
    log_step "Verifying installation..."
    stage_verify "xfce4-terminal installed" "verify_command_exists xfce4-terminal"
    stage_verify "xclip installed" "verify_command_exists xclip"
    stage_verify "flameshot installed" "verify_command_exists flameshot"
    stage_verify "tmux installed" "verify_command_exists tmux"

    # Verify i3 (ts3d only)
    if [[ "${PROFILE:-}" == "ts3d" ]]; then
        stage_verify "i3 installed" "verify_command_exists i3"
    fi

    mark_complete "packages-desktop"

    stage_end
}

main "$@"

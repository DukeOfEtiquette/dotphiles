#!/bin/bash
# setup/01-packages-core.sh - Essential apt packages
# Installs: curl, wget, git, git-lfs, etc.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/verify.sh"

MANIFEST="$SCRIPT_DIR/manifests/packages-core.txt"

main() {
    stage_start "Core Packages"

    if check_complete "packages-core"; then
        log_info "Core packages already installed (skipping)"
        stage_end
        return 0
    fi

    # Update apt cache
    log_step "Updating package cache..."
    apt_update

    # Upgrade existing packages
    log_step "Upgrading existing packages..."
    apt_upgrade

    # Install core packages
    log_step "Installing core packages..."
    install_apt_packages "$MANIFEST"

    # Verify installation
    log_step "Verifying installation..."
    stage_verify "git installed" "verify_command_exists git"
    stage_verify "curl installed" "verify_command_exists curl"
    stage_verify "wget installed" "verify_command_exists wget"

    mark_complete "packages-core"

    stage_end
}

main "$@"

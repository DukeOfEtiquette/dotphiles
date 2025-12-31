#!/bin/bash
# setup/04-packages-dev.sh - Development toolchain
# Installs: build-essential, cmake, make, gcc, etc.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/verify.sh"

MANIFEST="$SCRIPT_DIR/manifests/packages-dev.txt"

main() {
    stage_start "Development Packages"

    if check_complete "packages-dev"; then
        log_info "Development packages already installed (skipping)"
        stage_end
        return 0
    fi

    # Install dev packages
    log_step "Installing development packages..."
    install_apt_packages "$MANIFEST"

    # Create Maverick directory structure
    log_step "Creating Maverick directory structure..."
    local rogue_root="${ROGUE_ROOT:-$HOME/rogue}"

    ensure_directory "$rogue_root/src"
    ensure_directory "$rogue_root/builds/debug"
    ensure_directory "$rogue_root/builds/elite/debug"
    ensure_directory "$rogue_root/builds/elite/install"
    ensure_directory "$rogue_root/builds/platinum/debug"
    ensure_directory "$rogue_root/builds/platinum/install"
    ensure_directory "$rogue_root/builds/encore/debug"
    ensure_directory "$rogue_root/builds/encore/install"
    ensure_directory "$rogue_root/builds/mav_tools/animation_maker/cram"

    log_success "Maverick directories created at $rogue_root"

    # Verify installation
    log_step "Verifying installation..."
    stage_verify "cmake installed" "verify_command_exists cmake"
    stage_verify "make installed" "verify_command_exists make"
    stage_verify "g++ installed" "verify_command_exists g++"
    stage_verify "ccmake installed" "verify_command_exists ccmake"

    # Show versions
    verify_command_version "cmake" "--version"
    verify_command_version "make" "--version"
    verify_command_version "g++" "--version"

    mark_complete "packages-dev"

    stage_end
}

main "$@"

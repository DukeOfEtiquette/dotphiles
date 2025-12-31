#!/bin/bash
# setup/00-preflight.sh - System requirements check
# Verifies: Debian version, sudo access, network, disk space

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    stage_start "Preflight Checks"

    # Check we're not running as root
    log_step "Checking user privileges..."
    check_not_root

    # Check sudo access
    log_step "Checking sudo access..."
    check_sudo

    # Check Debian version
    log_step "Checking OS version..."
    local codename
    codename=$(get_debian_codename)
    log_substep "Detected: Debian $codename"

    case "$codename" in
        bullseye|bookworm|trixie)
            log_success "Debian version supported: $codename"
            ;;
        *)
            log_warn "Untested Debian version: $codename (expected bullseye, bookworm, or trixie)"
            if ! prompt_yes_no "Continue anyway?"; then
                exit 1
            fi
            ;;
    esac

    # Check network connectivity
    log_step "Checking network connectivity..."
    check_network

    # Check disk space (10GB minimum)
    log_step "Checking disk space..."
    check_disk_space "$HOME" 10

    # Check essential commands
    log_step "Checking essential commands..."
    local essential_cmds=("bash" "grep" "sed" "awk" "tar")
    local missing=()
    for cmd in "${essential_cmds[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing essential commands: ${missing[*]}"
        log_error "Please install these packages first."
        exit 1
    fi
    log_success "All essential commands available"

    # Mark preflight complete
    mark_complete "preflight"

    stage_end
}

main "$@"

#!/bin/bash
# setup/10-post-install.sh - Post-installation tasks
# Runs: font cache, hardware detection, final verification

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/verify.sh"

main() {
    stage_start "Post-Installation"

    # Refresh font cache
    log_step "Refreshing font cache..."
    if ! check_complete "font-cache"; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY RUN] Would run: fc-cache -fv"
        else
            fc-cache -fv &>/dev/null || true
            log_success "Font cache refreshed"
        fi
        mark_complete "font-cache"
    else
        log_substep "Font cache already refreshed"
    fi

    # Hardware detection
    log_step "Detecting hardware..."

    # Network interfaces
    log_substep "Network interfaces:"
    local wireless_iface
    wireless_iface=$(iw dev 2>/dev/null | grep "Interface" | awk '{print $2}' | head -1 || echo "")
    if [[ -z "$wireless_iface" ]]; then
        wireless_iface=$(ls /sys/class/net/ 2>/dev/null | grep -E '^wl' | head -1 || echo "none")
    fi
    local wired_iface
    wired_iface=$(ls /sys/class/net/ 2>/dev/null | grep -E '^(eth|enp|eno)' | head -1 || echo "none")

    log_info "  Wireless: $wireless_iface"
    log_info "  Wired: $wired_iface"

    if [[ "${PROFILE:-}" == "ts3d" ]] && { [[ "$wireless_iface" != "none" ]] || [[ "$wired_iface" != "none" ]]; }; then
        log_warn "Update i3status config with correct interface names:"
        log_warn "  ~/.config/i3status/config"
    fi

    # Battery (for laptops)
    local battery_path="/sys/class/power_supply/BAT0"
    if [[ -d "$battery_path" ]]; then
        log_info "  Battery: detected (laptop)"
    else
        log_info "  Battery: not detected (desktop)"
    fi

    # Run profile-specific verification script
    log_step "Running profile verification..."

    local dotfiles_root
    dotfiles_root="$(cd "$SCRIPT_DIR/.." && pwd)"
    local verify_script="$dotfiles_root/profiles/${PROFILE}/verify.sh"

    if [[ -f "$verify_script" ]]; then
        chmod +x "$verify_script"
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY RUN] Would run: $verify_script"
        else
            "$verify_script"
        fi
    else
        log_warn "No verify.sh found for profile: $PROFILE"
    fi

    # Display manual verification checklist
    local verify_doc="$dotfiles_root/profiles/${PROFILE}/VERIFY.md"
    if [[ -f "$verify_doc" ]]; then
        echo ""
        echo "============================================"
        echo "  MANUAL VERIFICATION CHECKLIST"
        echo "============================================"
        cat "$verify_doc"
    fi

    mark_complete "post-install"

    stage_end
}

main "$@"

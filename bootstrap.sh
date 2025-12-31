#!/bin/bash
# bootstrap.sh - Entry point for fresh machine setup
# Orchestrates all setup scripts in sequence
#
# Usage:
#   ./bootstrap.sh --profile rogue [--yes] [--stage N] [--dry-run]
#
# Options:
#   --profile, -p   Profile to install (required): rogue, gomez, ts3d
#   --yes, -y       Skip all interactive prompts
#   --stage, -s     Start from stage N (0-10)
#   --dry-run       Show what would be done without making changes
#   --reset         Clear all state and start fresh
#   --help, -h      Show this help message

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$SCRIPT_DIR/setup"

# Default values
PROFILE=""
ASSUME_YES=0
DRY_RUN=0
START_STAGE=0
RESET_STATE=0

# Export for sub-scripts
export ASSUME_YES
export DRY_RUN

# ============================================================================
# Help and Usage
# ============================================================================

usage() {
    cat << 'EOF'
bootstrap.sh - Fresh machine setup for dotfiles

Usage:
  ./bootstrap.sh --profile <profile> [options]

Required:
  --profile, -p <name>   Profile to install: rogue, gomez, ts3d

Options:
  --yes, -y              Skip all interactive prompts (auto-confirm)
  --stage, -s <N>        Start from stage N (0-10, default: 0)
  --dry-run              Show what would be done without changes
  --reset                Clear all state and start fresh
  --help, -h             Show this help message

Stages:
  0  - Preflight checks (OS, sudo, network, disk)
  1  - Core packages (curl, wget, git, etc.)
  2  - Shell (zsh, oh-my-zsh)
  3  - Git config (user, email, SSH key)
  4  - Dev packages (cmake, make, build-essential)
  5  - Desktop packages (terminal, utils; i3 for ts3d only)
  6  - NVM (Node Version Manager)
  7  - Docker
  8  - External apps (Chrome, VSCode, Discord)
  9  - Dotfiles (runs installDotfiles.sh)
  10 - Post-install (font cache, verification)

Examples:
  # Full install with rogue profile
  ./bootstrap.sh --profile rogue

  # Non-interactive install
  ./bootstrap.sh --profile rogue --yes

  # Resume from stage 5
  ./bootstrap.sh --profile rogue --stage 5

  # Preview what would happen
  ./bootstrap.sh --profile rogue --dry-run
EOF
}

# ============================================================================
# Argument Parsing
# ============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -y|--yes)
                ASSUME_YES=1
                shift
                ;;
            -s|--stage)
                START_STAGE="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            --reset)
                RESET_STATE=1
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                usage
                exit 1
                ;;
        esac
    done

    # Validate profile
    if [[ -z "$PROFILE" ]]; then
        echo "ERROR: --profile is required" >&2
        usage
        exit 1
    fi

    case "$PROFILE" in
        rogue|gomez|ts3d)
            ;;
        *)
            echo "ERROR: Invalid profile: $PROFILE" >&2
            echo "Valid profiles: rogue, gomez, ts3d" >&2
            exit 1
            ;;
    esac

    # Export profile for sub-scripts
    export PROFILE
}

# ============================================================================
# Stage Definitions
# ============================================================================

# Array of stage scripts
STAGES=(
    "00-preflight.sh"
    "01-packages-core.sh"
    "02-shell.sh"
    "03-git-config.sh"
    "04-packages-dev.sh"
    "05-packages-desktop.sh"
    "06-nvm.sh"
    "07-docker.sh"
    "08-apps-external.sh"
    "09-dotfiles.sh"
    "10-post-install.sh"
)

# ============================================================================
# Main
# ============================================================================

main() {
    parse_args "$@"

    # Source common library for logging
    source "$SETUP_DIR/lib/common.sh"

    # Banner
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    DOTFILES BOOTSTRAP                        ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  Profile:     $PROFILE"
    printf "║  %-60s ║\n" "Dry Run:      $( [[ $DRY_RUN -eq 1 ]] && echo 'YES' || echo 'no' )"
    printf "║  %-60s ║\n" "Auto-confirm: $( [[ $ASSUME_YES -eq 1 ]] && echo 'YES' || echo 'no' )"
    printf "║  %-60s ║\n" "Start Stage:  $START_STAGE"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    # Reset state if requested
    if [[ $RESET_STATE -eq 1 ]]; then
        log_warn "Clearing all state..."
        clear_all_state
        log_success "State cleared"
    fi

    # Confirm before proceeding (unless --yes)
    if [[ $ASSUME_YES -ne 1 ]] && [[ $DRY_RUN -ne 1 ]]; then
        echo "This script will install packages and configure your system."
        echo ""
        if ! prompt_yes_no "Continue with installation?"; then
            echo "Aborted."
            exit 0
        fi
        echo ""
    fi

    # Run stages
    local stage_num=0
    for stage_script in "${STAGES[@]}"; do
        if [[ $stage_num -lt $START_STAGE ]]; then
            log_info "Skipping stage $stage_num: $stage_script"
            ((++stage_num))
            continue
        fi

        local script_path="$SETUP_DIR/$stage_script"
        if [[ ! -f "$script_path" ]]; then
            log_error "Stage script not found: $script_path"
            exit 1
        fi

        log_info "Running stage $stage_num: $stage_script"

        # Make sure script is executable
        chmod +x "$script_path"

        # Run the stage
        if ! "$script_path"; then
            log_error "Stage $stage_num failed: $stage_script"
            log_error "You can resume from this stage with: --stage $stage_num"
            exit 1
        fi

        ((++stage_num))
    done

    # Final message
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    BOOTSTRAP COMPLETE                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "This was a dry run. No changes were made."
    else
        log_success "Installation complete!"
        echo ""
        echo "See the verification checklist above for next steps."
        echo "You can re-run verification anytime with:"
        echo "  ~/.everc/dotfiles/profiles/$PROFILE/verify.sh"
        echo ""
    fi
}

main "$@"

#!/bin/bash
# setup/lib/common.sh - Core functions for bootstrap setup
# Provides: logging, prompts, idempotency tracking, stage management

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

STATE_DIR="${HOME}/.everc"
STATE_FILE="${STATE_DIR}/.setup-state"
ASSUME_YES="${ASSUME_YES:-0}"
DRY_RUN="${DRY_RUN:-0}"

# ============================================================================
# Colors
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ============================================================================
# Logging
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_step() {
    echo -e "${CYAN}==>${NC} ${BOLD}$*${NC}"
}

log_substep() {
    echo -e "    ${CYAN}->${NC} $*"
}

# ============================================================================
# User Prompts
# ============================================================================

# Prompt for yes/no, respects ASSUME_YES
# Usage: prompt_yes_no "Do you want to continue?"
prompt_yes_no() {
    local msg="$1"
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        log_info "$msg (auto-yes)"
        return 0
    fi
    read -r -p "$msg (y/N) " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Prompt for input with default
# Usage: prompt_input "Enter name" "default_value"
prompt_input() {
    local msg="$1"
    local default="${2:-}"
    local response

    if [[ -n "$default" ]]; then
        read -r -p "$msg [$default]: " response
        echo "${response:-$default}"
    else
        read -r -p "$msg: " response
        echo "$response"
    fi
}

# ============================================================================
# State Management (Idempotency)
# ============================================================================

# Ensure state directory and file exist
init_state() {
    mkdir -p "$STATE_DIR"
    touch "$STATE_FILE"
}

# Mark a step as complete
# Usage: mark_complete "step-name"
mark_complete() {
    local marker="$1"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_info "[DRY RUN] Would mark complete: $marker"
        return 0
    fi
    init_state
    if ! grep -q "^${marker}=" "$STATE_FILE" 2>/dev/null; then
        echo "${marker}=$(date -Iseconds)" >> "$STATE_FILE"
    fi
}

# Check if a step is already complete
# Usage: if check_complete "step-name"; then skip; fi
check_complete() {
    local marker="$1"
    [[ -f "$STATE_FILE" ]] && grep -q "^${marker}=" "$STATE_FILE"
}

# Clear a specific marker (for re-running)
# Usage: clear_marker "step-name"
clear_marker() {
    local marker="$1"
    if [[ -f "$STATE_FILE" ]]; then
        sed -i "/^${marker}=/d" "$STATE_FILE"
    fi
}

# Clear all state (full reset)
clear_all_state() {
    rm -f "$STATE_FILE"
}

# ============================================================================
# Stage Management
# ============================================================================

CURRENT_STAGE=""

# Start a stage
# Usage: stage_start "Installing packages"
stage_start() {
    CURRENT_STAGE="$1"
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BOLD}  $CURRENT_STAGE${NC}"
    echo -e "${BOLD}========================================${NC}"
    echo ""
}

# End a stage with optional verification
# Usage: stage_end
stage_end() {
    echo ""
    log_success "Completed: $CURRENT_STAGE"
    echo ""
}

# Run verification function and report result
# Usage: stage_verify "description" verify_function
stage_verify() {
    local description="$1"
    local verify_fn="$2"

    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_info "[DRY RUN] Would verify: $description"
        return 0
    fi

    log_substep "Verifying: $description"
    if $verify_fn; then
        log_success "Verified: $description"
        return 0
    else
        log_error "Verification failed: $description"
        return 1
    fi
}

# ============================================================================
# Dry Run Support
# ============================================================================

# Execute command or print if dry run
# Usage: run_cmd "description" command args...
run_cmd() {
    local description="$1"
    shift
    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_info "[DRY RUN] Would execute: $*"
    else
        log_substep "$description"
        "$@"
    fi
}

# Execute sudo command or print if dry run
# Usage: run_sudo "description" command args...
run_sudo() {
    local description="$1"
    shift
    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_info "[DRY RUN] Would execute: sudo $*"
    else
        log_substep "$description"
        sudo "$@"
    fi
}

# ============================================================================
# Directory and File Helpers
# ============================================================================

# Ensure directory exists with optional permissions
# Usage: ensure_directory "/path/to/dir" [mode]
ensure_directory() {
    local dir="$1"
    local mode="${2:-}"

    if [[ -d "$dir" ]]; then
        log_substep "Directory exists: $dir"
    else
        run_cmd "Creating directory: $dir" mkdir -p "$dir"
        if [[ -n "$mode" ]] && [[ "$DRY_RUN" -ne 1 ]]; then
            chmod "$mode" "$dir"
        fi
    fi
}

# Ensure symlink exists and points to correct target
# Usage: ensure_symlink "/path/to/target" "/path/to/link"
ensure_symlink() {
    local target="$1"
    local link="$2"

    if [[ -L "$link" ]]; then
        local current_target
        current_target=$(readlink "$link")
        if [[ "$current_target" == "$target" ]]; then
            log_substep "Symlink correct: $link -> $target"
            return 0
        else
            log_warn "Symlink exists but points to wrong target: $link -> $current_target"
            run_cmd "Updating symlink" ln -sf "$target" "$link"
        fi
    elif [[ -e "$link" ]]; then
        log_warn "File exists at symlink location: $link (backing up)"
        run_cmd "Backing up existing file" mv "$link" "${link}.bak"
        run_cmd "Creating symlink" ln -s "$target" "$link"
    else
        run_cmd "Creating symlink: $link -> $target" ln -s "$target" "$link"
    fi
}

# Ensure a line exists in a file
# Usage: ensure_line_in_file "/path/to/file" "line to add"
ensure_line_in_file() {
    local file="$1"
    local line="$2"

    if [[ -f "$file" ]] && grep -qF "$line" "$file"; then
        log_substep "Line already exists in $file"
    else
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY RUN] Would add line to $file: $line"
        else
            echo "$line" >> "$file"
            log_substep "Added line to $file"
        fi
    fi
}

# ============================================================================
# System Checks
# ============================================================================

# Check if running as root (we don't want that)
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run this script as root. Use a regular user with sudo access."
        exit 1
    fi
}

# Check if sudo is available
check_sudo() {
    if ! command -v sudo &>/dev/null; then
        log_error "sudo is not installed. Please install sudo first."
        exit 1
    fi
    if ! sudo -n true 2>/dev/null; then
        log_info "Sudo access required. You may be prompted for your password."
        if ! sudo true; then
            log_error "Failed to obtain sudo access."
            exit 1
        fi
    fi
}

# Check network connectivity
check_network() {
    log_substep "Checking network connectivity..."
    if ping -c 1 -W 5 8.8.8.8 &>/dev/null; then
        log_success "Network is available"
        return 0
    else
        log_error "No network connectivity. Please check your connection."
        return 1
    fi
}

# Check available disk space
# Usage: check_disk_space "/path" min_gb
check_disk_space() {
    local path="$1"
    local min_gb="$2"
    local available_kb
    available_kb=$(df -k "$path" | awk 'NR==2 {print $4}')
    local available_gb=$((available_kb / 1024 / 1024))

    if [[ $available_gb -ge $min_gb ]]; then
        log_success "Disk space OK: ${available_gb}GB available (minimum: ${min_gb}GB)"
        return 0
    else
        log_error "Insufficient disk space: ${available_gb}GB available, need ${min_gb}GB"
        return 1
    fi
}

# Get Debian version codename
get_debian_codename() {
    if [[ -f /etc/os-release ]]; then
        grep "^VERSION_CODENAME=" /etc/os-release | cut -d= -f2
    else
        echo "unknown"
    fi
}

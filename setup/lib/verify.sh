#!/bin/bash
# setup/lib/verify.sh - Verification functions
# Provides: command, file, service, and group verification

# Requires common.sh to be sourced first
if [[ -z "${STATE_DIR:-}" ]]; then
    echo "ERROR: common.sh must be sourced before verify.sh" >&2
    exit 1
fi

# ============================================================================
# Command Verification
# ============================================================================

# Check if a command exists
# Usage: verify_command_exists "git"
verify_command_exists() {
    local cmd="$1"
    command -v "$cmd" &>/dev/null
}

# Check if a command exists and print version
# Usage: verify_command_version "git" "--version"
verify_command_version() {
    local cmd="$1"
    local version_flag="${2:---version}"

    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        log_info "[DRY RUN] Would check version: $cmd $version_flag"
        return 0
    fi

    if command -v "$cmd" &>/dev/null; then
        local version
        version=$("$cmd" "$version_flag" 2>&1 | head -1)
        log_substep "$cmd: $version"
        return 0
    else
        log_error "$cmd not found"
        return 1
    fi
}

# ============================================================================
# File and Directory Verification
# ============================================================================

# Check if a file exists
# Usage: verify_file_exists "/path/to/file"
verify_file_exists() {
    local file="$1"
    [[ -f "$file" ]]
}

# Check if a directory exists
# Usage: verify_directory_exists "/path/to/dir"
verify_directory_exists() {
    local dir="$1"
    [[ -d "$dir" ]]
}

# Check if a symlink exists and points to correct target
# Usage: verify_symlink "/path/to/link" "/path/to/target"
verify_symlink() {
    local link="$1"
    local target="$2"

    [[ -L "$link" ]] && [[ "$(readlink "$link")" == "$target" ]]
}

# Check file permissions
# Usage: verify_file_permissions "/path/to/file" "600"
verify_file_permissions() {
    local file="$1"
    local expected="$2"
    local actual

    if [[ ! -e "$file" ]]; then
        return 1
    fi

    actual=$(stat -c "%a" "$file")
    [[ "$actual" == "$expected" ]]
}

# ============================================================================
# Service Verification
# ============================================================================

# Check if a systemd service is running
# Usage: verify_service_running "docker"
verify_service_running() {
    local service="$1"
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        return 0
    fi
    systemctl is-active --quiet "$service"
}

# Check if a systemd service is enabled
# Usage: verify_service_enabled "docker"
verify_service_enabled() {
    local service="$1"
    systemctl is-enabled --quiet "$service"
}

# ============================================================================
# User and Group Verification
# ============================================================================

# Check if current user is in a group
# Usage: verify_group_membership "docker"
verify_group_membership() {
    local group="$1"
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        return 0
    fi
    groups "$USER" 2>/dev/null | grep -qw "$group"
}

# Check if a user exists
# Usage: verify_user_exists "username"
verify_user_exists() {
    local user="$1"
    id "$user" &>/dev/null
}

# ============================================================================
# Shell Verification
# ============================================================================

# Check if zsh is the default shell
verify_zsh_default() {
    local user_shell
    user_shell=$(getent passwd "$USER" | cut -d: -f7)
    [[ "$user_shell" == *"zsh"* ]]
}

# Check if oh-my-zsh is installed
verify_omz_installed() {
    [[ -d "$HOME/.oh-my-zsh" ]]
}

# ============================================================================
# Git Verification
# ============================================================================

# Check if git user.name is configured
verify_git_user_name() {
    git config --global user.name &>/dev/null
}

# Check if git user.email is configured
verify_git_user_email() {
    git config --global user.email &>/dev/null
}

# Check if SSH key exists
verify_ssh_key() {
    [[ -f "$HOME/.ssh/id_ed25519" ]] || [[ -f "$HOME/.ssh/id_rsa" ]]
}

# ============================================================================
# Network Verification
# ============================================================================

# Check if a port is listening
# Usage: verify_port_listening 8080
verify_port_listening() {
    local port="$1"
    ss -tuln | grep -q ":$port "
}

# Check if a URL is reachable
# Usage: verify_url_reachable "https://example.com"
verify_url_reachable() {
    local url="$1"
    curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "^[23]"
}

# ============================================================================
# Aggregate Verification
# ============================================================================

# Run all verification checks for a list of commands
# Usage: verify_commands "git" "curl" "wget"
verify_commands() {
    local all_ok=true
    for cmd in "$@"; do
        if verify_command_exists "$cmd"; then
            log_success "Found: $cmd"
        else
            log_error "Missing: $cmd"
            all_ok=false
        fi
    done
    $all_ok
}

# Run all verification checks for a list of files
# Usage: verify_files "/path/to/file1" "/path/to/file2"
verify_files() {
    local all_ok=true
    for file in "$@"; do
        if verify_file_exists "$file"; then
            log_success "Found: $file"
        else
            log_error "Missing: $file"
            all_ok=false
        fi
    done
    $all_ok
}

# Run all verification checks for a list of directories
# Usage: verify_directories "/path/to/dir1" "/path/to/dir2"
verify_directories() {
    local all_ok=true
    for dir in "$@"; do
        if verify_directory_exists "$dir"; then
            log_success "Found: $dir"
        else
            log_error "Missing: $dir"
            all_ok=false
        fi
    done
    $all_ok
}

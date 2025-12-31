#!/bin/bash
# setup/lib/packages.sh - Package management helpers
# Provides: apt package installation, deb installation, repository management

# Requires common.sh to be sourced first
if [[ -z "${STATE_DIR:-}" ]]; then
    echo "ERROR: common.sh must be sourced before packages.sh" >&2
    exit 1
fi

# ============================================================================
# APT Package Management
# ============================================================================

# Check if an apt package is installed
# Usage: is_package_installed "package-name"
is_package_installed() {
    local package="$1"
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
}

# Install apt packages from a manifest file
# Manifest format: one package per line, # for comments, empty lines ignored
# Usage: install_apt_packages "/path/to/manifest.txt"
install_apt_packages() {
    local manifest="$1"
    local packages_to_install=()

    if [[ ! -f "$manifest" ]]; then
        log_error "Manifest file not found: $manifest"
        return 1
    fi

    # Read manifest, skip comments and empty lines
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        # Skip empty lines and comments
        [[ -z "$line" || "$line" == \#* ]] && continue

        if ! is_package_installed "$line"; then
            packages_to_install+=("$line")
        else
            log_substep "Already installed: $line"
        fi
    done < "$manifest"

    if [[ ${#packages_to_install[@]} -eq 0 ]]; then
        log_success "All packages from $manifest already installed"
        return 0
    fi

    log_step "Installing ${#packages_to_install[@]} packages..."
    for pkg in "${packages_to_install[@]}"; do
        log_substep "Will install: $pkg"
    done

    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_info "[DRY RUN] Would run: sudo apt install -y ${packages_to_install[*]}"
    else
        sudo apt install -y "${packages_to_install[@]}"
    fi
}

# Install a single apt package
# Usage: install_apt_package "package-name"
install_apt_package() {
    local package="$1"

    if is_package_installed "$package"; then
        log_substep "Already installed: $package"
        return 0
    fi

    run_sudo "Installing $package" apt install -y "$package"
}

# Update apt cache
apt_update() {
    run_sudo "Updating apt cache" apt update
}

# Upgrade all packages
apt_upgrade() {
    run_sudo "Upgrading packages" apt upgrade -y
}

# ============================================================================
# Debian Package Installation
# ============================================================================

# Download and install a .deb file from URL
# Usage: install_deb_from_url "https://example.com/package.deb" "package-name"
install_deb_from_url() {
    local url="$1"
    local package_name="$2"
    local temp_deb="/tmp/${package_name}.deb"

    # Check if already installed (by command or package name)
    if command -v "$package_name" &>/dev/null; then
        log_substep "Already installed: $package_name"
        return 0
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_info "[DRY RUN] Would download: $url"
        log_info "[DRY RUN] Would install: $temp_deb"
        return 0
    fi

    log_substep "Downloading $package_name..."
    if ! wget -q -O "$temp_deb" "$url"; then
        log_error "Failed to download: $url"
        return 1
    fi

    log_substep "Installing $package_name..."
    if ! sudo apt install -y "$temp_deb"; then
        log_error "Failed to install: $temp_deb"
        rm -f "$temp_deb"
        return 1
    fi

    rm -f "$temp_deb"
    log_success "Installed: $package_name"
}

# ============================================================================
# Repository Management
# ============================================================================

# Add an APT repository with GPG key
# Usage: add_apt_repository "repo-name" "key-url" "repo-line" "keyring-path"
add_apt_repository() {
    local name="$1"
    local key_url="$2"
    local repo_line="$3"
    local keyring_path="$4"
    local sources_file="/etc/apt/sources.list.d/${name}.list"

    if [[ -f "$sources_file" ]]; then
        log_substep "Repository already configured: $name"
        return 0
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        log_info "[DRY RUN] Would add repository: $name"
        log_info "[DRY RUN] Key URL: $key_url"
        log_info "[DRY RUN] Repo line: $repo_line"
        return 0
    fi

    log_substep "Adding GPG key for $name..."
    curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring_path"

    log_substep "Adding repository: $name..."
    echo "$repo_line" | sudo tee "$sources_file" > /dev/null

    log_substep "Updating apt cache..."
    sudo apt update

    log_success "Added repository: $name"
}

# ============================================================================
# Version Checking
# ============================================================================

# Compare version strings
# Returns: 0 if v1 >= v2, 1 otherwise
# Usage: version_gte "1.2.3" "1.2.0"
version_gte() {
    local v1="$1"
    local v2="$2"
    printf '%s\n%s\n' "$v2" "$v1" | sort -V -C
}

# Get installed version of a package
# Usage: get_package_version "package-name"
get_package_version() {
    local package="$1"
    dpkg -l "$package" 2>/dev/null | awk '/^ii/ {print $3}'
}

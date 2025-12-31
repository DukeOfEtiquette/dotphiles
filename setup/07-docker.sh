#!/bin/bash
# setup/07-docker.sh - Docker CE installation
# Installs: Docker CE, adds user to docker group

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/verify.sh"

main() {
    stage_start "Docker"

    # Check if Docker is already installed
    log_step "Checking Docker installation..."
    if check_complete "docker-installed" && verify_command_exists docker; then
        log_info "Docker already installed (skipping installation)"
    else
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY RUN] Would install Docker CE"
        else
            # Remove old versions if present
            log_substep "Removing old Docker versions (if any)..."
            sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

            # Install prerequisites
            log_substep "Installing prerequisites..."
            sudo apt install -y ca-certificates curl gnupg

            # Add Docker's official GPG key
            log_substep "Adding Docker GPG key..."
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            sudo chmod a+r /etc/apt/keyrings/docker.gpg

            # Add the repository
            log_substep "Adding Docker repository..."
            local codename
            codename=$(get_debian_codename)
            echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
                $codename stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Install Docker
            log_substep "Installing Docker CE..."
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

            log_success "Docker installed"
        fi
        mark_complete "docker-installed"
    fi

    # Add user to docker group
    log_step "Configuring Docker group..."
    if ! check_complete "docker-group"; then
        if verify_group_membership "docker"; then
            log_substep "User already in docker group"
        else
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_info "[DRY RUN] Would add $USER to docker group"
            else
                log_substep "Adding $USER to docker group..."
                sudo usermod -aG docker "$USER"
                log_success "Added $USER to docker group"
                log_warn "You must log out and back in for docker group to take effect"
            fi
        fi
        mark_complete "docker-group"
    fi

    # Enable and start Docker service
    log_step "Enabling Docker service..."
    if ! check_complete "docker-service"; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY RUN] Would enable and start Docker service"
        else
            sudo systemctl enable docker
            sudo systemctl start docker
            log_success "Docker service enabled and started"
        fi
        mark_complete "docker-service"
    fi

    # Verify
    log_step "Verifying installation..."
    stage_verify "docker installed" "verify_command_exists docker"
    verify_command_version "docker" "--version"

    if verify_service_running "docker"; then
        log_success "Docker service is running"
    else
        log_warn "Docker service is not running"
    fi

    if verify_group_membership "docker"; then
        log_success "User is in docker group"
    else
        log_warn "User not yet in docker group (requires logout/login)"
    fi

    stage_end
}

main "$@"

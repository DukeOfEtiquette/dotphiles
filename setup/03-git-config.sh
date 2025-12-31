#!/bin/bash
# setup/03-git-config.sh - Git user configuration and SSH key generation
# Configures: git user.name, user.email, generates SSH key

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/verify.sh"

main() {
    stage_start "Git Configuration"

    # Configure git user.name
    log_step "Configuring git user.name..."
    if ! check_complete "git-user-name"; then
        local current_name
        current_name=$(git config --global user.name 2>/dev/null || echo "")

        if [[ -n "$current_name" ]]; then
            log_substep "Already configured: $current_name"
        else
            if [[ "$ASSUME_YES" -eq 1 ]]; then
                log_warn "Git user.name not configured and --yes flag set"
                log_warn "Please configure manually: git config --global user.name 'Your Name'"
            else
                local name
                name=$(prompt_input "Enter your full name for git commits" "")
                if [[ -n "$name" ]]; then
                    if [[ "$DRY_RUN" -eq 1 ]]; then
                        log_info "[DRY RUN] Would set git user.name: $name"
                    else
                        git config --global user.name "$name"
                        log_success "Set git user.name: $name"
                    fi
                else
                    log_warn "Skipped git user.name configuration"
                fi
            fi
        fi
        mark_complete "git-user-name"
    fi

    # Configure git user.email
    log_step "Configuring git user.email..."
    if ! check_complete "git-user-email"; then
        local current_email
        current_email=$(git config --global user.email 2>/dev/null || echo "")

        if [[ -n "$current_email" ]]; then
            log_substep "Already configured: $current_email"
        else
            if [[ "$ASSUME_YES" -eq 1 ]]; then
                log_warn "Git user.email not configured and --yes flag set"
                log_warn "Please configure manually: git config --global user.email 'you@example.com'"
            else
                local email
                email=$(prompt_input "Enter your email for git commits" "")
                if [[ -n "$email" ]]; then
                    if [[ "$DRY_RUN" -eq 1 ]]; then
                        log_info "[DRY RUN] Would set git user.email: $email"
                    else
                        git config --global user.email "$email"
                        log_success "Set git user.email: $email"
                    fi
                else
                    log_warn "Skipped git user.email configuration"
                fi
            fi
        fi
        mark_complete "git-user-email"
    fi

    # Set other useful git defaults
    log_step "Setting git defaults..."
    if ! check_complete "git-defaults"; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            log_info "[DRY RUN] Would set git defaults:"
            log_info "[DRY RUN]   init.defaultBranch = master"
            log_info "[DRY RUN]   pull.rebase = false"
            log_info "[DRY RUN]   core.editor = vim"
        else
            git config --global init.defaultBranch master
            git config --global pull.rebase false
            git config --global core.editor vim
            log_substep "Set default branch: master"
            log_substep "Set pull strategy: merge (no rebase)"
            log_substep "Set editor: vim"
        fi
        mark_complete "git-defaults"
    fi

    # Generate SSH key
    log_step "Checking SSH key..."
    if ! check_complete "ssh-key-generated"; then
        if verify_ssh_key; then
            log_substep "SSH key already exists"
            if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
                log_info "Public key:"
                cat "$HOME/.ssh/id_ed25519.pub"
            elif [[ -f "$HOME/.ssh/id_rsa.pub" ]]; then
                log_info "Public key:"
                cat "$HOME/.ssh/id_rsa.pub"
            fi
        else
            if [[ "$DRY_RUN" -eq 1 ]]; then
                log_info "[DRY RUN] Would generate SSH key"
            else
                log_substep "Generating SSH key (ed25519)..."
                mkdir -p "$HOME/.ssh"
                chmod 700 "$HOME/.ssh"

                local email
                email=$(git config --global user.email 2>/dev/null || echo "$USER@$(hostname)")

                ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""
                chmod 600 "$HOME/.ssh/id_ed25519"
                chmod 644 "$HOME/.ssh/id_ed25519.pub"

                log_success "SSH key generated"
                echo ""
                log_info "Add this public key to GitHub/GitLab:"
                echo ""
                cat "$HOME/.ssh/id_ed25519.pub"
                echo ""

                if [[ "$ASSUME_YES" -ne 1 ]]; then
                    read -r -p "Press Enter to continue after adding the key to GitHub... "
                fi
            fi
        fi
        mark_complete "ssh-key-generated"
    fi

    # Verify
    log_step "Verifying configuration..."
    if verify_git_user_name; then
        log_success "git user.name: $(git config --global user.name)"
    else
        log_warn "git user.name not configured"
    fi

    if verify_git_user_email; then
        log_success "git user.email: $(git config --global user.email)"
    else
        log_warn "git user.email not configured"
    fi

    stage_end
}

main "$@"

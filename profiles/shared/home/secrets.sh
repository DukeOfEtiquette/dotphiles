#!/bin/bash
###############################################################################
# secrets.sh - Secure secrets loader for dotfiles
#
# This script sources secrets from the dotfiles secrets directory.
# It loads shared secrets first, then profile-specific secrets.
#
# Usage: Source this file from your shell rc file:
#   source "$DOTFILES/profiles/shared/home/secrets.sh"
#
# Secrets are loaded from:
#   1. $DOTFILES/secrets/.env           (shared across all profiles)
#   2. $DOTFILES/secrets/.env.$PROFILE  (profile-specific)
###############################################################################

# Determine dotfiles location (use existing var or default)
_DOTFILES="${DOTFILES:-$HOME/.everc/dotfiles}"

# Determine profile (use existing var)
_PROFILE="${DOTPROFILE:-}"

# Secrets directory
_SECRETS_DIR="$_DOTFILES/secrets"

# Function to safely source an env file
_source_env_file() {
    local env_file="$1"
    if [[ -f "$env_file" ]]; then
        # Check file permissions - refuse to load if too permissive
        local perms
        perms=$(stat -c "%a" "$env_file" 2>/dev/null || stat -f "%OLp" "$env_file" 2>/dev/null)
        if [[ "$perms" != "600" && "$perms" != "400" ]]; then
            echo "[secrets.sh] REFUSING to load $env_file - permissions too open ($perms)" >&2
            echo "[secrets.sh] Fix with: chmod 600 $env_file" >&2
            return 1
        fi

        # Source the file, exporting each variable
        set -a  # automatically export all variables
        source "$env_file"
        set +a
        return 0
    fi
    return 1
}

# Load shared secrets
_source_env_file "$_SECRETS_DIR/.env"

# Load profile-specific secrets
if [[ -n "$_PROFILE" ]]; then
    _source_env_file "$_SECRETS_DIR/.env.$_PROFILE"
fi

# Cleanup internal variables
unset _DOTFILES _PROFILE _SECRETS_DIR
unset -f _source_env_file

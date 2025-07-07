#!/bin/bash
set -euo pipefail

usage() {
    echo "Usage: $0 [--yes]" >&2
    echo "  --yes   run without interactive prompts" >&2
    exit "$1"
}

ASSUME_YES=0
while [ $# -gt 0 ]; do
    case "$1" in
        -y|--yes)
            ASSUME_YES=1
            shift
            ;;
        -h|--help)
            usage 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage 1
            ;;
    esac
done

prompt() {
    local msg="$1"
    if [ "$ASSUME_YES" -eq 1 ]; then
        echo "$msg (auto yes)"
        return 0
    fi
    read -r -p "$msg (y/N) " response
    [ "$response" = "y" ]
}

echo "***WARNING*** this script will install packages and may modify your system***"

if prompt "Would you like to HALT execution?"; then
    exit 1
fi

mkdir -p "$HOME/screenshots"

if prompt "Install dircolors?"; then
    mkdir /tmp/LS_COLORS
    curl -L https://api.github.com/repos/trapd00r/LS_COLORS/tarball/master | tar xzf - --directory=/tmp/LS_COLORS --strip=1
    ( cd /tmp/LS_COLORS && sh install.sh )
fi

if prompt "Install greatest hits Debian packages?"; then
    sudo apt update
    sudo apt install -y git git-lfs cifs-utils arandr xfce4-terminal xclip maim flameshot xdotool pavucontrol bat tmux
fi

if prompt "Install Docker?"; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    sudo usermod -aG docker "$USER"
    echo "!!!ATTENTION!!! Docker will require a system restart!"
fi

if prompt "Install nvm?"; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
fi

if prompt "Install Slack?"; then
    wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb
    sudo apt install -y ./slack-desktop-4.0.2-amd64.deb
    rm ./slack-desktop-4.0.2-amd64.deb
fi

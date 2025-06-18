#!/bin/bash

echo "***WARNING*** this script is not well tested, review before continuing"

read -p "Would you like to HALT execution? (y/N) " response
if [ "$response" = "y" ]; then
    exit 1
fi

# make sure store for screenshots is created
mkdir -p $HOME/screenshots

# install dircolors
read -p "Install dircolors? (y/N) " response
if [ "$response" = "y" ]; then
    echo "DIRCOLORS IN"
    # mkdir /tmp/LS_COLORS && curl -L https://api.github.com/repos/trapd00r/LS_COLORS/tarball/master | tar xzf - --directory=/tmp/LS_COLORS --strip=1 && ( cd /tmp/LS_COLORS && sh install.sh )
else
    echo "no dircolors"
fi

# debian installs
read -p "Install greatest hits Debian packages? (y/N) " response
if [ "$response" = "y" ]; then
    echo "DEBIAN INSTALLS"
    # sudo apt update && sudo apt install git git-lfs cifs-utils arandr xfce4-terminal xclip maim flameshot xdotool pavucontrol bat tmux
else
    echo "no debian"
fi

# download Docker
read -p "Install Docker? (y/N) " response
if [ "$response" = "y" ]; then
    echo "DACKER BABY"
    # curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh && rm get-docker.sh && sudo usermod -aG docker $USER
    echo "!!!ATTENTION!!! Docker will require a system restart!"
else
    echo "no dacker : ("
fi

# install nvm
read -p "Install nvm? (y/N) " response
if [ "$response" = "y" ]; then
    echo "NVM TIME"
    # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
else
    echo "no nvm"
fi

# install slack
read -p "Install Slack? (y/N) " response
if [ "$response" = "y" ]; then
    echo "SLACKIN OFF AMIRITE"
    # wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb && sudo apt install ./slack-desktop-*.deb && rm ./slack-desktop-*.deb
else
    echo "no slackin off"
fi
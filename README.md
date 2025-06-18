# dotfiles

## Set up new machine

Take the following steps to set up a new machine from scratch:

1. [Start here](#start-here) (install Linux OS and desktop environment)
1. [Install standard debian packages](#standard-debian-package-installs)
1. [Install shell](#install-shell)
1. [Download/install Dotfiles project](#install-dotfiles)
1. [Download/install additional tools](#additional-tools) not available in `apt`
1. [Review tips 'n' tricks](#useful-linux-tips-n-tricks)

   - **NOTE:** You may want to checkout any `onetimeInstalls.sh` scripts found in a profile

### Start here

[Lubuntu+i3wm tutorial](https://feeblenerd.blogspot.com/2016/08/walkthrough-for-lubuntu-with-i3-tiling.html)


### Standard debian package installs

$ `sudo apt update && sudo apt install git git-lfs cifs-utils arandr xfce4-terminal xclip maim flameshot xdotool pavucontrol bat tmux`

  - **xfce4-terminal** terminal emulator of choice

  - **arandr** GUI for resolution/display configurations (generates xrandr commands)

  - **cifs-utils** required to mount drives in Berkeley

  - **xclip** allows CLI to clipboard selections, useful copying stdout

  - **maim** screenshots

  - **flameshot** screenshoots as well

  - **xdotool** programmatically simulate keyboard input and mouse activity

  - **pavucontrol** graphical volume control

  - **bat** better than cat

  - **tmux** terminal multiplexer

### Install shell

1. Follow instructions on [zsh wiki](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)

1. Follow instructions on [ohmyzsh wiki](https://github.com/ohmyzsh/ohmyzsh/wiki)

$ `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

### Install dotfiles

1. $ `git clone https://github.com/DukeOfEtiquette/dotfiles.git && cd dotfiles`

1. $ `mkdir -p ~/screenshots`
   - Review `$HOME/.config/i3/config`, there are system bindings for taking screenshots

**DEPRECATED**

LS_COLORS script now part of repo, just if it needs updated but no need to install.

1. Install [.dircolors](https://github.com/trapd00r/LS_COLORS#installation)

   - $ `mkdir /tmp/LS_COLORS && curl -L https://api.github.com/repos/trapd00r/LS_COLORS/tarball/master | tar xzf - --directory=/tmp/LS_COLORS --strip=1 && ( cd /tmp/LS_COLORS && sh install.sh )`
   - You may want to checkout any `onetimeInstalls.sh` scripts found in a profile

1. Verify `installDotfiles` is setup properly and run: `./installDotfiles --profile gomez`

1. $ `source ~/.zshrc`

## Additional Tools

### Chrome

[Chrome](https://www.google.com/chrome/)

### VSCode

[VSCode](https://code.visualstudio.com/download)

**Turn on Settings Sync!**

### Slack

[Slack](https://linuxize.com/post/how-to-install-slack-on-ubuntu-18-04/)

### Docker

[docker](https://github.com/docker/docker-install)

**RUN THIS** `sudo usermod -a -G docker $USER`

**Logout after adding user to the docker group**

### Node

[nvm](https://github.com/nvm-sh/nvm)

`curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash`

### Dunst

Custom notification window (comes with Lubuntu)

[Dunst](https://dunst-project.org/documentation/)

## Useful Linux tips 'n' tricks

### Create new linux user

---
**NOTE**

For a new user, you must run the oh-my-zsh and dircolors install before running this installDotfiles.sh!

---

For this example, let us assume we are adding a new user named `spare`

1. Create the user: `sudo adduser spare`

1. Add to sudo group: `sudo usermod -a -G sudo spare`

1. Log into new user: `su - spare`

1. Install oh-my-zsh for user

   - $ `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

1. Install dircolors for user

   - `mkdir -p $HOME/.local/share && ( cd /tmp/LS_COLORS && sh install.sh )`

1. Clone this repo

   - $ `git clone https://github.com/DukeOfEtiquette/dotfiles.git && cd dotfiles`

1. Install dotfiles

   - $ `./installDotfiles.sh && source ~/.zshrc`

### Rename linux user

For this example, let us assume the following old and new user names:

- **old user name:** alpha
- **new user name:** beta

1. Update user's name

   - $ `sudo usermod -l beta alpha`

1. Update user's group name

   - $ `sudo groupmod --new-name beta alpha`

### Delete linux user

For this example, let us assume we are deleting the user named `spare`

1. Ensure you are logged into a user that is not the one intended for removal

1. Kill running processes: $ `sudo killall -u spare`

1. Delete and remove home directory: $ `sudo userdel -r spare`

### Get wifi device name for i3status

`iw dev | grep "Interface" | awk -F ' ' '{print $2}'`

### Connect to wifi with NetworkManager TUI

`nmtui`

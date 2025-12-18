#!/bin/bash
set -euo pipefail
###############################################################################
# ./installDotfiles
#
# This script will:
#    1) Backup all relevant dotfiles
#    2) Install dotfiles of given --profile
#
# The script is broken into 3 main parts, in this order:
#    1) Setup
#    2) Helper functions
#        - Each is responisble for backing up and installing a set of dotfiles
#    3) Entry Point
###############################################################################

### <SETUP> ###

# Dry-run mode (set via --dry-run flag)
DRY_RUN=false

# Check required dependencies
check_dependencies() {
  local missing=()
  local deps=(notify-send)

  for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "WARNING: Missing optional dependencies: ${missing[*]}"
    echo "Some features may not work correctly."
  fi
}

# make sure we are in the right place
personal_dir=$HOME/.everc
cd "$personal_dir/dotfiles"

# Parse arguments
profile=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile)
      profile="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      echo "=== DRY RUN MODE - No changes will be made ==="
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 --profile <profile_name> [--dry-run]"
      exit 1
      ;;
  esac
done

# Validate profile
valid_profiles="gomez rogue ts3d"
if [ -z "$profile" ]; then
  echo "ERROR: --profile is required"
  echo "Usage: $0 --profile <profile_name> [--dry-run]"
  echo "Valid profiles: $valid_profiles"
  exit 1
fi

if ! echo "$valid_profiles" | grep -w -q "$profile"; then
  echo "UNKNOWN PROFILE: $profile"
  echo "Valid profiles: $valid_profiles"
  exit 1
fi

# Run dependency check
check_dependencies

# profile directory, holds all dotfiles for a particular profile
profile_dir="$personal_dir/dotfiles/profiles/$profile"

# shared dotfiles directory, holds dotfiles shared by all profiles
shared_dotfile_dir="$personal_dir/dotfiles/profiles/shared"

# dotfiles backup directory, backup is run during each install
backup_olddir="$personal_dir/dotfiles_bck/profiles/$profile"

# shared dotfiles directory, backup is run during each install
shared_backup_dir="$personal_dir/dotfiles_bck/profiles/shared"

### </SETUP> ###



### <HELPER_FUNCTIONS> ###

# This function sets up the secrets directory structure
function setup_secrets () {
  printf "### SETTING UP SECRETS DIRECTORY ###\n"

  local secrets_dir="$personal_dir/dotfiles/secrets"

  # Create secrets directory if it doesn't exist
  mkdir -p "$secrets_dir"

  # Create .env file if it doesn't exist
  if [[ ! -f "$secrets_dir/.env" ]]; then
    touch "$secrets_dir/.env"
    chmod 600 "$secrets_dir/.env"
    printf "Created $secrets_dir/.env (add your shared secrets here)\n"
  fi

  # Create profile-specific secrets file if it doesn't exist
  if [[ ! -f "$secrets_dir/.env.$profile" ]]; then
    touch "$secrets_dir/.env.$profile"
    chmod 600 "$secrets_dir/.env.$profile"
    printf "Created $secrets_dir/.env.$profile (add profile-specific secrets here)\n"
  fi

  printf "### SECRETS SETUP COMPLETE ###\n"
}

# This function installs background images
function install_backgrounds () {
  printf "### INSTALLING BACKGROUNDS ###\n"
  if $DRY_RUN; then echo "[dry-run] Would install backgrounds"; return; fi

  # make backup of backgrounds dir
  mkdir -p "$shared_backup_dir/backgrounds"
  mkdir -p "$HOME/backgrounds"

  # MOVE everything that is a background to backup location
  if [[ -n "$(ls -A "$HOME/backgrounds" 2>/dev/null)" ]]; then
    mv "$HOME/backgrounds"/* "$shared_backup_dir/backgrounds/"
  fi

  # copy target backgrounds to system
  cp "$shared_dotfile_dir/backgrounds"/* "$HOME/backgrounds"
}

# This function installs oh-my-zsh themes
function install_omz () {
  printf "### INSTALLING OMZ THEMES ###\n"
  if $DRY_RUN; then echo "[dry-run] Would install OMZ themes"; return; fi

  # make backup of OMZ themes
  mkdir -p "$shared_backup_dir/omz_themes/theme"

  # MOVE everything that is a theme to backup location
  if [[ -n "$(ls "$HOME/.oh-my-zsh/themes"/*.zsh-theme 2>/dev/null)" ]]; then
    cp "$HOME/.oh-my-zsh/themes"/*.zsh-theme "$shared_backup_dir/omz_themes/"
  fi

  # copy target OMZ themes to system
  cp "$shared_dotfile_dir/omz_themes"/* "$HOME/.oh-my-zsh/themes/"
}

# This function creates symlinks from the home directory to dotfiles
function install_homedir () {
  printf "### INSTALLING HOME DOTFILES ###\n"
  if $DRY_RUN; then echo "[dry-run] Would install home dotfiles"; return; fi

  # create dotfiles_old in homedir
  # printf "Creating $backup_olddir/home for backup"
  mkdir -p "$backup_olddir/home"
  # printf "...done\n\n"

  # move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
  for file in "$profile_dir/home"/* ; do
    basename_file="$(basename "$file")"

    # printf "Moving $HOME/.$file to $backup_olddir/home \n"
    if [[ -e "$HOME/.$basename_file" ]]; then
      mv "$HOME/.$basename_file" "$backup_olddir/home"
    fi
    # printf "Creating symlink to $file in home directory.\n"
    ln -s "$file" "$HOME/.$basename_file"
  done
}

# This function installs i3 and i3status configs
function install_i3config () {
  printf "### INSTALLING i3 CONFIG ###\n"
  if $DRY_RUN; then echo "[dry-run] Would install i3 configs"; return; fi

  mkdir -p "$backup_olddir/.config/i3"
  mkdir -p "$HOME/.config/i3"

  mkdir -p "$backup_olddir/.config/i3status"
  mkdir -p "$HOME/.config/i3status"

  # MOVE anything in system .config that starts with 'i3' to backup
  if [[ -f "$HOME/.config/i3/config" ]]; then
    mv "$HOME/.config/i3/config" "$backup_olddir/.config/i3/"
  fi
  if [[ -f "$HOME/.config/i3status/config" ]]; then
    mv "$HOME/.config/i3status/config" "$backup_olddir/.config/i3status/"
  fi

  # copy i3 config from shared, i3status from profile
  cp -r "$shared_dotfile_dir/.config/i3"/* "$HOME/.config/i3/"
  cp -r "$profile_dir/.config/i3status"/* "$HOME/.config/i3status/"
}

# This function installs dunst configuration
function install_dunst () {
  printf "### INSTALLING DUNST CONFIG ###\n"
  if $DRY_RUN; then echo "[dry-run] Would install dunst config"; return; fi

  # backup current config
  mkdir -p "$backup_olddir/.config/dunst"
  mkdir -p "$HOME/.config/dunst"

  cp -r "$HOME/.config/dunst" "$backup_olddir/.config/"

  # install new config
  cp -r "$profile_dir/.config/dunst"/* "$HOME/.config/dunst/"
}

# This function installs custom fonts
function install_fonts () {
  printf "### INSTALLING FONTS ###\n"
  if $DRY_RUN; then echo "[dry-run] Would install fonts"; return; fi

  mkdir -p "$backup_olddir/.fonts"
  mkdir -p "$HOME/.fonts/"

  # MOVE any TTF in system .fonts
  if [[ -n "$(ls "$HOME/.fonts"/*.ttf 2>/dev/null)" ]]; then
    mv "$HOME/.fonts"/*.ttf "$backup_olddir/.fonts/"
  fi

  # copy these Linux .font
  cp -r "$profile_dir/.fonts"/*.ttf "$HOME/.fonts/"
}

# This function installs XFCE terminal config
function install_terminal () {
  printf "### INSTALLING xfce4-terminal CONFIG ###\n"
  if $DRY_RUN; then echo "[dry-run] Would install terminal config"; return; fi

  mkdir -p "$backup_olddir/.config/xfce4/terminal"
  mkdir -p "$HOME/.config/xfce4/terminal"

  # MOVE existing terminal config to backup
  if [[ -f "$HOME/.config/xfce4/terminal/terminalrc" ]]; then
    mv "$HOME/.config/xfce4/terminal/terminalrc" "$backup_olddir/.config/xfce4/terminal/terminalrc"
  fi

  # copy these Linux i3 .config to system
  cp "$profile_dir/.config/xfce4/terminal/terminalrc" "$HOME/.config/xfce4/terminal/"
}

# This function installs bin scripts
function install_home_bin () {
  printf "### INSTALLING BIN SCRIPTS ###\n"
  if $DRY_RUN; then echo "[dry-run] Would install bin scripts"; return; fi

  mkdir -p "$backup_olddir/bin"
  mkdir -p "$HOME/bin"

  # MOVE anything in $HOME/bin to backup/bin
  cp -ar "$HOME/bin" "$backup_olddir/"

  # copy these ./bin files to $HOME/bin
  cp -ar "$profile_dir/bin" "$HOME/"
  # sudo cp $profile_dir/bin/backup.sh /etc/init.d/backup
}

# This function runs all installation steps
function install_all () {
  printf "### INSTALLATION STARTING ###\n"

  # setup secrets directory first
  setup_secrets

  # shared configs
  install_backgrounds
  install_omz

  # profile-specific configs
  install_homedir
  install_i3config
  install_dunst
  install_fonts
  install_terminal
  install_home_bin

  printf "### INSTALLATION COMPLETE ###\n"
}

### </HELPER_FUNCTIONS> ###



### <ENTRY_POINT> ###

install_all && notify-send -t 2000 "dotfile install" "installation complete"

### </ENTRY_POINT> ###

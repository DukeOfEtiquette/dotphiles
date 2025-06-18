#!/bin/bash
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

# make sure we are in the right place
personal_dir=$HOME/.everc
cd "$personal_dir/dotfiles"

# --profile is required
if [ "$1" = "--profile" ]; then
  valid_profiles="gomez rogue"
  echo $valid_profiles | grep -w -q $2
  if [ $? -eq 0 ]; then
    profile=$2
  else
    echo "UNKNOWN PROFILE - cannot determine appropriate profile to install"
    echo "value of --profile: $2"
    echo "valid profile options: $valid_profiles"
    echo "Halt execution."
    exit 1
  fi
fi

# double check we have a valid profile
if [ -z "$profile" ]; then
  echo "UNKNOWN PROFILE - make sure you are using --profile!!!"
  echo "Halt execution."
  exit 1
fi

# profile directory, holds all dotfiles for a particular profile
profile_dir=$personal_dir/dotfiles/profiles/$profile

# shared dotfiles directory, holds dotfiles shared by all profiles
shared_dotfile_dir=$personal_dir/dotfiles/profiles/shared

# dotfiles backup directory, backup is run during each install
backup_olddir=$personal_dir/dotfiles_bck/profiles/$profile

# shared dotfiles directory, backup is run during each install
shared_backup_dir=$personal_dir/dotfiles_bck/profiles/shared

### </SETUP> ###



### <HELPER_FUNCTIONS> ###

# This function is responsible for backing up any images used for desktop backgrounds
function backup_backgrounds () {
  printf "### STARTING BACKGROUNDS BACKUP ###\n"

  # make backup of backgrounds dir
  mkdir -p $shared_backup_dir/backgrounds
  mkdir -p $HOME/backgrounds

  # MOVE everything that is a background to backup location
  mv $HOME/backgrounds/* $shared_backup_dir/backgrounds/

  # copy target backgrounds to system
  cp $shared_dotfile_dir/backgrounds/* $HOME/backgrounds
}

# This function is responsible for backing up any oh-my-zsh themes
function backup_omz () {
  printf "### STARTING OMZ BACKUP ###\n"

  # make backup of OMZ themes
  mkdir -p $shared_backup_dir/omz_themes/theme

  # MOVE everything that is a theme to backup location
  cp $HOME/.oh-my-zsh/themes/*.zsh-theme $shared_backup_dir/omz_themes/

  # copy target OMZ themes to system
  cp $shared_dotfile_dir/omz_themes/* $HOME/.oh-my-zsh/themes/
}

##########
# This function creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
function backup_homedir () {
  printf "### STARTING $HOME/ BACKUP ###\n"

  # create dotfiles_old in homedir
  # printf "Creating $backup_olddir/home for backup"
  mkdir -p $backup_olddir/home
  # printf "...done\n\n"

  # move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
  for file in $profile_dir/home/* ; do
    basename_file="$(basename $file)"

    # printf "Moving $HOME/.$file to $backup_olddir/home \n"
    mv $HOME/.$basename_file $backup_olddir/home
    # printf "Creating symlink to $file in home directory.\n"
    ln -s $file $HOME/.$basename_file
  done
}

# This function is responsible for backing up any i3 system configs
function backup_i3config () {
  printf "### STARTING i3 CONFIG BACKUP ###\n"

  mkdir -p $backup_olddir/.config/i3
  mkdir -p $HOME/.config/i3

  mkdir -p $backup_olddir/.config/i3status
  mkdir -p $HOME/.config/i3status

  # MOVE anything in system .config that starts with 'i3' to backup
  mv $HOME/.config/i3/config $backup_olddir/.config/i3/
  mv $HOME/.config/i3status/config $backup_olddir/.config/i3status/

  # copy these Linux i3 .config to system
  cp -r $profile_dir/.config/i3/* $HOME/.config/i3/
  cp -r $profile_dir/.config/i3status/* $HOME/.config/i3status/
}

# This function is responsible for backing up the dunst configuration file
function backup_dunst () {
  printf "### STARTING DUNST BACKUP ###\n"

  # backup current config
  mkdir -p $backup_olddir/.config/dunst
  mkdir -p $HOME/.config/dunst

  cp -r $HOME/.config/dunst $backup_olddir/.config/

  # install new config
  cp -r $profile_dir/.config/dunst/* $HOME/.config/dunst/
}

# This function is responsible for backing up any custom installed fonts
function backup_fonts () {
  printf "### STARTING FONT BACKUP ###\n"

  mkdir -p $backup_olddir/.fonts
  mkdir -p $HOME/.fonts/

  # MOVE any TTF in system .fonts
  mv $HOME/.fonts/*.ttf $backup_olddir/.fonts/

  # copy these Linux .font
  cp -r $profile_dir/.fonts/*.ttf $HOME/.fonts/
}

# This function is responsible for backing up XFCE terminal config
function backup_terminal () {
  printf "### STARTING xfce4-terminal BACKUP ###\n"

  mkdir -p $backup_olddir/.config/xfce4/terminal
  mkdir -p $HOME/.config/xfce4/terminal

  # MOVE anything in system .config that starts with 'i3' to backup
  mv $HOME/.config/xfce4/terminal/terminalrc $backup_olddir/.config/xfce4/terminal/terminalrc

  # copy these Linux i3 .config to system
  cp $profile_dir/.config/xfce4/terminal/terminalrc $HOME/.config/xfce4/terminal/
}

function backup_home_bin () {
  printf "### STARTING $HOME/bin BACKUP ###\n"

  mkdir -p $backup_olddir/bin
  mkdir -p $HOME/bin

  # MOVE anything in $HOME/bin to backup/bin
  cp -ar $HOME/bin $backup_olddir/

  # copy these ./bin files to $HOME/bin
  cp -ar $profile_dir/bin $HOME/
  # sudo cp $profile_dir/bin/backup.sh /etc/init.d/backup
}

# This function controls what backup functions are run
function backup_all () {
  printf "### BACKUP_ALL STARTING ###\n"

  # shared
  backup_backgrounds
  backup_omz

  # profile-based
  backup_homedir
  backup_i3config
  backup_dunst
  backup_fonts
  backup_terminal
  backup_home_bin

  printf "### BACKUP_ALL COMPLETE ###\n"
}

### </HELPER_FUNCTIONS> ###



### <ENTRY_POINT> ###

backup_all && notify-send -t 2000 "dotfile install" "backup complete"

### </ENTRY_POINT> ###
#!/bin/sh

cd $HOME

# What to backup.
backup_files="Desktop/ Documents/ backgrounds/ screenshots/ .everc/dotfiles"

# Where to backup to.
# hostname=$(hostname -s)
hostname="rogue_lurch"
dest="$HOME/backups/$hostname"
mkdir -p $dest

# Create archive filename.
day=$(date +%Y-%m-%d-%H-%M-%S)
archive_file="$day.tgz"

# Print start status message.
echo "Backing up $backup_files to $dest/$archive_file"

# Backup the files using tar.
tar czf $dest/$archive_file $backup_files
# scp $dest/$archive_file lurch@raspberrypi.local:backups/rogue_lurch/
# tar czf - $dest/$archive_file lurch@raspberrypi.local:backups/rogue_lurch/
# tar cvzf - $dest/$archive_file | ssh lurch@raspberrypi.local "dd of=/home/lurch/backups/rogue_lurch/"
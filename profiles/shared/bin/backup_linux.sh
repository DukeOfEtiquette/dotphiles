#!/bin/bash
# inspiration: https://www.2daygeek.com/backup-user-home-directory-in-linux-using-tar-comm    and/

DATE=$(date +%Y-%m-%d-%T)

log_dir="/var/log/backups/data"
mkdir -p $log_dir
log_file=$log_dir/log.txt

log()
{
  MESSAGE=$1
  echo $MESSAGE >> $log_file
}

time=$(date +%T)
log "$time: Backup initiating"

BACKUP_DIR="/var/backups/data"
mkdir -p $BACKUP_DIR
BACKUP_FILE=$BACKUP_DIR/data-$DATE.tar.gz

# Backup home directory
log "Starting archive, saving to $BACKUP_FILE"
echo $DATE >> $HOME/backup_timestamp
tar -zcvpf $BACKUP_FILE -C /home/adamduquette \
  --exclude='./.*' \
  --exclude='ts3d' \
  --exclude='ts3d_communicator_logs' \
  --exclude='ts3d_communicator_workspace' \
  --exclude='bin' \
  --exclude='Downloads' \
  --exclude='HOOPS' \
  --exclude='Perforce' \
  --exclude='slack_downloads' \
  --exclude='snap' \
  --exclude='venv' \
  --exclude='node_modules' \
  --exclude-vcs \
  ./

rm $HOME/backup_timestamp
cp $BACKUP_FILE $BACKUP_DIR/latest.tar.gz

# Delete files older than 10 days
log "Deleting files older than 10 days..."
find $BACKUP_DIR/* -mtime +10 -exec rm {} \;

log "$time: Backup finished\n"

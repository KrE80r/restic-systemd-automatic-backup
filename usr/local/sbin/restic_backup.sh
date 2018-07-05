#!/usr/bin/env bash
# Make backup my system with restic to a local hard drive.
# This script is typically run by: /etc/systemd/system/nightly-backup.{service,timer}

# Exit on failure, pipe failure
set -e -o pipefail

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee" to a file, so we can observe the status by simply tailing the log file.
me=$(basename "$0")
now=$(date +%F_%R)
log_dir=$HOME/.restic/logs
log_file="${log_dir}/${now}_${me}.$$.log"
test -d $log_dir || mkdir -p $log_dir
exec > >(tee -i $log_file)
exec 2>&1

# Clean up lock if we are killed.
# If killed by systemd, like $(systemctl stop restic), then it kills the whole cgroup and all it's subprocesses.
# However if we kill this script ourselves, we need this trap that kills all subprocesses manually.
exit_hook() {
  echo "In exit_hook(), being killed" >&2
  jobs -p | xargs kill
  restic unlock
}
trap exit_hook INT TERM

# How many backups to keep.
RETENTION_DAYS=7
RETENTION_WEEKS=4
RETENTION_MONTHS=12
RETENTION_YEARS=3

# What to backup, and what to not
BACKUP_PATHS="/home /other/paths/you/want/to/backup"
BACKUP_EXCLUDES="--exclude-file /etc/restic/exclude.txt"
BACKUP_TAG=systemd.timer


# Set all environment variables like RESTIC_REPOSITORY, etc.
source /etc/restic/restic_env.sh

# NOTE start all commands in background and wait for them to finish.
# Reason: bash ignores any signals while child process is executing and thus my trap exit hook is not triggered.
# However if put in subprocesses, wait(1) waits until the process finishes OR signal is received.
# Reference: https://unix.stackexchange.com/questions/146756/forward-sigterm-to-child-in-bash

# Remove locks from other stale processes to keep the automated backup running.
restic unlock &
wait $!

# Do the backup!
# See restic-backup(1) or http://restic.readthedocs.io/en/latest/040_backup.html
# --one-file-system makes sure we only backup exactly those mounted file systems specified in $BACKUP_PATHS, and thus not directories like /dev, /sys etc.
# --tag lets us reference these backups later when doing restic-forget.
restic backup \
  --one-file-system \
  --tag $BACKUP_TAG \
  $BACKUP_EXCLUDES \
  $BACKUP_PATHS &
wait $!

# Dereference old backups.
# See restic-forget(1) or http://restic.readthedocs.io/en/latest/060_forget.html
restic forget \
  --tag $BACKUP_TAG \
  --keep-daily $RETENTION_DAYS \
  --keep-weekly $RETENTION_WEEKS \
  --keep-monthly $RETENTION_MONTHS \
  --keep-yearly $RETENTION_YEARS &
wait $!

# Remove old data not linked anymore.
# See restic-prune(1) or http://restic.readthedocs.io/en/latest/060_forget.html
restic prune &
wait $!

# Check repository for errors.
# NOTE this takes much time (and data transfer from remote repo?), do this in a separate systemd.timer which is run less often.
#restic check &
#wait $!

echo "Backup & cleaning is done."
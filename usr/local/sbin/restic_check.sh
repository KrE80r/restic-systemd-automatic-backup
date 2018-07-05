#!/usr/bin/env bash
# Check my backup with restic for errors.
# This script is typically run by: /etc/systemd/system/weekly-backup.{service,timer}

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

# Set all environment variables like RESTIC_REPOSITORY, etc.
source /etc/restic/restic_env.sh

# Remove locks from other stale processes to keep the automated backup running.
# NOTE nope, dont' unlock liek restic_backup.sh. restic_backup.sh should take preceedance over this script.
#restic unlock &
#wait $!

# Check repository for errors.
restic check &
wait $!
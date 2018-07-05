# Restic parameters
# Extracted settings so both systemd timers and user can just source this when want to work on my restic backup.
# See https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html

export RESTIC_REPOSITORY="/path/to/restic/respository"
export RESTIC_PASSWORD_FILE="/etc/restic/restic_pw.txt"

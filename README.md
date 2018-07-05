# Automatic restic backups using systemd services and timers

Forked from [erikw/restic-systemd-automatic-backup](https://github.com/erikw/restic-systemd-automatic-backup), this is my version that uses a local repo which is then sync'd to Google Cloud Storage using [`rclone`](https://rclone.org/)

## Restic

[restic](https://restic.net/) is a command-line tool for making backups, the right way. Check the official website for a feature explanation. As a storage backend, I'm using [Google Cloud Storage](https://cloud.google.com/storage/) as restic works well with it, and it has (at the time of writing) a 12 month, $300 trial credit which can be used to store your backups for up a year for free, depending on your usage.

Unfortunately restic does not come per-configured with a way to run automated backups, say every day. However it's possible to set this up yourself using. 

Here follows a step-by step tutorial on how to set it up, with my sample script and configurations that you can modify to suit your needs.

Note, you can use any of the supported [storage backends](https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html). The setup should be similar but you will have to use other configuration variables to match your backend of choice.

## Set up

_To Do._ There are a number of differences that I need to document, but will get to later.

Note that I make use of another service and a program called `slacksink` to send systemd service failures to Slack. Need to clean that up as well.

Add a Makefile to automatically install and update files as described.

#!/bin/bash

SLACK_TOKEN=<SLACK-LEGACY-API-TOKEN-HERE>
UNIT=$1
HOST=<enter-your-hostname-here>
MESSAGE="$UNIT failed on $HOST"
SLACK_USERNAME="systemd-timer"
systemctl status --full "$UNIT" | $HOME/.go/bin/slacksink \
--channel="#<channel-name>" --message="$MESSAGE" --attachment \
--color=danger --token="$SLACK_TOKEN"
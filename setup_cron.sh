#!/bin/bash

INTERVAL=$1
if [ -z "$INTERVAL" ]; then
    INTERVAL=10
fi

SCRIPT_PATH="$(pwd)/sync_reconciliere.sh"
LOG_PATH="$(pwd)/cron.log"

crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"
if [ $? -eq 0 ]; then
    echo "cron deja setat"
else
    (crontab -l 2>/dev/null; echo "*/$INTERVAL * * * * $SCRIPT_PATH >> \"$LOG_PATH\" 2>&1") | crontab -
    echo "cron setat pentru $INTERVAL minute"
fi

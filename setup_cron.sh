#!/bin/bash

SCRIPT_RECONCILIERE="/home/andy/Desktop/Stagiu-Practica/sync_reconciliere.sh"
INTERVAL="${1:-10}"

echo "setare cron la $INTERVAL minute pt $SCRIPT_RECONCILIERE"

chmod +x "$SCRIPT_RECONCILIERE"

crontab -l 2>/dev/null | grep -q "$SCRIPT_RECONCILIERE"

if [ $? -eq 0 ]; then
    echo "cron deja setat"
else
    (crontab -l 2>/dev/null; echo "*/$INTERVAL * * * * $SCRIPT_RECONCILIERE") | crontab -
    echo "cron setat cu succes la $INTERVAL minute"
fi

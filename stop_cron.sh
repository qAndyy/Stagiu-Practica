#!/bin/bash

SCRIPT_RECONCILIERE="sync_reconciliere.sh"

echo "oprire cron pt $SCRIPT_RECONCILIERE"

crontab -l 2>/dev/null | grep -v "$SCRIPT_RECONCILIERE" | crontab -

echo "cron oprit cu succes"

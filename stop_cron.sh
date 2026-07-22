#!/bin/bash
SCRIPT_PATH="$(pwd)/sync_reconciliere.sh"

crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" | crontab -
echo "cron oprit cu succes"

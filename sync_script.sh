#!/bin/bash

DIR_LOCAL="/home/andy/Desktop/sync_test/"
USER_REMOTE="vboxuser"
IP_REMOTE="10.211.25.193"
DIR_REMOTE="/home/vboxuser/Desktop/sync_dest/"

echo "start sync pt directorul $DIR_LOCAL"

inotifywait -m -r -e close_write,create "$DIR_LOCAL" --format "%w%f" | while read FISIER_MODIFICAT; do

    NUME_FISIER=$(basename "$FISIER_MODIFICAT")
    echo "Fisier modificat: $NUME_FISIER"
    
    FISIER_TEMPORAR="${NUME_FISIER}.tmp"
    
    scp -q "$FISIER_MODIFICAT" "${USER_REMOTE}@${IP_REMOTE}:\"${DIR_REMOTE}${FISIER_TEMPORAR}\""
    
    STATUS_LSOF=$(ssh "${USER_REMOTE}@${IP_REMOTE}" "lsof \"${DIR_REMOTE}${NUME_FISIER}\" > /dev/null 2>&1; echo \$?")
    
    if [ "$STATUS_LSOF" -eq 1 ]; then
        ssh "${USER_REMOTE}@${IP_REMOTE}" "mv \"${DIR_REMOTE}${FISIER_TEMPORAR}\" \"${DIR_REMOTE}${NUME_FISIER}\""
        echo "copiere finalizata cu succes"
    else
        echo "fisierul e deschis pe ubuntu"
    fi

done

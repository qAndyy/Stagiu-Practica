#!/bin/bash

source /home/andy/Desktop/Stagiu-Practica/setari.conf

echo "start sync pt directorul $DIR_LOCAL"

inotifywait -m -r -e close_write,create "$DIR_LOCAL" --format "%w%f" | while read FISIER_MODIFICAT; do

    NUME_FISIER=$(basename "$FISIER_MODIFICAT")
    echo "Fisier modificat: $NUME_FISIER"
    
    FISIER_TEMPORAR="${NUME_FISIER}.tmp"
    
    for SLAVE in "${SLAVES[@]}"; do
        ssh -n "${SLAVE}" "mkdir -p \"${DIR_REMOTE}\""
        
        scp -q "$FISIER_MODIFICAT" "${SLAVE}:\"${DIR_REMOTE}${FISIER_TEMPORAR}\""
        
        STATUS_LSOF=$(ssh -n "${SLAVE}" "lsof \"${DIR_REMOTE}${NUME_FISIER}\" > /dev/null 2>&1; echo \$?")
        
        if [ "$STATUS_LSOF" -eq 1 ]; then
            ssh -n "${SLAVE}" "mv \"${DIR_REMOTE}${FISIER_TEMPORAR}\" \"${DIR_REMOTE}${NUME_FISIER}\""
            echo "copiere finalizata cu succes pe $SLAVE"
        else
            echo "fisierul e deschis pe $SLAVE"
        fi
    done

done

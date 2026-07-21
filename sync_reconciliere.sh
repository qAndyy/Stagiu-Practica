#!/bin/bash

source /home/andy/Desktop/Stagiu-Practica/setari.conf

echo "start verificare md5sum pt directorul $DIR_LOCAL"

for FISIER_LOCAL in "$DIR_LOCAL"*; do
    if [ -f "$FISIER_LOCAL" ]; then
        NUME_FISIER=$(basename "$FISIER_LOCAL")
        
        MD5_LOCAL=$(md5sum "$FISIER_LOCAL" | awk '{print $1}')
        
        for SLAVE in "${SLAVES[@]}"; do
            ssh -n "${SLAVE}" "mkdir -p \"${DIR_REMOTE}\""
            
            MD5_REMOTE=$(ssh -n "${SLAVE}" "md5sum \"${DIR_REMOTE}${NUME_FISIER}\" 2>/dev/null" | awk '{print $1}')
            
            if [ "$MD5_LOCAL" != "$MD5_REMOTE" ]; then
                echo "diferenta detectata la: $NUME_FISIER pe $SLAVE"
                
                FISIER_TEMPORAR="${NUME_FISIER}.tmp"
                
                scp -q "$FISIER_LOCAL" "${SLAVE}:\"${DIR_REMOTE}${FISIER_TEMPORAR}\""
                
                STATUS_LSOF=$(ssh -n "${SLAVE}" "lsof \"${DIR_REMOTE}${NUME_FISIER}\" > /dev/null 2>&1; echo \$?")
                
                if [ "$STATUS_LSOF" -eq 1 ]; then
                    ssh -n "${SLAVE}" "mv \"${DIR_REMOTE}${FISIER_TEMPORAR}\" \"${DIR_REMOTE}${NUME_FISIER}\""
                    echo "copiere finalizata cu succes pe $SLAVE"
                else
                    echo "fisierul e deschis pe $SLAVE"
                fi
            fi
        done
    fi
done

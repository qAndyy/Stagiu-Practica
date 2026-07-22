#!/bin/bash
source setari.conf

inotifywait -m -e close_write,create,delete --format '%w%f %e' "$DIR_LOCAL" | while read -r FISIER EVENT
do
    NUME_FISIER=$(basename "$FISIER")
    
    if [[ "$EVENT" == *"DELETE"* ]]; then
        echo "fisier sters local: $NUME_FISIER"
        for SLAVE in "${SLAVES[@]}"; do
            ssh "$SLAVE" "rm -f ${DIR_REMOTE}${NUME_FISIER}"
            echo "sters si de pe $SLAVE"
        done
    else
        echo "Fisier modificat: $NUME_FISIER"
        for SLAVE in "${SLAVES[@]}"; do
            scp "${DIR_LOCAL}${NUME_FISIER}" "${SLAVE}:${DIR_REMOTE}${NUME_FISIER}.tmp"
            
            if [ $? -eq 0 ]; then
                IN_USE=$(ssh "$SLAVE" "lsof ${DIR_REMOTE}${NUME_FISIER} 2>/dev/null | wc -l")
                
                if [ "$IN_USE" -eq 0 ]; then
                    ssh "$SLAVE" "mv ${DIR_REMOTE}${NUME_FISIER}.tmp ${DIR_REMOTE}${NUME_FISIER}"
                    echo "copiere finalizata cu succes pe $SLAVE"
                else
                    echo "fisierul e deschis pe $SLAVE"
                fi
            else
                echo "eroare la transfer, ignoram temporarul"
            fi
        done
    fi
done

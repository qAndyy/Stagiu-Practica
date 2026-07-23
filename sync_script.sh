#!/bin/bash
source setari.conf

inotifywait -m -e close_write,create,delete --format '%e %f' "$DIR_LOCAL" | while read -r EVENT NUME_FISIER
do
    if [[ "$EVENT" == *"DELETE"* ]]; then
        echo "fisier sters local: $NUME_FISIER"
        for SLAVE in "${SLAVES[@]}"; do
            ssh "$SLAVE" "rm -f \"${DIR_REMOTE}${NUME_FISIER}\"" 2>/dev/null
            echo "sters si de pe $SLAVE"
        done
    else
        echo "Fisier modificat: $NUME_FISIER"
        for SLAVE in "${SLAVES[@]}"; do
            scp -q "${DIR_LOCAL}${NUME_FISIER}" "${SLAVE}:\"${DIR_REMOTE}${NUME_FISIER}.tmp\"" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                IN_USE=$(ssh "$SLAVE" "lsof \"${DIR_REMOTE}${NUME_FISIER}\" 2>/dev/null | wc -l")
                
                if [ "$IN_USE" -eq 0 ]; then
                    ssh "$SLAVE" "mv \"${DIR_REMOTE}${NUME_FISIER}.tmp\" \"${DIR_REMOTE}${NUME_FISIER}\"" 2>/dev/null
                    echo "copiere finalizata cu succes pe $SLAVE"
                else
                    echo "atentie: fisierul este deschis/blocat pe $SLAVE"
                fi
            fi
        done
    fi
done

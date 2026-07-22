#!/bin/bash
cd "$(dirname "$0")"
source setari.conf

for SLAVE in "${SLAVES[@]}"; do
    FISIERE_REMOTE=$(ssh "$SLAVE" "ls $DIR_REMOTE")
    for FISIER_R in $FISIERE_REMOTE; do
        if [[ "$FISIER_R" != *.tmp ]]; then
            if [ ! -f "${DIR_LOCAL}${FISIER_R}" ]; then
                ssh "$SLAVE" "rm -f ${DIR_REMOTE}${FISIER_R}"
            fi
        fi
    done

    for FISIER in "${DIR_LOCAL}"*; do
        if [ -f "$FISIER" ]; then
            NUME_FISIER=$(basename "$FISIER")
            MD5_LOCAL=$(md5sum "$FISIER" | awk '{print $1}')
            MD5_REMOTE=$(ssh "$SLAVE" "md5sum ${DIR_REMOTE}${NUME_FISIER} 2>/dev/null | awk '{print \$1}'")
            
            if [ "$MD5_LOCAL" != "$MD5_REMOTE" ]; then
                echo "diferenta detectata"
                scp "$FISIER" "${SLAVE}:${DIR_REMOTE}${NUME_FISIER}.tmp"
                
                if [ $? -eq 0 ]; then
                    IN_USE=$(ssh "$SLAVE" "lsof ${DIR_REMOTE}${NUME_FISIER} 2>/dev/null | wc -l")
                    if [ "$IN_USE" -eq 0 ]; then
                        ssh "$SLAVE" "mv ${DIR_REMOTE}${NUME_FISIER}.tmp ${DIR_REMOTE}${NUME_FISIER}"
                    fi
                fi
            fi
        fi
    done
done

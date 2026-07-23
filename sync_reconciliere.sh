#!/bin/bash
cd "$(dirname "$0")"
source setari.conf

for SLAVE in "${SLAVES[@]}"; do
    
    ssh "$SLAVE" "ls -1 \"$DIR_REMOTE\"" 2>/dev/null | while read -r FISIER_R; do
        if [ -n "$FISIER_R" ] && [[ "$FISIER_R" != *.tmp ]]; then
            if [ ! -f "${DIR_LOCAL}${FISIER_R}" ]; then
                ssh "$SLAVE" "rm -f \"${DIR_REMOTE}${FISIER_R}\"" 2>/dev/null
            fi
        fi
    done

    for FISIER in "${DIR_LOCAL}"*; do
        if [ -f "$FISIER" ]; then
            NUME_FISIER=$(basename "$FISIER")
            MD5_LOCAL=$(md5sum "$FISIER" | awk '{print $1}')
            MD5_REMOTE=$(ssh "$SLAVE" "md5sum \"${DIR_REMOTE}${NUME_FISIER}\" 2>/dev/null | awk '{print \$1}'")
            
            if [ "$MD5_LOCAL" != "$MD5_REMOTE" ]; then
                echo "diferenta detectata la $NUME_FISIER"
                scp "$FISIER" "${SLAVE}:\"${DIR_REMOTE}${NUME_FISIER}.tmp\"" 2>/dev/null
                
                if [ $? -eq 0 ]; then
                    IN_USE=$(ssh "$SLAVE" "lsof \"${DIR_REMOTE}${NUME_FISIER}\" 2>/dev/null | wc -l")
                    if [ "$IN_USE" -eq 0 ]; then
                        ssh "$SLAVE" "mv \"${DIR_REMOTE}${NUME_FISIER}.tmp\" \"${DIR_REMOTE}${NUME_FISIER}\"" 2>/dev/null
                    fi
                fi
            fi
        fi
    done
done

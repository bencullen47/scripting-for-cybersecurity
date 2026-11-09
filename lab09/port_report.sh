#!/bin/bash

REPORT=""

for CONF in case/configs/*.conf case/backups/config.old; do
    if [ -f "$CONF" ]; then
        PORT=$(grep '^port=' "$CONF" | cut -d'=' -f2)
        if [ -z "$PORT" ]; then
            PORT="(none)"
        fi

        DEBUG=$(grep '^debug=' "$CONF" | cut -d'=' -f2)
        if [ -z "$DEBUG" ]; then
            DEBUG="(none)"
        fi

        REPORT="${REPORT}${CONF}: port ${PORT}, debug ${DEBUG}"$'\n'
    fi
done

echo "Configured ports and debug states:"
echo "$REPORT"

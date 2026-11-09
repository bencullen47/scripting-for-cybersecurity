#!/bin/bash

TOTAL_FILES=0
FLAGGED=0
TOTAL_IOC_MATCHES=0

for FILE in case/evidence/* case/scripts/* case/logs/*.log; do
    [ -f "$FILE" ] || continue

    TOTAL_FILES=$((TOTAL_FILES + 1))
    SIZE=$(wc -c < "$FILE")
    TYPE=$(file -b "$FILE")

    echo "FILE: $FILE"
    echo "  size: $SIZE bytes"
    echo "  type: $TYPE"

    if [[ "$TYPE" == *text* ]]; then
        LINES=$(wc -l < "$FILE")
        echo "  lines: $LINES"
    fi

    HASH=$(sha256sum "$FILE" | awk '{print $1}')
    echo "  sha256: $HASH"

    EXPECT=""
    if [[ "$FILE" == *.png ]]; then
        EXPECT="PNG"
    elif [[ "$FILE" == *.zip ]]; then
        EXPECT="Zip"
    elif [[ "$FILE" == *.txt || "$FILE" == *.md ]]; then
        EXPECT="text"
    elif [[ "$FILE" == *.bin ]]; then
        EXPECT="empty"
    elif [[ "$FILE" == *.dat ]]; then
        EXPECT="data"
    elif [[ "$FILE" == *.sh ]]; then
        EXPECT="shell script"
    elif [[ "$FILE" == *.py ]]; then
        EXPECT="Python"
    fi

    if [ -n "$EXPECT" ]; then
        if [[ "$TYPE" == *"$EXPECT"* ]]; then
            echo "  status: OK"
        else
            echo "  status: !! expected $EXPECT, detected: $TYPE"
            FLAGGED=$((FLAGGED + 1))
        fi
    else
        echo "  status: ?? no expectation for this extension"
    fi

    if [[ "$FILE" == *.log ]]; then
        MATCHES=0
        for INDICATOR in $(cat intel/iocs.txt); do
            if grep -qwF "$INDICATOR" "$FILE"; then
                MATCHES=$((MATCHES + 1))
            fi
        done
        echo "  IOC matches: $MATCHES"
        TOTAL_IOC_MATCHES=$((TOTAL_IOC_MATCHES + MATCHES))
    fi

done

echo "Files surveyed: $TOTAL_FILES"
echo "Files flagged: $FLAGGED"
echo "Total IOC matches: $TOTAL_IOC_MATCHES"

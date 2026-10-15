#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

FILE=$1
LINES=$(wc -l < "$FILE")

if [ "$LINES" -lt 10 ]; then
    echo "$FILE is SMALL ($LINES lines)"
elif [ "$LINES" -lt 70 ]; then
    echo "$FILE is MEDIUM ($LINES lines)"
else
    echo "$FILE is LARGE ($LINES lines)"
fi

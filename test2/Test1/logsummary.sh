#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <logfile>" >&2
	exit 1
fi

logfile="$1"

if [ ! -e "$logfile" ]; then
	echo "Error: file does not exist: $logfile" >&2
	exit 2
fi

if [ ! -f "$logfile" ] || [ ! -s "$logfile" ]; then
	echo "Error: file is empty or not a regular file: $logfile" >&2
	exit 3
fi

lines=$(wc -l < "$logfile")
failed=$(grep -c 'Failed password' "$logfile")
accepted=$(grep -c 'Accepted password' "$logfile")
first=$(head -n 1 "$logfile" || awk '{print $1, $2, $3}')
last=$(tail -n 1 "$logfile" || awk '{print $1, $2, $3}')

echo "File	: $logfile"
echo "Lines:	: $lines"
echo "Failed	: $failed"
echo "Accepted	: $accepted"
echo "First	: $first"
echo "Last	: $last"

exit 0

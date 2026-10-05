#!/bin/bash

# Check that a filename was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <logfile>" >&2
    exit 1
fi

LOGFILE="$1"

# Check that the file exists
if [ ! -f "$LOGFILE" ]; then
    echo "Error: file does not exist" >&2
    exit 2
fi

# Total failed password attempts
FAILED=$(grep -c "Failed password" "$LOGFILE")
echo "Total failed password attempts: $FAILED"

# Most common attacking IP
TOP_IP=$(grep "Failed password" "$LOGFILE" | awk '{print $NF}' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
echo "Top attacking IP: $TOP_IP"

# Three busiest source IPs using top3.sh
echo "Top 3 source IPs:"
./top3.sh "$LOGFILE"

# Three most-targeted usernames
echo "Top 3 targeted usernames:"
grep "Failed password" "$LOGFILE" | awk '{print $(NF-2)}' | sort | uniq -c | sort -nr | head -n 3

exit 0

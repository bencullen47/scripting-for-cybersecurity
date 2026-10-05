#!/bin/bash 
TODAY=$(date +%Y-%m-%d)
echo "Today is $TODAY"

LINE_COUNT=$(wc -l < case/lab04-data/logs/auth.log)
echo "auth.log has $LINE_COUNT lines"

FAILED_COUNT=$(grep -c "Failed password" case/lab04-data/logs/auth.log)
echo "There were $FAILED_COUNT failed login attempts"
AUTH_LOG="case/lab04-data/logs/auth.log"

TOP_ATTACKERS=$(grep "Failed password" "$AUTH_LOG" |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
    sort | uniq -c | sort -nr | head -n 3)

echo "Top 3 failed-login sources:"
echo $TOP_ATTACKERS

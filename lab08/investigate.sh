#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <logfile> <search-term>" >&2
    exit 1
fi

LOGFILE=$1
TERM_ARG=$2
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
CASE_DIR="$SCRIPT_DIR/case"
FIREWALL_LOG="$CASE_DIR/logs/firewall.log"
IOC_FILE="$SCRIPT_DIR/intel/iocs.txt"

if [ -z "$LOGFILE" ]; then
    echo "Error: log file not specified" >&2
    exit 2
fi

if [ ! -e "$LOGFILE" ]; then
    echo "Error: '$LOGFILE' not found" >&2
    exit 2
fi

if [ ! -f "$LOGFILE" ]; then
    echo "Error: '$LOGFILE' is not a regular file" >&2
    exit 3
fi

if [ ! -r "$LOGFILE" ]; then
    echo "Error: '$LOGFILE' is not readable" >&2
    exit 4
fi

if [ -z "$TERM_ARG" ]; then
    echo "Error: search term cannot be empty" >&2
    exit 5
fi

if echo "$TERM_ARG" | grep -Eq '^[0-9]+(\.[0-9]+){3}$'; then
    COUNT=$(grep -cwF "$TERM_ARG" "$LOGFILE" || true)
    FAILED=$(grep -Ec "Failed password for .* from $TERM_ARG " "$LOGFILE" || true)
    if [ "$FAILED" -gt 0 ]; then
        if [ "$FAILED" -lt 5 ]; then
            RISK="LOW"
        elif [ "$FAILED" -lt 15 ]; then
            RISK="MEDIUM"
        elif [ "$FAILED" -lt 30 ]; then
            RISK="HIGH"
        else
            RISK="CRITICAL"
        fi
    else
        RISK="NONE"
    fi

    echo "IP: $TERM_ARG"
    echo "Occurrences in log: $COUNT"
    echo "Failed password attempts: $FAILED"
    echo "Risk: $RISK"

    if [ -f "$FIREWALL_LOG" ]; then
        FW_MATCH=$(grep -wF "$TERM_ARG" "$FIREWALL_LOG" || true)
        if [ -n "$FW_MATCH" ]; then
            echo "Firewall entries:"
            echo "$FW_MATCH"
        else
            echo "Firewall entries: none"
        fi
    else
        echo "Firewall entries: unavailable"
    fi

    if grep -qxF "$TERM_ARG" "$IOC_FILE"; then
        echo "IOC status: listed in intel/iocs.txt"
    else
        echo "IOC status: not listed in intel/iocs.txt"
    fi

    if [ "$COUNT" -gt 0 ]; then
        exit 0
    else
        exit 7
    fi
else
    FAILED=$(grep -c "Failed password for $TERM_ARG " "$LOGFILE" || true)
    ACCEPTED=$(grep -c "Accepted password for $TERM_ARG " "$LOGFILE" || true)
    if grep -q "^$TERM_ARG," "$SCRIPT_DIR/intel/users.csv"; then
        STATUS="CURRENT"
    elif grep -qxF "$TERM_ARG" "$CASE_DIR/backups/users.old"; then
        STATUS="LEGACY"
    else
        STATUS="UNKNOWN"
    fi

    echo "Username: $TERM_ARG"
    echo "Status: $STATUS"
    echo "Failed logins: $FAILED"
    echo "Accepted logins: $ACCEPTED"

    if [ "$FAILED" -gt 0 ]; then
        echo "Assessment: investigate"
    else
        echo "Assessment: no failed logins"
    fi

    if [ "$ACCEPTED" -gt 0 ] || [ "$FAILED" -gt 0 ]; then
        exit 0
    else
        exit 7
    fi
fi

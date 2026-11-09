#!/bin/bash

CLIENTS=$(awk '{print $1}' case/logs/access.log | sort -u)

for IP in $CLIENTS; do
    COUNT=$(grep -c "^$IP " case/logs/access.log || true)
    if grep -qxF "$IP" intel/iocs.txt; then
        continue
    fi

    if [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        if [[ "$IP" =~ ^(192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.) ]]; then
            echo "$IP ($COUNT requests): NOT in IOC list — internal"
        else
            echo "$IP ($COUNT requests): NOT in IOC list — external"
        fi
    else
        echo "$IP ($COUNT requests): NOT in IOC list — non-IP"
    fi
done

#!/bin/bash

CONF=$1
DEBUG=$(grep '^debug=' "$CONF" | cut -d'=' -f2)

if [ -z "$DEBUG" ]; then
    echo "$CONF: no debug setting"
elif [ "$DEBUG" = "true" ]; then
    echo "$CONF: WARNING - debug mode is ON"
elif [ "$DEBUG" = "false" ]; then
    echo "$CONF: debug mode is off"
else
    echo "$CONF: unexpected debug value '$DEBUG'"
fi

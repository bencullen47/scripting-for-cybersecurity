#!/bin/bash

read -p "Enter yes or no: " ANSWER

if [ "$ANSWER" = "yes" ]; then
    echo "Confirmed."
elif [ "$ANSWER" = "no" ]; then
    echo "Cancelled."
else
    echo "Unrecognised answer: '$ANSWER'"
fi

#!/bin/bash

read -p "Enter a username to look up: " TARGET_USER
read -p "Enter a department: " DEPARTMENT

echo "Searching for $TARGET_USER in $DEPARTMENT:"
grep "$TARGET_USER" intel/users.csv | grep "$DEPARTMENT"

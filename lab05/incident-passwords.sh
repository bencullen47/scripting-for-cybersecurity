#!/bin/bash

read -p "Enter username: " USERNAME
read -s -p "Enter password: " PASSWORD
echo ""

echo "Credentials captured for $USERNAME (password length: ${#PASSWORD})"

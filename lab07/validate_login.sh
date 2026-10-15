#!/bin/bash
# validate_login.sh - investigate one username

USERS_CSV="intel/users.csv"
LEGACY="case/lab04-data/backups/users.old"
AUTH_LOG="case/lab04-data/logs/auth.log"
PASSWORDS="case/lab04-data/evidence/passwords.txt"

# 1. Read username
read -p "Username: " USERNAME

# 2. Empty check
if [ -z "$USERNAME" ]; then
    echo "Error: username must not be empty" >&2
    exit 1
fi

# 3. Account source (same logic as account_source.sh)
SOURCE="UNKNOWN"
ROLE=""
STATUS=""
if grep -q "^$USERNAME," "$USERS_CSV"; then
    SOURCE="CURRENT"
    ROLE=$(grep "^$USERNAME," "$USERS_CSV" | head -n1 | cut -d, -f2)
    STATUS=$(grep "^$USERNAME," "$USERS_CSV" | head -n1 | cut -d, -f3)
elif grep -qx "$USERNAME" "$LEGACY"; then
    SOURCE="LEGACY"
fi

echo "User:   $USERNAME"
echo "Source: $SOURCE"
if [ "$SOURCE" = "CURRENT" ]; then
    echo "Role:   $ROLE"
    echo "Status: $STATUS"
fi

# 4. Count failed / accepted logins
FAILED=$(grep -c "Failed password for $USERNAME " "$AUTH_LOG")
ACCEPTED=$(grep -c "Accepted password for $USERNAME " "$AUTH_LOG")
echo "Failed logins:   $FAILED"
echo "Accepted logins: $ACCEPTED"

# 5. Risk level (thresholds from risk_level.sh)
if [ "$FAILED" -eq 0 ]; then
    RISK="NONE"
elif [ "$FAILED" -lt 5 ]; then
    RISK="LOW"
elif [ "$FAILED" -lt 15 ]; then
    RISK="MEDIUM"
elif [ "$FAILED" -lt 30 ]; then
    RISK="HIGH"
else
    RISK="CRITICAL"
fi
echo "Risk level: $RISK"

# 6. Warnings
if [ "$SOURCE" = "CURRENT" ] && [ "$STATUS" = "disabled" ] && [ "$ACCEPTED" -gt 0 ]; then
    echo "WARNING: disabled account has $ACCEPTED accepted login(s)!"
fi

if { [ "$SOURCE" = "LEGACY" ] || [ "$SOURCE" = "UNKNOWN" ]; } && [ "$FAILED" -gt 0 ]; then
    echo "WARNING: $SOURCE account targeted by $FAILED failed login(s) - attacker is guessing account names"
fi

if [ "$SOURCE" = "CURRENT" ] && [ "$ACCEPTED" -gt 0 ] && grep -q "^$USERNAME:" "$PASSWORDS"; then
    echo "WARNING: current account has accepted logins AND appears in passwords.txt"
fi

# 7. Exit code
case "$SOURCE" in
    CURRENT) exit 0 ;;
    LEGACY)  exit 2 ;;
    *)       exit 3 ;;
esac

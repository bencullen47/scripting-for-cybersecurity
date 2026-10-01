#!/bin/bash

CASE_DIR="case"
REPORT="triage-report-auto.txt"

read -p "Enter analyst name: " ANALYST
read -p "Enter case reference: " CASE_REF

PYTHON_FILES=$(find "$CASE_DIR" -type f -name "*.py" | wc -l)
SHELL_SCRIPTS=$(find "$CASE_DIR" -type f -name "*.sh" | wc -l)

echo "TRIAGE REPORT" > "$REPORT"
echo "Analyst: $ANALYST" >> "$REPORT"
echo "Case Reference: $CASE_REF" >> "$REPORT"
echo "Date: $(date)" >> "$REPORT"
echo "" >> "$REPORT"

echo "Total Files: $(find "$CASE_DIR" -type f | wc -l)" >> "$REPORT"
echo "Total Directories: $(find "$CASE_DIR" -type d | wc -l)" >> "$REPORT"
echo "Python Files: $PYTHON_FILES" >> "$REPORT"
echo "Shell Scripts: $SHELL_SCRIPTS" >> "$REPORT"
echo "Log Files: $(find "$CASE_DIR" -type f -name "*.log" | wc -l)" >> "$REPORT"
echo "Configuration Files: $(find "$CASE_DIR" -type f -name "*.conf" | wc -l)" >> "$REPORT"
echo "Empty Files: $(find "$CASE_DIR" -type f -empty | wc -l)" >> "$REPORT"
echo "Archives: $(find "$CASE_DIR" -type f \( -name "*.tar" -o -name "*.gz" -o -name "*.zip" \) | wc -l)" >> "$REPORT"

echo "" >> "$REPORT"
echo "Files containing admin:" >> "$REPORT"
grep -rl "admin" "$CASE_DIR" >> "$REPORT"

echo "" >> "$REPORT"
echo "Evidence file types:" >> "$REPORT"
file "$CASE_DIR"/evidence/* >> "$REPORT"

TOTAL_SCRIPTS=$((PYTHON_FILES + SHELL_SCRIPTS))

echo "" >> "$REPORT"
echo "Scripts (Python + shell): $TOTAL_SCRIPTS" >> "$REPORT"

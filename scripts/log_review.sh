#!/usr/bin/env bash

# Set default log files, allow override from command line
ACCESS_LOG="/var/log/apache2/access.log"
ERROR_LOG="/var/log/apache2/error.log"

if [ -n "$1" ]; then
  ACCESS_LOG="$1"
fi

if [ -n "$2" ]; then
  ERROR_LOG="$2"
fi

echo "=== Apache Log Summary ==="
echo "Access log: $ACCESS_LOG"
echo "Error log : $ERROR_LOG"
echo

# Check access log exists
if [ ! -f "$ACCESS_LOG" ]; then
  echo "Access log not found: $ACCESS_LOG"
  exit 1
fi

echo "---- Top 10 IP addresses ----"
# Get first field (IP), count, and show top 10
cat "$ACCESS_LOG" | awk '{print $1}' | sort | uniq -c | sort -nr | head -10
echo

echo "---- Top 10 requested URLs ----"
# Get 7th field (URL path), count, and show top 10
cat "$ACCESS_LOG" | awk '{print $7}' | sort | uniq -c | sort -nr | head -10
echo

echo "---- HTTP status codes ----"
# Get 9th field (status code), keep only 3-digit numbers, count, show most common
cat "$ACCESS_LOG" | awk '{print $9}' | grep -E '^[0-9]{3}$' | sort | uniq -c | sort -nr
echo

echo "---- Last 20 error log lines ----"
if [ -f "$ERROR_LOG" ]; then
  tail -20 "$ERROR_LOG"
else
  echo "Error log not found: $ERROR_LOG"
fi

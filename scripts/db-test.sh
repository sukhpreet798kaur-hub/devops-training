#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3005}"

echo "Checking database connectivity via /health..."
STATUS=$(curl -s -o /tmp/health-response.txt -w "%{http_code}" "$BASE_URL/health")

if [ "$STATUS" != "200" ]; then
  echo "DB test failed: expected HTTP 200, got $STATUS"
  cat /tmp/health-response.txt
  exit 1
fi

if ! grep -q "Welcome to the Day 1 LAMP site." /tmp/health-response.txt; then
  echo "DB test failed: expected health content not found"
  cat /tmp/health-response.txt
  exit 1
fi

echo "DB connectivity test passed (app + page reachable)"

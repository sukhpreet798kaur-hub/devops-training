#!/usr/bin/env bash
set -euo pipefail

APP_URL="${APP_URL:-http://localhost:3005}"

echo "Checking app is reachable..."
STATUS=$(curl -s -o /tmp/app-response.txt -w "%{http_code}" "$APP_URL")

if [ "$STATUS" != "200" ]; then
  echo "Smoke test failed: expected 200, got $STATUS"
  exit 1
fi

echo "Checking expected content..."
if ! grep -q "Welcome" /tmp/app-response.txt; then
  echo "Smoke test failed: expected content not found"
  exit 1
fi

echo "Smoke test passed"

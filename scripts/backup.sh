#!/usr/bin/env bash
set -e
mkdir -p backup
tar -czf backup/repo-backup-$(date +%Y%m%d-%H%M%S).tar.gz .
echo "Backup created successfully."

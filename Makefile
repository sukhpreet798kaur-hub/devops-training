.PHONY: run test backup

# Run the app (example: main.py inside app/)
run:
\tpython app/main.py

# Run tests (example using pytest)
test:
\tpytest

# Create a timestamped backup tarball of the repo (excluding the backup itself)
backup:
\t@timestamp=$$(date +%Y%m%d-%H%M%S); \\
\ttar --exclude='backup-*.tar.gz' -czf backup-$$timestamp.tar.gz .
\t@echo "Backup created: backup-$$timestamp.tar.gz"

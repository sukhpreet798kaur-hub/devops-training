.PHONY: run test backup

run:
	php app/site/index.php

test:
	echo "Running PHP tests..."

backup:
	@timestamp=$$(date +%Y%m%d-%H%M%S); \
	tar --exclude=./backups --exclude='./*.tar.gz' -czf /tmp/backup-$$timestamp.tar.gz . && \
	echo "Backup created: /tmp/backup-$$timestamp.tar.gz"

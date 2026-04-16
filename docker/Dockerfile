FROM php:8.2-cli

RUN useradd -m appuser

WORKDIR /app
COPY . /app
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

# IMPORTANT: -t must point to folder with index.php
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/app"]

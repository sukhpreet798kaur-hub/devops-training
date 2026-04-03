# 1) Use official PHP image with built-in web server
FROM php:8.2-cli

# 2) Create a non-root user "appuser"
RUN useradd -m appuser

# 3) Work in /app
WORKDIR /app

# 4) Copy app files
COPY . /app

# 5) Change owner so non-root user can read files
RUN chown -R appuser:appuser /app

# 6) Switch to non-root user
USER appuser

# 7) Expose port 8080
EXPOSE 8080

# 8) Healthcheck: call /health on port 8080
# (no double backslash here)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# 9) Start PHP built-in server on 0.0.0.0:8080
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]

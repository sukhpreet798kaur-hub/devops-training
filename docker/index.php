<?php
// Simple homepage
if ($_SERVER['REQUEST_URI'] === '/') {
    echo "Hello from PHP on Docker!";
    exit;
}

// Simple health endpoint
if ($_SERVER['REQUEST_URI'] === '/health') {
    http_response_code(200);
    echo "OK";
    exit;
}

// Fallback
http_response_code(404);
echo "Not Found";

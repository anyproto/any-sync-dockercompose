#!/bin/bash
# Test script for anytype-cli

set -e

echo "======================================"
echo "Testing Anytype CLI Integration"
echo "======================================"
echo

echo "1. Checking anytype-cli service status..."
docker compose ps anytype-cli
echo

echo "2. Checking authentication status..."
docker compose exec anytype-cli /app/anytype auth status
echo

echo "3. Listing spaces..."
docker compose exec anytype-cli /app/anytype space list
echo

echo "4. Checking health..."
if docker compose ps anytype-cli | grep -q "healthy"; then
    echo "✓ Service is healthy"
else
    echo "✗ Service is not healthy"
    exit 1
fi
echo

echo "======================================"
echo "All tests passed!"
echo "======================================"

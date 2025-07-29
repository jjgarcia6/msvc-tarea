#!/bin/bash

# Railway Debug and Start Script
set -e

echo "=== Railway Debug Information ==="
echo "Current directory: $(pwd)"
echo "User: $(whoami)"
echo "Shell: $0"
echo "Arguments: $@"
echo ""

echo "=== Environment Variables ==="
echo "PORT: ${PORT:-'not set'}"
echo "EUREKA_PORT: ${EUREKA_PORT:-'not set'}"
echo "SPRING_PROFILES_ACTIVE: ${SPRING_PROFILES_ACTIVE:-'not set'}"
echo ""

echo "=== Directory Contents ==="
ls -la
echo ""

echo "=== Available JAR files ==="
ls -la *.jar 2>/dev/null || echo "No JAR files found"
echo ""

echo "=== Available Scripts ==="
ls -la *.sh 2>/dev/null || echo "No shell scripts found"
echo ""

echo "=== Script Permissions ==="
for script in entrypoint.sh railway-start.sh start-services.sh; do
    if [ -f "$script" ]; then
        echo "$script: $(ls -la $script)"
        echo "First line: $(head -1 $script)"
    else
        echo "$script: NOT FOUND"
    fi
done
echo ""

# Try to find the best script to run
if [ -f "railway-start.sh" ] && [ -x "railway-start.sh" ]; then
    echo "Running railway-start.sh..."
    exec ./railway-start.sh
elif [ -f "entrypoint.sh" ] && [ -x "entrypoint.sh" ]; then
    echo "Running entrypoint.sh..."
    exec ./entrypoint.sh
elif [ -f "start-services.sh" ] && [ -x "start-services.sh" ]; then
    echo "Running start-services.sh..."
    exec ./start-services.sh
else
    echo "ERROR: No executable startup script found!"
    echo "Available files:"
    ls -la
    exit 1
fi

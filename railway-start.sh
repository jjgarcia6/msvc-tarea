#!/bin/bash

# Simple Railway startup script
set -e

echo "=== ABC Motor Railway Simple Start ==="
echo "Working directory: $(pwd)"
echo "Available files:"
ls -la

# Port configuration
export EUREKA_PORT=${EUREKA_PORT:-8761}
export GATEWAY_PORT=${PORT:-8080}

echo "Starting with ports: Gateway=$GATEWAY_PORT, Eureka=$EUREKA_PORT"

# Create logs
mkdir -p logs

# Start Eureka first
echo "Starting Eureka Server..."
java -jar -Dserver.port=$EUREKA_PORT eureka-server.jar > logs/eureka.log 2>&1 &

# Wait a bit
sleep 15

# Start Gateway (main service for Railway)
echo "Starting Gateway (main service)..."
exec java -jar -Dserver.port=$GATEWAY_PORT gateway.jar

#!/bin/bash

# Simple Railway startup script
set -e

echo "=== ABC Motor Railway Simple Start ==="
echo "Working directory: $(pwd)"
echo "Available files:"
ls -la

# Port configuration - Railway assigns PORT dynamically
export EUREKA_PORT=${EUREKA_PORT:-8761}
export GATEWAY_PORT=${PORT:-8080}

echo "Starting with ports: Gateway=$GATEWAY_PORT, Eureka=$EUREKA_PORT"
echo "Railway assigned PORT: $PORT"

# Create logs
mkdir -p logs

# Function to wait for service
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=20
    
    echo "Waiting for $service_name on port $port..."
    for i in $(seq 1 $max_attempts); do
        if curl -f http://localhost:$port/actuator/health > /dev/null 2>&1; then
            echo "✓ $service_name is ready"
            return 0
        fi
        echo "Attempt $i/$max_attempts - waiting for $service_name..."
        sleep 2
    done
    echo "✗ $service_name failed to start"
    return 1
}

# Start Eureka first (background)
echo "Starting Eureka Server on port $EUREKA_PORT..."
java -jar \
    -Dserver.port=$EUREKA_PORT \
    -Dspring.profiles.active=production \
    -Xmx512m \
    eureka-server.jar > logs/eureka.log 2>&1 &
EUREKA_PID=$!

# Give Eureka time to start
echo "Waiting for Eureka to initialize..."
sleep 10

# Start Gateway (foreground - main process for Railway)
echo "Starting Gateway on port $GATEWAY_PORT..."
exec java -jar \
    -Dserver.port=$GATEWAY_PORT \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
    -Xmx512m \
    gateway.jar

#!/bin/bash

# ==============================================
# ABC Motor - Railway Entrypoint Script
# Simple and robust startup for Railway
# ==============================================

set -e

echo "=== ABC Motor Railway Startup ==="
echo "Current directory: $(pwd)"
echo "Files in directory:"
ls -la

# Railway environment variables with fallbacks
export EUREKA_PORT=${EUREKA_PORT:-8761}
export GATEWAY_PORT=${PORT:-8080}
export PRODUCTS_PORT=${PRODUCTS_PORT:-8081}
export SALES_PORT=${SALES_PORT:-8082}

echo "Port configuration:"
echo "- Eureka Server: $EUREKA_PORT"
echo "- Gateway: $GATEWAY_PORT" 
echo "- Products: $PRODUCTS_PORT"
echo "- Sales: $SALES_PORT"

# Create logs directory
mkdir -p logs

# Function to wait for service
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    
    echo "Waiting for $service_name on port $port..."
    for i in $(seq 1 $max_attempts); do
        if curl -f http://localhost:$port/actuator/health > /dev/null 2>&1; then
            echo "✓ $service_name is ready"
            return 0
        fi
        echo "Attempt $i/$max_attempts - waiting for $service_name..."
        sleep 3
    done
    echo "✗ $service_name failed to start after $max_attempts attempts"
    return 1
}

# Start Eureka Server
echo "Starting Eureka Server..."
java -jar \
    -Dserver.port=$EUREKA_PORT \
    -Dspring.profiles.active=production \
    eureka-server.jar > logs/eureka.log 2>&1 &
EUREKA_PID=$!

# Wait for Eureka
wait_for_service $EUREKA_PORT "Eureka Server"

# Start Gateway
echo "Starting Gateway..."
java -jar \
    -Dserver.port=$GATEWAY_PORT \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
    gateway.jar > logs/gateway.log 2>&1 &
GATEWAY_PID=$!

# Start Products Service
echo "Starting Products Service..."
java -jar \
    -Dserver.port=$PRODUCTS_PORT \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
    products.jar > logs/products.log 2>&1 &
PRODUCTS_PID=$!

# Start Sales Service  
echo "Starting Sales Service..."
java -jar \
    -Dserver.port=$SALES_PORT \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
    sales.jar > logs/sales.log 2>&1 &
SALES_PID=$!

echo "✓ All services started successfully!"
echo "PIDs: Eureka=$EUREKA_PID, Gateway=$GATEWAY_PID, Products=$PRODUCTS_PID, Sales=$SALES_PID"

# Function to handle shutdown
shutdown_handler() {
    echo "Received shutdown signal - stopping all services..."
    kill $EUREKA_PID $GATEWAY_PID $PRODUCTS_PID $SALES_PID 2>/dev/null || true
    wait
    echo "All services stopped."
    exit 0
}

# Set up signal handlers
trap shutdown_handler SIGTERM SIGINT EXIT

# Keep container running and monitor processes
echo "Services are running. Monitoring processes..."
while true; do
    # Check if main gateway process is still running (this is what Railway will monitor)
    if ! kill -0 $GATEWAY_PID 2>/dev/null; then
        echo "Gateway process died - container will exit"
        exit 1
    fi
    
    sleep 30
done

#!/bin/bash

# ==============================================
# ABC Motor - Services Startup Script
# Starts all 4 microservices in correct order
# ==============================================

set -e

# Railway environment variables with fallbacks
export EUREKA_PORT=${EUREKA_PORT:-8761}
export GATEWAY_PORT=${PORT:-8080}
export PRODUCTS_PORT=${PRODUCTS_PORT:-8081}
export SALES_PORT=${SALES_PORT:-8082}

echo "=== ABC Motor Microservices Startup ==="
echo "Starting services with ports:"
echo "- Eureka Server: $EUREKA_PORT"
echo "- Gateway: $GATEWAY_PORT" 
echo "- Products: $PRODUCTS_PORT"
echo "- Sales: $SALES_PORT"
echo "========================================"

# Function to wait for service
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    
    echo "Waiting for $service_name to start on port $port..."
    for i in $(seq 1 $max_attempts); do
        if curl -f http://localhost:$port/actuator/health > /dev/null 2>&1; then
            echo "✓ $service_name is ready"
            return 0
        fi
        echo "Waiting for $service_name... ($i/$max_attempts)"
        sleep 3
    done
    echo "✗ $service_name failed to start"
    return 1
}

# Start Eureka Server
echo "Starting Eureka Server..."
nohup java -jar \
    -Dserver.port=$EUREKA_PORT \
    -Dspring.profiles.active=production \
    eureka-server.jar > logs/eureka.log 2>&1 &
EUREKA_PID=$!

# Wait for Eureka to be ready
wait_for_service $EUREKA_PORT "Eureka Server"

# Start Gateway
echo "Starting Gateway..."
nohup java -jar \
    -Dserver.port=$GATEWAY_PORT \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
    gateway.jar > logs/gateway.log 2>&1 &
GATEWAY_PID=$!

# Start Products Service
echo "Starting Products Service..."
nohup java -jar \
    -Dserver.port=$PRODUCTS_PORT \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
    products.jar > logs/products.log 2>&1 &
PRODUCTS_PID=$!

# Start Sales Service  
echo "Starting Sales Service..."
nohup java -jar \
    -Dserver.port=$SALES_PORT \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
    sales.jar > logs/sales.log 2>&1 &
SALES_PID=$!

echo "========================================"
echo "✓ All services started successfully!"
echo "PIDs: Eureka=$EUREKA_PID, Gateway=$GATEWAY_PID, Products=$PRODUCTS_PID, Sales=$SALES_PID"
echo "========================================"

# Function to handle shutdown
shutdown_handler() {
    echo "Received shutdown signal..."
    echo "Stopping all services gracefully..."
    kill $EUREKA_PID $GATEWAY_PID $PRODUCTS_PID $SALES_PID 2>/dev/null
    wait
    echo "All services stopped."
    exit 0
}

# Set up signal handlers
trap shutdown_handler SIGTERM SIGINT

# Keep container running
echo "Services are running. Container will stay alive..."
while true; do
    # Check if all processes are still running
    if ! kill -0 $EUREKA_PID 2>/dev/null; then
        echo "Eureka Server died, restarting..."
        nohup java -jar -Dserver.port=$EUREKA_PORT eureka-server.jar > logs/eureka.log 2>&1 &
        EUREKA_PID=$!
    fi
    
    if ! kill -0 $GATEWAY_PID 2>/dev/null; then
        echo "Gateway died, restarting..."
        nohup java -jar -Dserver.port=$GATEWAY_PORT gateway.jar > logs/gateway.log 2>&1 &
        GATEWAY_PID=$!
    fi
    
    if ! kill -0 $PRODUCTS_PID 2>/dev/null; then
        echo "Products Service died, restarting..."
        nohup java -jar -Dserver.port=$PRODUCTS_PORT products.jar > logs/products.log 2>&1 &
        PRODUCTS_PID=$!
    fi
    
    if ! kill -0 $SALES_PID 2>/dev/null; then
        echo "Sales Service died, restarting..."
        nohup java -jar -Dserver.port=$SALES_PORT sales.jar > logs/sales.log 2>&1 &
        SALES_PID=$!
    fi
    
    sleep 10
done
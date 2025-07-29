#!/bin/bash

# Railway startup with detailed logging and error handling
set -e

echo "=== ABC Motor Railway Startup with Diagnostics ==="
echo "Current time: $(date)"
echo "Working directory: $(pwd)"
echo "Process ID: $$"

# Environment setup
export EUREKA_PORT=${EUREKA_PORT:-8761}
export GATEWAY_PORT=${PORT:-8080}
export JAVA_OPTS="-Xmx512m -Djava.security.egd=file:/dev/./urandom"

echo "Configuration:"
echo "- EUREKA_PORT: $EUREKA_PORT"
echo "- GATEWAY_PORT: $GATEWAY_PORT"
echo "- PORT (Railway): $PORT"
echo "- JAVA_OPTS: $JAVA_OPTS"
echo ""

# Verify JAR files
echo "=== Verifying JAR files ==="
for jar in eureka-server.jar gateway.jar; do
    if [ -f "$jar" ]; then
        echo "✓ $jar exists ($(du -h $jar | cut -f1))"
    else
        echo "✗ $jar NOT FOUND"
        exit 1
    fi
done
echo ""

# Create logs directory
mkdir -p logs

# Function to check if port is available
check_port() {
    local port=$1
    if netstat -ln 2>/dev/null | grep -q ":$port "; then
        echo "Port $port is already in use"
        return 1
    fi
    return 0
}

# Function to wait for service with better error handling
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    
    echo "Waiting for $service_name on port $port..."
    for i in $(seq 1 $max_attempts); do
        if curl -f -s http://localhost:$port/actuator/health > /dev/null 2>&1; then
            echo "✓ $service_name is healthy on port $port"
            return 0
        fi
        
        # Check if process is still running
        if [ ! -z "${!3}" ] && ! kill -0 ${!3} 2>/dev/null; then
            echo "✗ $service_name process died (PID was ${!3})"
            return 1
        fi
        
        echo "[$i/$max_attempts] Waiting for $service_name..."
        sleep 3
    done
    
    echo "✗ $service_name failed to become healthy after $((max_attempts * 3)) seconds"
    
    # Show logs if available
    local log_file="logs/${service_name,,}.log"
    if [ -f "$log_file" ]; then
        echo "Last 10 lines of $log_file:"
        tail -10 "$log_file"
    fi
    
    return 1
}

# Trap to handle cleanup
cleanup() {
    echo "Received shutdown signal..."
    if [ ! -z "$EUREKA_PID" ]; then
        echo "Stopping Eureka (PID: $EUREKA_PID)"
        kill $EUREKA_PID 2>/dev/null || true
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start Eureka Server
echo "=== Starting Eureka Server ==="
java -jar $JAVA_OPTS \
    -Dserver.port=$EUREKA_PORT \
    -Dspring.profiles.active=production \
    eureka-server.jar > logs/eureka.log 2>&1 &
EUREKA_PID=$!

echo "Eureka started with PID: $EUREKA_PID"

# Wait for Eureka to be healthy
if ! wait_for_service $EUREKA_PORT "Eureka" EUREKA_PID; then
    echo "Failed to start Eureka Server"
    exit 1
fi

echo "=== Starting Gateway ==="
echo "Gateway will be the main process (foreground)"

# Start Gateway in foreground (main process for Railway)
exec java -jar $JAVA_OPTS \
    -Dserver.port=$GATEWAY_PORT \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
    gateway.jar

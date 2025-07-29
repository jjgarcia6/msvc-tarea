#!/bin/bash

# ==============================================
# ABC Motor - Multi-Service Startup Script
# Starts all microservices in the correct order
# ==============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting ABC Motor Microservices Suite...${NC}"
echo -e "${BLUE}==============================================${NC}"

# Set default environment variables if not provided
export EUREKA_PORT=${EUREKA_PORT:-8761}
export GATEWAY_PORT=${GATEWAY_PORT:-8080}
export PRODUCTS_PORT=${PRODUCTS_PORT:-8081}
export SALES_PORT=${SALES_PORT:-8082}

# For Railway, use PORT for gateway (main entry point)
export GATEWAY_PORT=${PORT:-8080}

echo -e "${YELLOW}📋 Configuration:${NC}"
echo -e "  • Eureka Server Port: ${EUREKA_PORT}"
echo -e "  • Gateway Port: ${GATEWAY_PORT}"
echo -e "  • Products Port: ${PRODUCTS_PORT}"
echo -e "  • Sales Port: ${SALES_PORT}"
echo ""

# Function to wait for service to be ready
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    echo -e "${YELLOW}⏳ Waiting for ${service_name} to be ready on port ${port}...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:${port}/actuator/health > /dev/null 2>&1; then
            echo -e "${GREEN}✅ ${service_name} is ready!${NC}"
            return 0
        fi
        
        echo -e "   Attempt ${attempt}/${max_attempts} - ${service_name} not ready yet..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ ${service_name} failed to start within expected time${NC}"
    return 1
}

# ==============================================
# START EUREKA SERVER (Service Registry)
# ==============================================
echo -e "${PURPLE}🏢 Starting Eureka Server...${NC}"
java -jar \
    -Dserver.port=${EUREKA_PORT} \
    -Dspring.profiles.active=production \
    -Deureka.instance.hostname=${RAILWAY_PUBLIC_DOMAIN:-localhost} \
    -Deureka.instance.non-secure-port=${EUREKA_PORT} \
    eureka-server.jar > eureka.log 2>&1 &

EUREKA_PID=$!
echo "Eureka Server PID: $EUREKA_PID"

# Wait for Eureka to be ready
wait_for_service $EUREKA_PORT "Eureka Server"

# ==============================================
# START API GATEWAY
# ==============================================
echo -e "${PURPLE}🌐 Starting API Gateway...${NC}"
java -jar \
    -Dserver.port=${GATEWAY_PORT} \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:${EUREKA_PORT}/eureka/ \
    -Deureka.instance.hostname=${RAILWAY_PUBLIC_DOMAIN:-localhost} \
    -Deureka.instance.non-secure-port=${GATEWAY_PORT} \
    gateway.jar > gateway.log 2>&1 &

GATEWAY_PID=$!
echo "Gateway PID: $GATEWAY_PID"

# Wait for Gateway to be ready
sleep 20

# ==============================================
# START PRODUCTS SERVICE
# ==============================================
echo -e "${PURPLE}📦 Starting Products Service...${NC}"
java -jar \
    -Dserver.port=${PRODUCTS_PORT} \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:${EUREKA_PORT}/eureka/ \
    -Deureka.instance.hostname=${RAILWAY_PUBLIC_DOMAIN:-localhost} \
    -Deureka.instance.non-secure-port=${PRODUCTS_PORT} \
    -Dspring.data.mongodb.uri="${MONGODB_URI}" \
    products.jar > products.log 2>&1 &

PRODUCTS_PID=$!
echo "Products Service PID: $PRODUCTS_PID"

# Wait for Products to be ready
sleep 25

# ==============================================
# START SALES SERVICE
# ==============================================
echo -e "${PURPLE}🛒 Starting Sales Service...${NC}"
java -jar \
    -Dserver.port=${SALES_PORT} \
    -Dspring.profiles.active=production \
    -Deureka.client.service-url.defaultZone=http://localhost:${EUREKA_PORT}/eureka/ \
    -Deureka.instance.hostname=${RAILWAY_PUBLIC_DOMAIN:-localhost} \
    -Deureka.instance.non-secure-port=${SALES_PORT} \
    sales.jar > sales.log 2>&1 &

SALES_PID=$!
echo "Sales Service PID: $SALES_PID"

# Wait for all services to be ready
sleep 30

echo ""
echo -e "${GREEN}🎉 All services started successfully!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "${BLUE}📊 Service Information:${NC}"
echo -e "  • Eureka Server: http://localhost:${EUREKA_PORT}"
echo -e "  • API Gateway: http://localhost:${GATEWAY_PORT}"
echo -e "  • Products Service: http://localhost:${PRODUCTS_PORT}"
echo -e "  • Sales Service: http://localhost:${SALES_PORT}"
echo ""
echo -e "${BLUE}🌐 API Endpoints:${NC}"
echo -e "  • Products API: http://localhost:${GATEWAY_PORT}/msvc-products/api/products"
echo -e "  • Sales API: http://localhost:${GATEWAY_PORT}/msvc-sales/api/item"
echo -e "  • Swagger Products: http://localhost:${GATEWAY_PORT}/msvc-products/swagger-ui.html"
echo -e "  • Swagger Sales: http://localhost:${GATEWAY_PORT}/msvc-sales/swagger-ui.html"
echo ""
echo -e "${YELLOW}📋 Process IDs:${NC}"
echo -e "  • Eureka: $EUREKA_PID"
echo -e "  • Gateway: $GATEWAY_PID"  
echo -e "  • Products: $PRODUCTS_PID"
echo -e "  • Sales: $SALES_PID"
echo ""

# Function to handle shutdown gracefully
shutdown_services() {
    echo -e "\n${YELLOW}🛑 Shutting down services gracefully...${NC}"
    
    echo "Stopping Sales Service..."
    kill -TERM $SALES_PID 2>/dev/null || true
    
    echo "Stopping Products Service..."
    kill -TERM $PRODUCTS_PID 2>/dev/null || true
    
    echo "Stopping Gateway..."
    kill -TERM $GATEWAY_PID 2>/dev/null || true
    
    echo "Stopping Eureka Server..."
    kill -TERM $EUREKA_PID 2>/dev/null || true
    
    # Wait for processes to terminate
    sleep 10
    
    echo -e "${GREEN}✅ All services stopped${NC}"
    exit 0
}

# Trap signals for graceful shutdown
trap shutdown_services SIGTERM SIGINT

# Keep the script running and monitor processes
while true; do
    # Check if all processes are still running
    if ! kill -0 $EUREKA_PID 2>/dev/null; then
        echo -e "${RED}❌ Eureka Server died unexpectedly${NC}"
        exit 1
    fi
    
    if ! kill -0 $GATEWAY_PID 2>/dev/null; then
        echo -e "${RED}❌ Gateway died unexpectedly${NC}"
        exit 1
    fi
    
    if ! kill -0 $PRODUCTS_PID 2>/dev/null; then
        echo -e "${RED}❌ Products Service died unexpectedly${NC}"
        exit 1
    fi
    
    if ! kill -0 $SALES_PID 2>/dev/null; then
        echo -e "${RED}❌ Sales Service died unexpectedly${NC}"
        exit 1
    fi
    
    # All services are running, wait before next check
    sleep 30
done

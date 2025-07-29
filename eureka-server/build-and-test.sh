#!/bin/bash

# =====================================================
# ABC Motor - Local Build & Test Script
# Builds and tests the multi-service Docker container
# =====================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏗️  ABC Motor - Local Build & Test${NC}"
echo -e "${BLUE}=====================================${NC}"

# Configuration
IMAGE_NAME="abc-motor-microservices"
CONTAINER_NAME="abc-motor-test"
MONGODB_URI=${MONGODB_URI:-"mongodb+srv://username:password@cluster.mongodb.net/abcmotor?retryWrites=true&w=majority"}

# Navigate to project root (where eureka-server folder is)
cd "$(dirname "$0")"

echo -e "${YELLOW}📂 Current directory: $(pwd)${NC}"

# Check if Dockerfile exists
if [ ! -f "eureka-server/Dockerfile" ]; then
    echo -e "${RED}❌ Dockerfile not found in eureka-server/ directory${NC}"
    exit 1
fi

# Step 1: Clean up previous builds
echo -e "\n${PURPLE}🧹 Cleaning up previous builds...${NC}"
docker rm -f $CONTAINER_NAME 2>/dev/null || true
docker rmi $IMAGE_NAME 2>/dev/null || true

# Step 2: Build the multi-service image
echo -e "\n${PURPLE}🔨 Building multi-service Docker image...${NC}"
echo -e "${YELLOW}This may take several minutes...${NC}"

if docker build -t $IMAGE_NAME -f eureka-server/Dockerfile .; then
    echo -e "${GREEN}✅ Docker image built successfully!${NC}"
else
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
fi

# Step 3: Show image info
echo -e "\n${BLUE}📊 Image Information:${NC}"
docker images $IMAGE_NAME

# Step 4: Run the container
echo -e "\n${PURPLE}🚀 Starting multi-service container...${NC}"
echo -e "${YELLOW}⚠️  Make sure MongoDB URI is configured correctly${NC}"

docker run -d \
    --name $CONTAINER_NAME \
    -p 8761:8761 \
    -p 8080:8080 \
    -p 8081:8081 \
    -p 8082:8082 \
    -e MONGODB_URI="$MONGODB_URI" \
    -e SPRING_PROFILES_ACTIVE=production \
    -e EUREKA_PORT=8761 \
    -e GATEWAY_PORT=8080 \
    -e PRODUCTS_PORT=8081 \
    -e SALES_PORT=8082 \
    $IMAGE_NAME

echo -e "${GREEN}✅ Container started successfully!${NC}"
echo -e "${BLUE}Container Name: $CONTAINER_NAME${NC}"

# Step 5: Monitor startup
echo -e "\n${PURPLE}📋 Monitoring service startup...${NC}"
echo -e "${YELLOW}This will take 2-3 minutes for all services to be ready${NC}"

# Wait for initial startup
sleep 10

# Show logs for the first 60 seconds
echo -e "\n${BLUE}📋 Container Logs (first 60 seconds):${NC}"
timeout 60s docker logs -f $CONTAINER_NAME || true

# Step 6: Health check
echo -e "\n${PURPLE}🏥 Running health checks...${NC}"
sleep 5

# Wait a bit more for services to stabilize
echo -e "${YELLOW}⏳ Waiting for services to stabilize...${NC}"
sleep 30

# Test service endpoints
echo -e "\n${BLUE}🔍 Testing service endpoints:${NC}"

echo -n -e "${YELLOW}Testing Eureka Server...${NC} "
if curl -f -s http://localhost:8761/actuator/health > /dev/null; then
    echo -e "${GREEN}✅ ONLINE${NC}"
else
    echo -e "${RED}❌ OFFLINE${NC}"
fi

echo -n -e "${YELLOW}Testing Gateway...${NC} "
if curl -f -s http://localhost:8080/actuator/health > /dev/null; then
    echo -e "${GREEN}✅ ONLINE${NC}"
else
    echo -e "${RED}❌ OFFLINE${NC}"
fi

echo -n -e "${YELLOW}Testing Products Service...${NC} "
if curl -f -s http://localhost:8081/api/actuator/health > /dev/null; then
    echo -e "${GREEN}✅ ONLINE${NC}"
else
    echo -e "${RED}❌ OFFLINE${NC}"
fi

echo -n -e "${YELLOW}Testing Sales Service...${NC} "
if curl -f -s http://localhost:8082/api/actuator/health > /dev/null; then
    echo -e "${GREEN}✅ ONLINE${NC}"
else
    echo -e "${RED}❌ OFFLINE${NC}"
fi

# Step 7: Show useful information
echo -e "\n${GREEN}🎉 Local Test Environment Ready!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo -e "${BLUE}🌐 Available Services:${NC}"
echo -e "  • Eureka Dashboard: http://localhost:8761"
echo -e "  • API Gateway: http://localhost:8080"
echo -e "  • Products API: http://localhost:8080/msvc-products/api/products"
echo -e "  • Sales API: http://localhost:8080/msvc-sales/api/item"
echo ""
echo -e "${BLUE}📚 API Documentation:${NC}"
echo -e "  • Products Swagger: http://localhost:8080/msvc-products/swagger-ui.html"
echo -e "  • Sales Swagger: http://localhost:8080/msvc-sales/swagger-ui.html"
echo ""
echo -e "${BLUE}🔧 Management Commands:${NC}"
echo -e "  • View logs: ${YELLOW}docker logs -f $CONTAINER_NAME${NC}"
echo -e "  • Health check: ${YELLOW}docker exec $CONTAINER_NAME ./health-check.sh${NC}"
echo -e "  • Stop container: ${YELLOW}docker stop $CONTAINER_NAME${NC}"
echo -e "  • Remove container: ${YELLOW}docker rm $CONTAINER_NAME${NC}"
echo ""
echo -e "${PURPLE}💡 Testing Tips:${NC}"
echo -e "  • Wait 3-5 minutes for all services to fully initialize"
echo -e "  • Check Eureka dashboard to see registered services"
echo -e "  • Use Swagger UI for API testing"
echo -e "  • Monitor logs for any startup issues"
echo ""

# Step 8: Keep monitoring (optional)
echo -e "${YELLOW}📋 Container is running in background${NC}"
echo -e "${YELLOW}Press Ctrl+C to exit this script (container will keep running)${NC}"

# Function to handle cleanup on script exit
cleanup() {
    echo -e "\n${YELLOW}🛑 Script terminated${NC}"
    echo -e "${BLUE}Container $CONTAINER_NAME is still running${NC}"
    echo -e "${BLUE}Use 'docker stop $CONTAINER_NAME' to stop it${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Monitor logs indefinitely until user stops
echo -e "\n${BLUE}📋 Live Logs (Press Ctrl+C to exit):${NC}"
docker logs -f $CONTAINER_NAME || true

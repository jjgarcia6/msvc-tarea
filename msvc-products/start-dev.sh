#!/bin/bash

# ABC Motor - Development Startup Script

echo "🚀 Starting ABC Motor Microservices Development Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose is not installed. Please install it first.${NC}"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  No .env file found. Creating from template...${NC}"
    cp .env.docker .env
    echo -e "${GREEN}✅ .env file created. Please update with your MongoDB credentials if needed.${NC}"
fi

echo -e "${BLUE}📦 Building and starting services...${NC}"

# Build and start services
docker-compose up --build -d

echo -e "${GREEN}✅ Services are starting up...${NC}"
echo ""
echo -e "${BLUE}📊 Service Status:${NC}"
docker-compose ps

echo ""
echo -e "${BLUE}🌐 Available URLs:${NC}"
echo -e "  • Eureka Server: ${GREEN}http://localhost:8761${NC}"
echo -e "  • API Gateway: ${GREEN}http://localhost:8080${NC}"
echo -e "  • Products API: ${GREEN}http://localhost:8080/msvc-products/api/products${NC}"
echo -e "  • Sales API: ${GREEN}http://localhost:8080/msvc-sales/api/item${NC}"
echo -e "  • Swagger Products: ${GREEN}http://localhost:8080/msvc-products/swagger-ui/index.html${NC}"
echo -e "  • Swagger Sales: ${GREEN}http://localhost:8080/msvc-sales/swagger-ui/index.html${NC}"

echo ""
echo -e "${YELLOW}💡 Useful Commands:${NC}"
echo -e "  • View logs: ${BLUE}docker-compose logs -f${NC}"
echo -e "  • Stop services: ${BLUE}docker-compose down${NC}"
echo -e "  • Restart service: ${BLUE}docker-compose restart <service-name>${NC}"
echo -e "  • View status: ${BLUE}docker-compose ps${NC}"

echo ""
echo -e "${GREEN}🎉 Development environment is ready!${NC}"

#!/bin/bash

# ================================================
# ABC Motor - Health Check Script
# Verifies all microservices are running properly
# ================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Service configuration
EUREKA_PORT=${EUREKA_PORT:-8761}
GATEWAY_PORT=${GATEWAY_PORT:-8080}
PRODUCTS_PORT=${PRODUCTS_PORT:-8081}
SALES_PORT=${SALES_PORT:-8082}

# For Railway, use PORT for gateway
GATEWAY_PORT=${PORT:-8080}

# Health check timeout
TIMEOUT=10

echo -e "${BLUE}🏥 ABC Motor - Health Check${NC}"
echo -e "${BLUE}===========================${NC}"

# Function to check service health
check_service_health() {
    local port=$1
    local service_name=$2
    local endpoint=$3
    
    echo -n -e "${YELLOW}Checking ${service_name}...${NC} "
    
    # Use curl with timeout to check health endpoint
    if curl -f -s --connect-timeout $TIMEOUT --max-time $TIMEOUT \
        "http://localhost:${port}${endpoint}" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ HEALTHY${NC}"
        return 0
    else
        echo -e "${RED}❌ UNHEALTHY${NC}"
        return 1
    fi
}

# Function to check basic port availability
check_port() {
    local port=$1
    local service_name=$2
    
    echo -n -e "${YELLOW}Checking ${service_name} port ${port}...${NC} "
    
    if nc -z localhost $port 2>/dev/null; then
        echo -e "${GREEN}✅ OPEN${NC}"
        return 0
    else
        echo -e "${RED}❌ CLOSED${NC}"
        return 1
    fi
}

# Check if netcat is available, if not use basic port check with timeout
if ! command -v nc &> /dev/null; then
    echo -e "${YELLOW}⚠️  netcat not available, using basic connectivity checks${NC}"
    USE_NC=false
else
    USE_NC=true
fi

# Initialize health status
EUREKA_HEALTHY=false
GATEWAY_HEALTHY=false
PRODUCTS_HEALTHY=false
SALES_HEALTHY=false

# ==============================================
# CHECK EUREKA SERVER
# ==============================================
echo -e "\n${BLUE}🏢 Eureka Server (Service Registry)${NC}"
if $USE_NC; then
    if check_port $EUREKA_PORT "Eureka Server"; then
        if check_service_health $EUREKA_PORT "Eureka Health" "/actuator/health"; then
            EUREKA_HEALTHY=true
        fi
    fi
else
    if check_service_health $EUREKA_PORT "Eureka Server" "/actuator/health"; then
        EUREKA_HEALTHY=true
    fi
fi

# ==============================================
# CHECK API GATEWAY
# ==============================================
echo -e "\n${BLUE}🌐 API Gateway${NC}"
if $USE_NC; then
    if check_port $GATEWAY_PORT "Gateway"; then
        if check_service_health $GATEWAY_PORT "Gateway Health" "/actuator/health"; then
            GATEWAY_HEALTHY=true
        fi
    fi
else
    if check_service_health $GATEWAY_PORT "Gateway" "/actuator/health"; then
        GATEWAY_HEALTHY=true
    fi
fi

# ==============================================
# CHECK PRODUCTS SERVICE
# ==============================================
echo -e "\n${BLUE}📦 Products Service${NC}"
if $USE_NC; then
    if check_port $PRODUCTS_PORT "Products Service"; then
        if check_service_health $PRODUCTS_PORT "Products Health" "/actuator/health"; then
            PRODUCTS_HEALTHY=true
        fi
    fi
else
    if check_service_health $PRODUCTS_PORT "Products Service" "/actuator/health"; then
        PRODUCTS_HEALTHY=true
    fi
fi

# ==============================================
# CHECK SALES SERVICE
# ==============================================
echo -e "\n${BLUE}🛒 Sales Service${NC}"
if $USE_NC; then
    if check_port $SALES_PORT "Sales Service"; then
        if check_service_health $SALES_PORT "Sales Health" "/actuator/health"; then
            SALES_HEALTHY=true
        fi
    fi
else
    if check_service_health $SALES_PORT "Sales Service" "/actuator/health"; then
        SALES_HEALTHY=true
    fi
fi

# ==============================================
# SUMMARY
# ==============================================
echo -e "\n${BLUE}📊 Health Check Summary${NC}"
echo -e "${BLUE}========================${NC}"

TOTAL_SERVICES=4
HEALTHY_SERVICES=0

echo -e "Eureka Server:   $(if $EUREKA_HEALTHY; then echo -e "${GREEN}✅ HEALTHY${NC}"; HEALTHY_SERVICES=$((HEALTHY_SERVICES + 1)); else echo -e "${RED}❌ UNHEALTHY${NC}"; fi)"
echo -e "API Gateway:     $(if $GATEWAY_HEALTHY; then echo -e "${GREEN}✅ HEALTHY${NC}"; HEALTHY_SERVICES=$((HEALTHY_SERVICES + 1)); else echo -e "${RED}❌ UNHEALTHY${NC}"; fi)"
echo -e "Products Service: $(if $PRODUCTS_HEALTHY; then echo -e "${GREEN}✅ HEALTHY${NC}"; HEALTHY_SERVICES=$((HEALTHY_SERVICES + 1)); else echo -e "${RED}❌ UNHEALTHY${NC}"; fi)"
echo -e "Sales Service:   $(if $SALES_HEALTHY; then echo -e "${GREEN}✅ HEALTHY${NC}"; HEALTHY_SERVICES=$((HEALTHY_SERVICES + 1)); else echo -e "${RED}❌ UNHEALTHY${NC}"; fi)"

echo ""
echo -e "Services Status: ${HEALTHY_SERVICES}/${TOTAL_SERVICES} healthy"

# Overall health status
if [ $HEALTHY_SERVICES -eq $TOTAL_SERVICES ]; then
    echo -e "${GREEN}🎉 ALL SERVICES ARE HEALTHY!${NC}"
    echo ""
    echo -e "${BLUE}🌐 Available Endpoints:${NC}"
    echo -e "  • Eureka Dashboard: http://localhost:${EUREKA_PORT}"
    echo -e "  • API Gateway: http://localhost:${GATEWAY_PORT}"
    echo -e "  • Products API: http://localhost:${GATEWAY_PORT}/msvc-products/api/products"
    echo -e "  • Sales API: http://localhost:${GATEWAY_PORT}/msvc-sales/api/item"
    echo -e "  • Products Swagger: http://localhost:${GATEWAY_PORT}/msvc-products/swagger-ui.html"
    echo -e "  • Sales Swagger: http://localhost:${GATEWAY_PORT}/msvc-sales/swagger-ui.html"
    exit 0
elif [ $HEALTHY_SERVICES -gt 0 ]; then
    echo -e "${YELLOW}⚠️  SOME SERVICES ARE UNHEALTHY${NC}"
    exit 1
else
    echo -e "${RED}💥 ALL SERVICES ARE DOWN!${NC}"
    exit 2
fi

#!/bin/bash

# ==============================================
# Health Check Script for all microservices
# ==============================================

EUREKA_PORT=${EUREKA_PORT:-8761}
GATEWAY_PORT=${PORT:-8080}
PRODUCTS_PORT=${PRODUCTS_PORT:-8081}
SALES_PORT=${SALES_PORT:-8082}

echo "=== Health Check Status ==="

# Check Eureka Server
if curl -f http://localhost:$EUREKA_PORT/actuator/health > /dev/null 2>&1; then
    echo "✓ Eureka Server: HEALTHY"
    EUREKA_OK=1
else
    echo "✗ Eureka Server: DOWN"
    EUREKA_OK=0
fi

# Check Gateway
if curl -f http://localhost:$GATEWAY_PORT/actuator/health > /dev/null 2>&1; then
    echo "✓ Gateway: HEALTHY"
    GATEWAY_OK=1
else
    echo "✗ Gateway: DOWN"
    GATEWAY_OK=0
fi

# Check Products Service
if curl -f http://localhost:$PRODUCTS_PORT/actuator/health > /dev/null 2>&1; then
    echo "✓ Products Service: HEALTHY"
    PRODUCTS_OK=1
else
    echo "✗ Products Service: DOWN"
    PRODUCTS_OK=0
fi

# Check Sales Service
if curl -f http://localhost:$SALES_PORT/actuator/health > /dev/null 2>&1; then
    echo "✓ Sales Service: HEALTHY"
    SALES_OK=1
else
    echo "✗ Sales Service: DOWN"
    SALES_OK=0
fi

echo "=========================="

# Return overall health status
if [ $EUREKA_OK -eq 1 ] && [ $GATEWAY_OK -eq 1 ] && [ $PRODUCTS_OK -eq 1 ] && [ $SALES_OK -eq 1 ]; then
    echo "Overall Status: ALL SERVICES HEALTHY"
    exit 0
else
    echo "Overall Status: SOME SERVICES DOWN"
    exit 1
fi
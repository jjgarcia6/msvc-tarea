#!/bin/bash

# Railway environment variables
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

# Start Eureka Server
echo "Starting Eureka Server..."
nohup java -jar -Dserver.port=$EUREKA_PORT eureka-server.jar > logs/eureka.log 2>&1 &
EUREKA_PID=$!

# Wait for Eureka to be ready
echo "Waiting for Eureka Server to start..."
for i in {1..30}; do
  if curl -f http://localhost:$EUREKA_PORT/actuator/health > /dev/null 2>&1; then
    echo "✓ Eureka Server is ready"
    break
  fi
  echo "Waiting for Eureka... ($i/30)"
  sleep 3
done

# Start Gateway
echo "Starting Gateway..."
nohup java -jar -Dserver.port=$GATEWAY_PORT \
  -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
  gateway.jar > logs/gateway.log 2>&1 &
GATEWAY_PID=$!

# Start Products Service
echo "Starting Products Service..."
nohup java -jar -Dserver.port=$PRODUCTS_PORT \
  -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
  products.jar > logs/products.log 2>&1 &
PRODUCTS_PID=$!

# Start Sales Service  
echo "Starting Sales Service..."
nohup java -jar -Dserver.port=$SALES_PORT \
  -Deureka.client.service-url.defaultZone=http://localhost:$EUREKA_PORT/eureka/ \
  sales.jar > logs/sales.log 2>&1 &
SALES_PID=$!

echo "All services started!"
echo "PIDs: Eureka=$EUREKA_PID, Gateway=$GATEWAY_PID, Products=$PRODUCTS_PID, Sales=$SALES_PID"

# Keep container running and handle shutdown gracefully
trap 'echo "Shutting down..."; kill $EUREKA_PID $GATEWAY_PID $PRODUCTS_PID $SALES_PID; exit' SIGTERM SIGINT

# Wait for any process to exit
wait
# ==============================================
# ABC Motor - Multi-Service Dockerfile
# Deploys all 4 microservices in a single container
# ==============================================

FROM openjdk:21-jdk-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    netcat-openbsd \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create directories for each service
RUN mkdir -p eureka-server gateway msvc-products msvc-sales

# ==============================================
# BUILD EUREKA SERVER
# ==============================================
COPY eureka-server/mvnw ./eureka-server/
COPY eureka-server/.mvn ./eureka-server/.mvn/
COPY eureka-server/pom.xml ./eureka-server/
RUN chmod +x ./eureka-server/mvnw

WORKDIR /app/eureka-server
RUN ./mvnw dependency:go-offline -B

COPY eureka-server/src ./src/
RUN ./mvnw clean package -DskipTests
RUN cp target/eureka-server-0.0.1-SNAPSHOT.jar /app/eureka-server.jar

# ==============================================
# BUILD GATEWAY
# ==============================================
WORKDIR /app
COPY gateway/mvnw ./gateway/
COPY gateway/.mvn ./gateway/.mvn/
COPY gateway/pom.xml ./gateway/
RUN chmod +x ./gateway/mvnw

WORKDIR /app/gateway
RUN ./mvnw dependency:go-offline -B

COPY gateway/src ./src/
RUN ./mvnw clean package -DskipTests
RUN cp target/gateway-0.0.1-SNAPSHOT.jar /app/gateway.jar

# ==============================================
# BUILD PRODUCTS SERVICE
# ==============================================
WORKDIR /app
COPY msvc-products/mvnw ./msvc-products/
COPY msvc-products/.mvn ./msvc-products/.mvn/
COPY msvc-products/pom.xml ./msvc-products/
RUN chmod +x ./msvc-products/mvnw

WORKDIR /app/msvc-products
RUN ./mvnw dependency:go-offline -B

COPY msvc-products/src ./src/
RUN ./mvnw clean package -DskipTests
RUN cp target/msvc-products-0.0.1-SNAPSHOT.jar /app/products.jar

# ==============================================
# BUILD SALES SERVICE
# ==============================================
WORKDIR /app
COPY msvc-sales/mvnw ./msvc-sales/
COPY msvc-sales/.mvn ./msvc-sales/.mvn/
COPY msvc-sales/pom.xml ./msvc-sales/
RUN chmod +x ./msvc-sales/mvnw

WORKDIR /app/msvc-sales
RUN ./mvnw dependency:go-offline -B

COPY msvc-sales/src ./src/
RUN ./mvnw clean package -DskipTests
RUN cp target/msvc-sales-0.0.1-SNAPSHOT.jar /app/sales.jar

# ==============================================
# RUNTIME SETUP
# ==============================================
WORKDIR /app

# Clean up build directories to reduce image size
RUN rm -rf eureka-server gateway msvc-products msvc-sales

# Copy startup script
COPY start-services.sh ./
RUN chmod +x start-services.sh

# Copy health check script
COPY health-check.sh ./
RUN chmod +x health-check.sh

# Expose ports
EXPOSE 8761 8080 8081 8082

# Health check for the container
HEALTHCHECK --interval=60s --timeout=30s --start-period=120s --retries=3 \
  CMD ./health-check.sh

# Start all services
CMD ["./start-services.sh"]

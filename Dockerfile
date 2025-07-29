# ==============================================
# ABC Motor - Multi-Service Dockerfile (Fixed# Copy startup and health check scripts
COPY start-services.sh ./
COPY health-check.sh ./
COPY entrypoint.sh ./
COPY railway-start.sh ./
COPY railway-debug.sh ./
COPY railway-production.sh ./

# Fix line endings and permissions for Railway compatibility
RUN dos2unix start-services.sh health-check.sh entrypoint.sh railway-start.sh railway-debug.sh railway-production.sh 2>/dev/null || true && \
    chmod +x start-services.sh health-check.sh entrypoint.sh railway-start.sh railway-debug.sh railway-production.sh && \
    ls -la *.sh && \
    echo "=== Verifying key scripts ===" && \
    head -3 railway-production.shall 4 microservices in a single container
# ==============================================

FROM eclipse-temurin:21-jdk-alpine as builder

# Install required packages for build
RUN apk add --no-cache curl wget

# Set working directory
WORKDIR /app

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
RUN ./mvnw clean package -DskipTests -q

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
RUN ./mvnw clean package -DskipTests -q

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
RUN ./mvnw clean package -DskipTests -q

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
RUN ./mvnw clean package -DskipTests -q

# ==============================================
# RUNTIME STAGE (Smaller final image)
# ==============================================
FROM eclipse-temurin:21-jre-alpine

# Install runtime packages (Alpine Linux)
RUN apk add --no-cache \
    curl \
    wget \
    netcat-openbsd \
    procps \
    dos2unix \
    file \
    bash \
    net-tools

WORKDIR /app

# Copy JAR files from builder stage
COPY --from=builder /app/eureka-server/target/eureka-server-*.jar ./eureka-server.jar
COPY --from=builder /app/gateway/target/gateway-*.jar ./gateway.jar
COPY --from=builder /app/msvc-products/target/msvc-products-*.jar ./products.jar
COPY --from=builder /app/msvc-sales/target/msvc-sales-*.jar ./sales.jar

# Copy startup and health check scripts
COPY start-services.sh ./
COPY health-check.sh ./
COPY entrypoint.sh ./
COPY railway-start.sh ./
COPY railway-debug.sh ./

# Fix line endings and permissions for Railway compatibility
RUN dos2unix start-services.sh health-check.sh entrypoint.sh railway-start.sh railway-debug.sh 2>/dev/null || true && \
    chmod +x start-services.sh health-check.sh entrypoint.sh railway-start.sh railway-debug.sh && \
    ls -la *.sh && \
    echo "=== Verifying key scripts ===" && \
    head -3 entrypoint.sh && \
    head -3 railway-start.sh

# Create logs directory
RUN mkdir -p logs

# Railway uses $PORT, but we also expose common ports
EXPOSE $PORT 8761 8080

# Health check optimized for Railway - longer timeout for startup
HEALTHCHECK --interval=45s --timeout=30s --start-period=120s --retries=5 \
  CMD curl -f http://localhost:${PORT:-8080}/actuator/health || exit 1

# Start all services - use production script with diagnostics
CMD ["/bin/bash", "/app/railway-production.sh"]
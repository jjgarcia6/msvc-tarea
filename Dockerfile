# ==============================================
# ABC Motor - Multi-Service Dockerfile (Optimized)
# Deploys all 4 microservices in a single container
# ==============================================

FROM openjdk:21-jdk-slim as builder

# Install required packages for build
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

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
FROM openjdk:21-jre-slim

# Install runtime packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    netcat-openbsd \
    procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy JAR files from builder stage
COPY --from=builder /app/eureka-server/target/eureka-server-*.jar ./eureka-server.jar
COPY --from=builder /app/gateway/target/gateway-*.jar ./gateway.jar
COPY --from=builder /app/msvc-products/target/msvc-products-*.jar ./products.jar
COPY --from=builder /app/msvc-sales/target/msvc-sales-*.jar ./sales.jar

# Copy startup and health check scripts
COPY start-services.sh ./
COPY health-check.sh ./
RUN chmod +x start-services.sh health-check.sh

# Create logs directory
RUN mkdir -p logs

# Railway uses $PORT, but we also expose common ports
EXPOSE $PORT 8761 8080

# Health check optimized for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
  CMD curl -f http://localhost:8761/actuator/health || exit 1

# Start all services
CMD ["./start-services.sh"]

@echo off
REM ABC Motor - Development Startup Script for Windows

echo 🚀 Starting ABC Motor Microservices Development Environment...

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running. Please start Docker first.
    pause
    exit /b 1
)

REM Create .env file if it doesn't exist
if not exist .env (
    echo ⚠️  No .env file found. Creating from template...
    copy .env.docker .env
    echo ✅ .env file created. Please update with your MongoDB credentials if needed.
)

echo 📦 Building and starting services...

REM Build and start services
docker-compose up --build -d

echo ✅ Services are starting up...
echo.
echo 📊 Service Status:
docker-compose ps

echo.
echo 🌐 Available URLs:
echo   • Eureka Server: http://localhost:8761
echo   • API Gateway: http://localhost:8080
echo   • Products API: http://localhost:8080/msvc-products/api/products
echo   • Sales API: http://localhost:8080/msvc-sales/api/item
echo   • Swagger Products: http://localhost:8080/msvc-products/swagger-ui/index.html
echo   • Swagger Sales: http://localhost:8080/msvc-sales/swagger-ui/index.html

echo.
echo 💡 Useful Commands:
echo   • View logs: docker-compose logs -f
echo   • Stop services: docker-compose down
echo   • Restart service: docker-compose restart ^<service-name^>
echo   • View status: docker-compose ps

echo.
echo 🎉 Development environment is ready!
pause

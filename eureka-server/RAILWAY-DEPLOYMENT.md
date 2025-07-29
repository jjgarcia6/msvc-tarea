# 🚂 Deployment Instructions for Railway

## ABC Motor - Microservices Deployment Guide

Este documento proporciona instrucciones detalladas para desplegar todos los microservicios de ABC Motor como un solo contenedor en Railway.

## 📋 Prerequisites

1. **Cuenta de Railway**: Crea una cuenta en [railway.app](https://railway.app)
2. **MongoDB Atlas**: Configura tu cluster de MongoDB Atlas
3. **Código fuente**: Asegúrate de tener todos los archivos del proyecto

## 🗂️ Project Structure

```
eureka-server/
├── Dockerfile                 # Multi-service Docker configuration
├── start-services.sh          # Service startup orchestration
├── health-check.sh           # Health monitoring script
└── ... (other eureka files)
```

## 🔧 Environment Variables Setup

En Railway, configura las siguientes variables de entorno:

### Database Configuration
```bash
# MongoDB Atlas connection string
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/abcmotor?retryWrites=true&w=majority

# Replace with your actual credentials:
# username: tu usuario de MongoDB Atlas
# password: tu password de MongoDB Atlas  
# cluster: tu cluster name (ej: cluster0.abc123.mongodb.net)
```

### Service Configuration (Railway will set PORT automatically)
```bash
# Railway sets PORT automatically for the main entry point (Gateway)
# Internal service ports (optional, defaults will be used):
EUREKA_PORT=8761
PRODUCTS_PORT=8081
SALES_PORT=8082

# For production
SPRING_PROFILES_ACTIVE=production
```

## 🚀 Deployment Steps

### Step 1: Prepare Repository
1. Asegúrate de que todos los archivos estén en tu repositorio
2. El `Dockerfile` debe estar en la carpeta `eureka-server/`
3. Verifica que los scripts tengan permisos de ejecución

### Step 2: Connect to Railway
1. Ve a [railway.app](https://railway.app)
2. Crea un nuevo proyecto
3. Conecta tu repositorio de GitHub/GitLab

### Step 3: Configure Build
1. **Root Directory**: Deja vacío (usará la raíz del proyecto)
2. **Build Command**: Railway detectará automáticamente el Dockerfile
3. **Start Command**: Se usará el CMD del Dockerfile

### Step 4: Set Environment Variables
En la sección de Variables de Railway:

```bash
MONGODB_URI=mongodb+srv://tu_usuario:tu_password@tu_cluster.mongodb.net/abcmotor?retryWrites=true&w=majority
SPRING_PROFILES_ACTIVE=production
```

### Step 5: Deploy
1. Haz push de tu código al repositorio
2. Railway iniciará el build automáticamente
3. Monitorea los logs durante el despliegue

## 📊 Service Startup Sequence

El contenedor iniciará los servicios en este orden:

1. **Eureka Server** (Port 8761) - Service Registry
2. **API Gateway** (Port from Railway's $PORT) - Main entry point  
3. **Products Service** (Port 8081) - Products management
4. **Sales Service** (Port 8082) - Sales management

## 🔍 Health Monitoring

### Container Health Check
El contenedor incluye un health check que verifica:
- ✅ Eureka Server status
- ✅ Gateway connectivity  
- ✅ Products service health
- ✅ Sales service health

### Manual Health Check
Puedes ejecutar manualmente desde Railway console:
```bash
./health-check.sh
```

## 🌐 API Endpoints

Una vez desplegado, tus endpoints serán:

```bash
# Railway proporcionará una URL como: https://tu-app.up.railway.app

# Service Discovery
GET https://tu-app.up.railway.app/eureka

# Products API
GET https://tu-app.up.railway.app/msvc-products/api/products
POST https://tu-app.up.railway.app/msvc-products/api/products

# Sales API  
GET https://tu-app.up.railway.app/msvc-sales/api/item
POST https://tu-app.up.railway.app/msvc-sales/api/item

# API Documentation
GET https://tu-app.up.railway.app/msvc-products/swagger-ui.html
GET https://tu-app.up.railway.app/msvc-sales/swagger-ui.html
```

## 🔧 Troubleshooting

### Common Issues

**1. Services not starting:**
```bash
# Check logs in Railway dashboard
# Look for MongoDB connection issues
# Verify environment variables
```

**2. MongoDB connection failed:**
```bash
# Verify MONGODB_URI format
# Check MongoDB Atlas IP whitelist (allow 0.0.0.0/0 for Railway)
# Confirm database user permissions
```

**3. Service registration issues:**
```bash
# Check Eureka Server logs
# Verify internal service communication
# Look for port conflicts
```

### Debugging Commands

En Railway console:
```bash
# Check running processes  
ps aux

# Check service logs
tail -f eureka.log
tail -f gateway.log
tail -f products.log
tail -f sales.log

# Test connectivity
curl http://localhost:8761/actuator/health
curl http://localhost:8080/actuator/health
```

## ⚙️ Configuration Details

### Dockerfile Highlights
- **Multi-stage build**: Optimized for size and security
- **Health checks**: Built-in monitoring
- **Environment variables**: Production-ready configuration
- **Service orchestration**: Proper startup sequence

### Scripts Functionality
- **start-services.sh**: Handles service startup with proper timing
- **health-check.sh**: Comprehensive health monitoring
- **Graceful shutdown**: SIGTERM handling for clean stops

## 📈 Performance Considerations

### Resource Usage
- **Memory**: Approximately 2-3GB RAM total for all services
- **CPU**: Moderate usage during startup, low during runtime
- **Storage**: ~500MB for application JARs

### Scaling Notes
- Este es un despliegue monolítico para testing/demo
- Para producción, considera desplegar servicios individualmente
- Railway maneja el scaling automático basado en tráfico

## 🔒 Security

### Best Practices Implemented
- ✅ No hardcoded credentials
- ✅ Environment variable configuration
- ✅ Health checks for monitoring
- ✅ Proper service isolation
- ✅ MongoDB Atlas with authentication

### Additional Security Recommendations
- Usa secrets management para credenciales sensibles
- Configura MongoDB IP whitelist apropiadamente
- Monitorea logs para intentos de acceso no autorizados
- Implementa rate limiting en el Gateway

## 📞 Support

Si encuentras problemas durante el despliegue:

1. **Check Railway logs**: Busca errores en los logs de build y runtime
2. **Verify environment variables**: Confirma que todas las variables estén configuradas
3. **Test MongoDB connection**: Verifica la conectividad a tu cluster
4. **Check health endpoints**: Usa los endpoints de health para debugging

## 🎯 Success Criteria

El despliegue es exitoso cuando:
- ✅ Todos los 4 servicios están corriendo
- ✅ Eureka Dashboard es accesible
- ✅ API Gateway responde correctamente
- ✅ Products y Sales APIs funcionan
- ✅ Swagger documentation es accesible
- ✅ Health checks pasan

¡Listo! Tu aplicación ABC Motor estará disponible en Railway con todos los microservicios funcionando como un solo contenedor optimizado. 🚀

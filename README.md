# ABC Motor - Sistema de Microservicios

![Java](https://img.shields.io/badge/Java-21-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.4-brightgreen)
![Spring Cloud Gateway](https://img.shields.io/badge/Spring%20Cloud-Gateway-blue)
![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-green)
![Netflix Eureka](https://img.shields.io/badge/Netflix-Eureka-blue)
![Swagger](https://img.shields.io/badge/Swagger-OpenAPI-brightgreen)
![Maven](https://img.shields.io/badge/Maven-3.6+-red)

## 📖 Descripción

ABC Motor es un sistema distribuido de microservicios desarrollado con **Spring Boot** y **Spring Cloud** que gestiona un catálogo de productos y sus ventas. El proyecto implementa patrones de arquitectura de microservicios incluyendo service discovery, balanceador de carga y comunicación entre servicios.

## 🏗️ Arquitectura del Sistema

```
                           ┌─────────────────┐
                           │  API Gateway    │
                           │  (Port: 8080)   │
                           │                 │
                      ┌────┤  Load Balancer  ├────┐
                      │    │ Route Handler   │    │
                      │    └─────────────────┘    │
                      │                           │
                      ▼                           ▼
         ┌─────────────────┐              ┌─────────────────┐
         │  msvc-products  │              │   msvc-sales    │
         │  (Port: 0/Auto) │              │  (Port: 0/Auto) │
         │                 │              │                 │
         │  Product Service├──────────────┤  Sales Service  │
         │                 │  Feign Call  │                 │
         │   MongoDB       │              │  Feign Client   │
         └─────────────────┘              └─────────────────┘
                      │                           │
                      │                           │
                      └────────┬──────────────────┘
                               │
                      ┌─────────────────┐
                      │   Eureka Server │
                      │   (Port: 8761)  │
                      │                 │
                      │ Service Registry│
                      └─────────────────┘
```

## 🚀 Microservicios

### 1. **API Gateway** - Punto de Entrada Único
- **Puerto**: 8080
- **Función**: Enrutamiento, balanceador de carga y punto de entrada único
- **Tecnologías**: Spring Cloud Gateway, WebFlux
- **Características**:
  - ✅ Enrutamiento automático de peticiones
  - ✅ Balanceador de carga integrado
  - ✅ Filtros personalizables
  - ✅ Integración con Eureka para descubrimiento

### 2. **Eureka Server** - Service Registry
- **Puerto**: 8761
- **Función**: Registro y descubrimiento de servicios
- **Tecnologías**: Netflix Eureka

### 3. **msvc-products** - Servicio de Productos
- **Puerto**: Dinámico (0/Auto)
- **Función**: Gestión del catálogo de productos
- **Base de datos**: MongoDB Atlas
- **Funcionalidades**:
  - ✅ CRUD completo de productos
  - ✅ Importación masiva desde CSV/Excel
  - ✅ Control de duplicados
  - ✅ Validación de datos
  - ✅ Manejo de imágenes y metadatos

### 4. **msvc-sales** - Servicio de Ventas
- **Puerto**: Dinámico (0/Auto)
- **Función**: Gestión de ítems de venta
- **Comunicación**: Feign Client con msvc-products
- **Funcionalidades**:
  - ✅ Gestión de ítems de venta
  - ✅ Cálculo de totales con IVA
  - ✅ Aplicación de descuentos
  - ✅ Integración con servicio de productos

## 📦 Modelo de Datos

### Product (msvc-products)
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "price": "double",
  "stock": "integer",
  "image": "string",
  "platforms": "string",
  "genres": "string",
  "discount": "double",
  "developer": "string",
  "publisher": "string",
  "release_date": "date",
  "port": "integer"
}
```

### Item (msvc-sales)
```json
{
  "id": "string",
  "product": "ProductDTO",
  "quantity": "integer",
  "total": "double",
  "totalWithIva": "double",
  "totalDiscount": "double"
}
```

## 🛠️ Tecnologías Utilizadas

- **Java 21** - Lenguaje de programación
- **Spring Boot 3.5.4** - Framework principal
- **Spring Cloud** - Herramientas para microservicios
- **Spring Cloud Gateway** - API Gateway reactivo
- **Netflix Eureka** - Service Discovery
- **OpenFeign** - Cliente HTTP declarativo
- **MongoDB Atlas** - Base de datos NoSQL en la nube
- **Apache POI** - Procesamiento de archivos Excel
- **OpenCSV** - Procesamiento de archivos CSV
- **SpringDoc OpenAPI** - Documentación automática de APIs (Swagger)
- **Maven** - Gestión de dependencias

## 🚦 Endpoints API

> **Importante**: Todos los endpoints están disponibles a través del **API Gateway** en el puerto **8080**. 
> 
> **URL Base del Gateway**: `http://localhost:8080`

### Acceso a través del Gateway:

#### msvc-products (a través del Gateway)
- **Base URL**: `http://localhost:8080/msvc-products`

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/msvc-products/api/products` | Obtener todos los productos |
| GET | `/msvc-products/api/products/{id}` | Obtener producto por ID |
| POST | `/msvc-products/api/products` | Crear nuevo producto |
| PUT | `/msvc-products/api/products/{id}` | Actualizar producto |
| DELETE | `/msvc-products/api/products/{id}` | Eliminar producto |
| POST | `/msvc-products/api/products/import` | Importar productos desde CSV/Excel |

#### msvc-sales (a través del Gateway)
- **Base URL**: `http://localhost:8080/msvc-sales`

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/msvc-sales/api/item` | Obtener todos los ítems |
| GET | `/msvc-sales/api/item/{id}` | Obtener ítem por ID |
| POST | `/msvc-sales/api/item` | Crear nuevo ítem |
| PUT | `/msvc-sales/api/item/{id}` | Actualizar cantidad de ítem |
| DELETE | `/msvc-sales/api/item/{id}` | Eliminar ítem |
| GET | `/msvc-sales/api/item/{id}/total` | Obtener total del ítem |
| GET | `/msvc-sales/api/item/{id}/total-with-iva` | Obtener total con IVA |
| GET | `/msvc-sales/api/item/{id}/discount` | Obtener descuento aplicado |

### Acceso Directo (sin Gateway):

#### msvc-products (`/api/products`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/products` | Obtener todos los productos |
| GET | `/api/products/{id}` | Obtener producto por ID |
| POST | `/api/products` | Crear nuevo producto |
| PUT | `/api/products/{id}` | Actualizar producto |
| DELETE | `/api/products/{id}` | Eliminar producto |
| POST | `/api/products/import` | Importar productos desde CSV/Excel |

#### msvc-sales (`/api/item`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/item` | Obtener todos los ítems |
| GET | `/api/item/{id}` | Obtener ítem por ID |
| POST | `/api/item` | Crear nuevo ítem |
| PUT | `/api/item/{id}` | Actualizar cantidad de ítem |
| DELETE | `/api/item/{id}` | Eliminar ítem |
| GET | `/api/item/{id}/total` | Obtener total del ítem |
| GET | `/api/item/{id}/total-with-iva` | Obtener total con IVA |
| GET | `/api/item/{id}/discount` | Obtener descuento aplicado |

## 📚 Documentación de API (Swagger)

Cada microservicio incluye documentación interactiva de API generada automáticamente con **SpringDoc OpenAPI**.

### Acceso a Swagger UI:

#### msvc-products
- **URL**: `http://localhost:{puerto}/swagger-ui/index.html`
- **A través del Gateway**: `http://localhost:8080/msvc-products/swagger-ui/index.html`
- **OpenAPI JSON**: `http://localhost:{puerto}/v3/api-docs`

#### msvc-sales  
- **URL**: `http://localhost:{puerto}/swagger-ui/index.html`
- **A través del Gateway**: `http://localhost:8080/msvc-sales/swagger-ui/index.html`
- **OpenAPI JSON**: `http://localhost:{puerto}/v3/api-docs`

### Funcionalidades de Swagger:
- ✅ **Documentación interactiva** de todos los endpoints
- ✅ **Probar APIs directamente** desde el navegador  
- ✅ **Esquemas de datos** automáticamente generados
- ✅ **Ejemplos de request/response**
- ✅ **Validación de parámetros** en tiempo real

> **Nota**: Los puertos son dinámicos (configuración `server.port=0`). Consulta los logs de arranque o el dashboard de Eureka para obtener el puerto asignado.

## ⚙️ Configuración

### Prerrequisitos
- **Java 21** o superior
- **Maven 3.6+**
- **MongoDB Atlas** (cuenta configurada)
- **IDE** (VS Code, IntelliJ IDEA, Eclipse)

### Variables de Entorno

Crear archivo `.env` en el directorio `msvc-products`:

```env
# MongoDB Atlas Configuration
MONGODB_USERNAME=tu_usuario
MONGODB_PASSWORD=tu_password
MONGODB_CLUSTER=tu_cluster.mongodb.net
MONGODB_DATABASE=products_db

# Alternative: Complete MongoDB URI
# MONGODB_URI=mongodb+srv://usuario:password@cluster.mongodb.net/products_db?retryWrites=true&w=majority
```

### Configuración de Base de Datos

**MongoDB Atlas URI**:
```properties
spring.data.mongodb.uri=${MONGODB_URI:mongodb+srv://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@${MONGODB_CLUSTER}/${MONGODB_DATABASE}?retryWrites=true&w=majority&appName=Cluster0}
```

## 🚀 Instalación y Ejecución

### Opción A: Desarrollo Rápido con Docker Compose (Recomendado)

#### 1. Prerrequisitos
- **Docker** y **Docker Compose** instalados
- **Git** para clonar el repositorio

#### 2. Ejecución con un solo comando
```bash
# Clonar el repositorio
git clone <repository-url>
cd msvc-tarea

# Mover docker-compose.yml a la raíz del proyecto
mv msvc-products/docker-compose.yml .
mv msvc-products/.env.docker .env

# Configurar variables de entorno (opcional)
# Editar .env con tus credenciales de MongoDB Atlas

# Ejecutar todo el sistema
docker-compose up --build
```

#### 3. Scripts de automatización
```bash
# Linux/Mac
chmod +x start-dev.sh
./start-dev.sh

# Windows
start-dev.bat
```

#### 4. Verificar servicios (Docker Compose)
- **Eureka Dashboard**: http://localhost:8761
- **API Gateway**: http://localhost:8080
- **Productos API**: http://localhost:8080/msvc-products/api/products
- **Sales API**: http://localhost:8080/msvc-sales/api/item
- **Swagger Products**: http://localhost:8080/msvc-products/swagger-ui/index.html
- **Swagger Sales**: http://localhost:8080/msvc-sales/swagger-ui/index.html

#### 5. Comandos útiles Docker Compose
```bash
# Ver logs en tiempo real
docker-compose logs -f

# Parar todos los servicios
docker-compose down

# Reiniciar un servicio específico
docker-compose restart msvc-products

# Ver estado de servicios
docker-compose ps

# Reconstruir y reiniciar
docker-compose up --build
```

### Opción B: Ejecución Manual (Desarrollo Individual)

#### 1. Clonar el repositorio
```bash
git clone <repository-url>
cd msvc-tarea
```

#### 2. Configurar variables de entorno
```bash
# Windows (PowerShell)
$env:MONGODB_USERNAME="tu_usuario"
$env:MONGODB_PASSWORD="tu_password"
$env:MONGODB_CLUSTER="tu_cluster.mongodb.net"
$env:MONGODB_DATABASE="products_db"
```

#### 3. Ejecutar los servicios (en orden)

##### Eureka Server
```bash
cd eureka-server
mvn spring-boot:run
```
**Acceso**: http://localhost:8761

##### API Gateway
```bash
cd gateway
mvn spring-boot:run
```
**Acceso**: http://localhost:8080

##### msvc-products
```bash
cd msvc-products
mvn spring-boot:run
```

##### msvc-sales
```bash
cd msvc-sales
mvn spring-boot:run
```

#### 4. Verificar servicios (Manual)
- **Eureka Dashboard**: http://localhost:8761
- **API Gateway**: http://localhost:8080
- **Productos API (Gateway)**: http://localhost:8080/msvc-products/api/products
- **Sales API (Gateway)**: http://localhost:8080/msvc-sales/api/item
- **Productos API (Directo)**: http://localhost:{puerto-dinamico}/api/products
- **Sales API (Directo)**: http://localhost:{puerto-dinamico}/api/item
- **Swagger UI Products (Gateway)**: http://localhost:8080/msvc-products/swagger-ui/index.html
- **Swagger UI Sales (Gateway)**: http://localhost:8080/msvc-sales/swagger-ui/index.html
- **Swagger UI Products (Directo)**: http://localhost:{puerto-dinamico}/swagger-ui/index.html
- **Swagger UI Sales (Directo)**: http://localhost:{puerto-dinamico}/swagger-ui/index.html

## 📊 Funcionalidades Destacadas

### 🔄 Importación Masiva de Productos
- **Formatos soportados**: CSV, Excel (.xlsx)
- **Control de duplicados**: Previene duplicados en BD y en archivo
- **Validación de datos**: Manejo de errores en tipos de datos
- **Campos requeridos**: name, description, price, stock, image, platforms, genres, discount, developer, publisher, release_date

### 🔍 Detección de Duplicados
```java
// Verifica duplicados en base de datos
if (productRepository.existsByName(productName)) {
    duplicatedProducts.add(productName);
    continue;
}

// Verifica duplicados en archivo actual
boolean alreadyInList = products.stream()
    .anyMatch(p -> p.getName().equalsIgnoreCase(productName));
```

### 🌐 Comunicación entre Microservicios
```java
@FeignClient(name = "msvc-products")
public interface ProductFeignClient {
    @GetMapping("api/products")
    List<ProductDTO> getAllProducts();
    
    @GetMapping("api/products/{id}")
    ProductDTO getProductById(@PathVariable String id);
}
```

## 🧪 Testing y Documentación

### Ejecutar tests unitarios
```bash
# Para todos los servicios
mvn test

# Para un servicio específico
cd msvc-products
mvn test
```

### Probar APIs con Swagger
1. Ejecutar el microservicio correspondiente
2. Abrir navegador en `http://localhost:{puerto}/swagger-ui/index.html`
3. Expandir los endpoints disponibles
4. Usar el botón **"Try it out"** para probar cada endpoint
5. Ver ejemplos de request/response automáticamente generados

### Ejemplos de archivos de importación

#### CSV Format
```csv
name,description,price,stock,image,platforms,genres,discount,developer,publisher,release_date
FIFA 2024,Football simulation game,59.99,100,fifa2024.jpg,PC|PS5|Xbox,Sports,10.0,EA Sports,EA,15-09-2023
```

#### Excel Format
| name | description | price | stock | image | platforms | genres | discount | developer | publisher | release_date |
|------|-------------|-------|-------|--------|-----------|--------|----------|-----------|-----------|--------------|
| FIFA 2024 | Football simulation | 59.99 | 100 | fifa2024.jpg | PC\|PS5 | Sports | 10.0 | EA Sports | EA | 15-09-2023 |

## 🐛 Troubleshooting

### Problemas Comunes

#### 1. Error de conexión a MongoDB
```bash
# Verificar variables de entorno
echo $MONGODB_URI

# Verificar conectividad
# Probar conexión desde MongoDB Compass
```

#### 2. Servicios no se registran en Eureka
```bash
# Verificar que Eureka esté ejecutándose en puerto 8761
curl http://localhost:8761

# Revisar logs de los microservicios
```

#### 3. Error en importación de archivos
- Verificar que el archivo tenga todas las columnas requeridas
- Verificar formato de fechas: `dd-MM-yyyy`
- Verificar que los valores numéricos sean válidos

## 🚀 Despliegue en Railway

### 🎯 Opción 1: Despliegue Unificado (Recomendado para Testing)

**Nuevo**: Todos los microservicios pueden desplegarse como un solo contenedor usando la configuración multi-servicio.

#### Características del Despliegue Unificado:
- ✅ **Un solo contenedor** con todos los microservicios
- ✅ **Startup orchestration** automático con timing correcto
- ✅ **Health checks** integrados para monitoreo
- ✅ **Configuración simplificada** con variables de entorno
- ✅ **Optimizado para Railway** con manejo automático de puertos

#### Pasos para Despliegue Unificado:

1. **Usar el Dockerfile multi-servicio** ubicado en `eureka-server/Dockerfile`
2. **Configurar variables de entorno** en Railway:
   ```bash
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/abcmotor?retryWrites=true&w=majority
   SPRING_PROFILES_ACTIVE=production
   ```
3. **Desplegar desde Railway** conectando el repositorio
4. **Railway automáticamente** detectará el Dockerfile y construirá el contenedor

#### Servicios incluidos en el contenedor:
- 🏢 **Eureka Server** (Port 8761) - Service Registry
- 🌐 **API Gateway** (Railway's PORT) - Main entry point
- 📦 **Products Service** (Port 8081) - Product management
- 🛒 **Sales Service** (Port 8082) - Sales management

📋 **Documentación detallada**: Ver `eureka-server/RAILWAY-DEPLOYMENT.md`

---

### 🔧 Opción 2: Despliegue Individual (Para Producción)

### Prerrequisitos para Railway
1. **Cuenta en Railway**: https://railway.app/
2. **Repositorio en GitHub** con tu código
3. **MongoDB Atlas** configurado (ya tienes esto)

### Pasos para el Despliegue

#### 1. Preparar el Repositorio
```bash
# Asegúrate de que todos los archivos estén en tu repositorio Git
git add .
git commit -m "Add Railway deployment configuration"
git push origin main
```

#### 2. Crear Proyectos en Railway

**Orden de despliegue importante:**

##### a) Desplegar Eureka Server (Primero)
1. Crear nuevo proyecto en Railway
2. Conectar con tu repositorio GitHub
3. Seleccionar carpeta: `eureka-server`
4. **Variables de entorno**:
   ```
   PORT=8761
   RAILWAY_PUBLIC_DOMAIN=tu-eureka-domain.railway.app
   ```

##### b) Desplegar API Gateway (Segundo)
1. Crear nuevo proyecto en Railway
2. Conectar con tu repositorio GitHub  
3. Seleccionar carpeta: `gateway`
4. **Variables de entorno**:
   ```
   PORT=8080
   EUREKA_URL=https://tu-eureka-domain.railway.app/eureka/
   RAILWAY_PUBLIC_DOMAIN=tu-gateway-domain.railway.app
   ```

##### c) Desplegar msvc-products (Tercero)
1. Crear nuevo proyecto en Railway
2. Conectar con tu repositorio GitHub
3. Seleccionar carpeta: `msvc-products`
4. **Variables de entorno**:
   ```
   PORT=8080
   EUREKA_URL=https://tu-eureka-domain.railway.app/eureka/
   MONGODB_USERNAME=tu_usuario_atlas
   MONGODB_PASSWORD=tu_password_atlas
   MONGODB_CLUSTER=tu_cluster.mongodb.net
   MONGODB_DATABASE=products_db
   RAILWAY_PUBLIC_DOMAIN=tu-products-domain.railway.app
   ```

##### d) Desplegar msvc-sales (Cuarto)
1. Crear nuevo proyecto en Railway
2. Conectar con tu repositorio GitHub
3. Seleccionar carpeta: `msvc-sales`
4. **Variables de entorno**:
   ```
   PORT=8080
   EUREKA_URL=https://tu-eureka-domain.railway.app/eureka/
   RAILWAY_PUBLIC_DOMAIN=tu-sales-domain.railway.app
   ```

### URLs de Producción
Una vez desplegado, tendrás:

- **Eureka Server**: `https://tu-eureka-domain.railway.app`
- **API Gateway**: `https://tu-gateway-domain.railway.app`
- **Products Service**: `https://tu-products-domain.railway.app`
- **Sales Service**: `https://tu-sales-domain.railway.app`

### Acceso a APIs en Producción

#### A través del Gateway (Recomendado)
```bash
# Productos
GET https://tu-gateway-domain.railway.app/msvc-products/api/products

# Sales  
GET https://tu-gateway-domain.railway.app/msvc-sales/api/item

# Swagger UI
https://tu-gateway-domain.railway.app/msvc-products/swagger-ui/index.html
https://tu-gateway-domain.railway.app/msvc-sales/swagger-ui/index.html
```

#### Acceso Directo
```bash
# Productos directo
GET https://tu-products-domain.railway.app/api/products

# Sales directo
GET https://tu-sales-domain.railway.app/api/item
```

### Configuración Avanzada

#### Variables de entorno completas para Railway:

**Eureka Server:**
```env
PORT=8761
RAILWAY_PUBLIC_DOMAIN=tu-eureka-domain.railway.app
```

**Gateway:**
```env
PORT=8080
EUREKA_URL=https://tu-eureka-domain.railway.app/eureka/
RAILWAY_PUBLIC_DOMAIN=tu-gateway-domain.railway.app
```

**msvc-products:**
```env
PORT=8080
EUREKA_URL=https://tu-eureka-domain.railway.app/eureka/
MONGODB_URI=mongodb+srv://usuario:password@cluster.mongodb.net/products_db?retryWrites=true&w=majority
RAILWAY_PUBLIC_DOMAIN=tu-products-domain.railway.app
```

**msvc-sales:**
```env
PORT=8080
EUREKA_URL=https://tu-eureka-domain.railway.app/eureka/
RAILWAY_PUBLIC_DOMAIN=tu-sales-domain.railway.app
```

### Monitoreo en Producción
1. **Logs**: Revisar logs en el dashboard de Railway
2. **Health Checks**: Usar los endpoints `/actuator/health`
3. **Eureka Dashboard**: Verificar servicios registrados

### Troubleshooting Railway

#### Problemas Comunes:
1. **Servicios no se conectan**: Verificar URLs de Eureka
2. **Build failures**: Revisar Dockerfiles y dependencias
3. **Variables de entorno**: Asegurar que estén configuradas correctamente
4. **Tiempo de inicio**: Los microservicios pueden tardar 2-3 minutos en iniciarse

#### Comandos útiles para debug:
```bash
# Ver logs en tiempo real
railway logs --follow

# Verificar variables de entorno
railway env

# Redeploy manual
railway up
```

## 📁 Estructura del Proyecto

```
📦 msvc-tarea/
├── 📂 eureka-server/          # Service Registry
│   ├── src/main/java/...
│   ├── Dockerfile             # Docker configuration
│   ├── .dockerignore         # Docker ignore file
│   └── pom.xml
├── 📂 gateway/                # API Gateway
│   ├── src/main/java/...
│   ├── src/main/resources/
│   │   └── application.properties
│   ├── Dockerfile             # Docker configuration
│   ├── .dockerignore         # Docker ignore file
│   └── pom.xml
├── 📂 msvc-products/          # Servicio de Productos
│   ├── src/main/java/
│   │   └── test/abcmotor/msvc_products/
│   │       ├── controller/    # REST Controllers
│   │       ├── models/        # Entidades y DTOs
│   │       ├── repository/    # Repositorios MongoDB
│   │       └── service/       # Lógica de negocio
│   ├── src/main/resources/
│   │   └── application.properties
│   ├── .env                   # Variables de entorno (local)
│   ├── Dockerfile             # Docker configuration
│   ├── .dockerignore         # Docker ignore file
│   └── pom.xml
├── 📂 msvc-sales/             # Servicio de Ventas
│   ├── src/main/java/
│   │   └── test/abcmotor/msvc_sales/
│   │       ├── client/        # Feign Clients
│   │       ├── controller/    # REST Controllers
│   │       ├── models/        # Entidades y DTOs
│   │       ├── repository/    # Repositorios
│   │       └── services/      # Lógica de negocio
│   ├── Dockerfile             # Docker configuration
│   ├── .dockerignore         # Docker ignore file
│   └── pom.xml
└── README.md
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama para feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit los cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📜 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👥 Equipo de Desarrollo

- **Desarrollador Principal**: Jimmy García
- **Institución**: UTPL - Transformación Digital
- **Curso**: Desarrollo de Aplicaciones Nativas en Cloud
- **Semestre**: IV

## 📞 Contacto

Para dudas o sugerencias sobre el proyecto:
- **Email**: [jjgarcia6@utpl.edu.ec]
- **GitHub**: [https://github.com/jjgarcia6/]

---

⭐ **¡No olvides dar una estrella al proyecto si te fue útil!** ⭐

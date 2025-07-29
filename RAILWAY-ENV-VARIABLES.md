# 🔐 Railway Environment Variables Setup

## ⚠️ IMPORTANT: Configure These Variables in Railway Dashboard

### **Step 1: Access Railway Dashboard**
1. Go to [railway.app](https://railway.app)
2. Select your project: **ABC Motor**
3. Click on your service
4. Go to **"Variables"** tab

### **Step 2: Add Environment Variables**

**REQUIRED MongoDB Variables:**
```
MONGODB_USERNAME = jjgarcia6
MONGODB_PASSWORD = PTkW8S8M6b6jgMuc
MONGODB_CLUSTER = cluster0.u3mhx.mongodb.net
MONGODB_DATABASE = products_db
```

**Optional (already have defaults):**
```
PRODUCTS_PORT = 8081
SALES_PORT = 8082
SPRING_PROFILES_ACTIVE = production
```

### **Step 3: Deploy**
After adding the variables, Railway will automatically redeploy your application.

## 🔒 Security Best Practices

✅ **DO:**
- Configure sensitive variables in Railway dashboard
- Use Railway's built-in environment variable system
- Keep credentials out of source code

❌ **DON'T:**
- Put passwords in railway.toml
- Commit .env files to git
- Expose credentials in configuration files

## 📊 Expected Result

After configuring the variables, your startup logs should show:
```
Configuration:
- MongoDB configured: Yes
✓ products.jar exists
=== Starting Products Service ===
Products Service started with PID: [pid]
```

And your health check should show all services registered:
```json
{
  "eureka": {
    "applications": {
      "GATEWAY": 1,
      "MSVC-PRODUCTS": 1,
      "MSVC-SALES": 1
    }
  }
}
```

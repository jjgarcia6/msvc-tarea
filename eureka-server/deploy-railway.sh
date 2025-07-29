# Deployment script for Railway
#!/bin/bash

echo "Deploying ABC Motor Microservices to Railway..."

# Deploy using Railway CLI with Docker Compose
railway up --detach

# Or deploy individual services with shared configuration
railway deploy --service eureka-server
railway deploy --service gateway  
railway deploy --service msvc-products
railway deploy --service msvc-sales

echo "Deployment completed!"
echo "Check your Railway dashboard for service URLs"

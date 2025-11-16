#!/bin/bash

# Kong API Gateway Route Configuration Script

KONG_ADMIN_URL="http://34.44.244.168:8001"

echo "Configuring Kong routes for all services..."

# 1. User Service
echo "Creating user-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services \
  --data name=user-service \
  --data url='http://user-service.ecommerce.svc.cluster.local:8081'

echo ""
echo "Creating route for user-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services/user-service/routes \
  --data 'paths[]=/api/v1/users' \
  --data 'strip_path=false' \
  --data 'name=user-route'

# 2. Product Service
echo ""
echo "Creating product-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services \
  --data name=product-service \
  --data url='http://product-service.ecommerce.svc.cluster.local:8082'

echo ""
echo "Creating route for product-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services/product-service/routes \
  --data 'paths[]=/api/v1/products' \
  --data 'strip_path=false' \
  --data 'name=product-route'

# 3. Order Service
echo ""
echo "Creating order-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services \
  --data name=order-service \
  --data url='http://order-service.ecommerce.svc.cluster.local:8083'

echo ""
echo "Creating route for order-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services/order-service/routes \
  --data 'paths[]=/api/v1/orders' \
  --data 'strip_path=false' \
  --data 'name=order-route'

# 4. Frontend Service
echo ""
echo "Creating frontend service..."
curl -i -X POST ${KONG_ADMIN_URL}/services \
  --data name=frontend \
  --data url='http://frontend.ecommerce.svc.cluster.local:80'

echo ""
echo "Creating route for frontend..."
curl -i -X POST ${KONG_ADMIN_URL}/services/frontend/routes \
  --data 'paths[]=/' \
  --data 'strip_path=false' \
  --data 'name=frontend-route'

# Add Rate Limiting Plugin to all services
echo ""
echo "Adding rate limiting to user-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services/user-service/plugins \
  --data name=rate-limiting \
  --data config.minute=100 \
  --data config.hour=5000 \
  --data config.policy=local

echo ""
echo "Adding rate limiting to product-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services/product-service/plugins \
  --data name=rate-limiting \
  --data config.minute=100 \
  --data config.hour=5000 \
  --data config.policy=local

echo ""
echo "Adding rate limiting to order-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services/order-service/plugins \
  --data name=rate-limiting \
  --data config.minute=50 \
  --data config.hour=2000 \
  --data config.policy=local

# Add CORS Plugin
echo ""
echo "Adding CORS to user-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services/user-service/plugins \
  --data name=cors \
  --data config.origins='*' \
  --data config.methods=GET,POST,PUT,PATCH,DELETE \
  --data config.headers=Accept,Content-Type,Authorization \
  --data config.exposed_headers=X-Auth-Token \
  --data config.credentials=true \
  --data config.max_age=3600

echo ""
echo "Adding CORS to product-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services/product-service/plugins \
  --data name=cors \
  --data config.origins='*' \
  --data config.methods=GET,POST,PUT,PATCH,DELETE \
  --data config.headers=Accept,Content-Type,Authorization

echo ""
echo "Adding CORS to order-service..."
curl -i -X POST ${KONG_ADMIN_URL}/services/order-service/plugins \
  --data name=cors \
  --data config.origins='*' \
  --data config.methods=GET,POST,PUT,PATCH,DELETE \
  --data config.headers=Accept,Content-Type,Authorization

echo ""
echo "Kong configuration completed!"
echo ""
echo "Verify routes:"
echo "curl ${KONG_ADMIN_URL}/routes"
echo ""
echo "Test via Kong Proxy (http://136.119.114.180):"
echo "curl http://136.119.114.180/api/v1/products"

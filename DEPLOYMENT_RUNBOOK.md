# Complete Deployment Runbook
## GCP Three-Tier E-Commerce Platform - From Scratch to Production

**Last Updated:** November 17, 2025  
**Version:** 1.0  
**Estimated Time:** 3-4 hours  
**Difficulty:** Intermediate to Advanced

---

## 📋 Table of Contents

1. [Project Overview](#1-project-overview)
2. [Prerequisites](#2-prerequisites)
3. [Architecture Understanding](#3-architecture-understanding)
4. [Local Development Setup](#4-local-development-setup)
5. [GCP Project Initialization](#5-gcp-project-initialization)
6. [Infrastructure Provisioning (Terraform)](#6-infrastructure-provisioning-terraform)
7. [Database Setup](#7-database-setup)
8. [Build and Push Docker Images](#8-build-and-push-docker-images)
9. [Deploy to Kubernetes](#9-deploy-to-kubernetes)
10. [Configure API Gateway (Kong)](#10-configure-api-gateway-kong)
11. [Setup Monitoring](#11-setup-monitoring)
12. [CI/CD Pipeline Setup](#12-cicd-pipeline-setup)
13. [Testing and Validation](#13-testing-and-validation)
14. [Troubleshooting Guide](#14-troubleshooting-guide)
15. [Operations and Maintenance](#15-operations-and-maintenance)

---

## 1. Project Overview

### What You'll Build

A production-ready three-tier e-commerce platform on Google Cloud Platform featuring:

**Presentation Tier:**
- React 18 + TypeScript single-page application
- Redux Toolkit for state management
- Responsive UI with Material-UI components
- Served via Nginx with optimized caching

**Application Tier:**
- 3 Spring Boot microservices (User, Product, Order)
- Kong API Gateway for unified routing
- JWT-based authentication
- RESTful APIs with OpenAPI documentation
- Deployed on Google Kubernetes Engine (GKE)

**Data Tier:**
- Cloud SQL PostgreSQL (primary database)
- Redis (caching and sessions)
- Google Pub/Sub (async messaging)
- Cloud Storage (static files and images)

**DevOps:**
- Infrastructure as Code (Terraform)
- Docker containerization
- Kubernetes orchestration
- Horizontal Pod Autoscaling
- Cloud Build CI/CD
- Prometheus + Grafana monitoring

### Final Architecture

```
                                  ┌─────────────┐
                                  │   Internet  │
                                  │    Users    │
                                  └──────┬──────┘
                                         │
                                  ┌──────▼──────┐
                                  │ Cloud CDN   │
                                  └──────┬──────┘
                                         │
┌────────────────────────────────────────┼────────────────────────────────────┐
│  GCP Load Balancer (34.8.28.111)      │                                    │
│                                  ┌─────▼─────┐                              │
│                                  │  Ingress  │                              │
│                                  │Controller │                              │
│                                  └─────┬─────┘                              │
│                                        │                                    │
│  ┌─────────────────────────────────────┼──────────────────────────────┐   │
│  │  Google Kubernetes Engine (GKE)     │                              │   │
│  │                                      │                              │   │
│  │    ┌─────────────────────────────────▼──────────────┐              │   │
│  │    │         Kong API Gateway                       │              │   │
│  │    │    (136.119.114.180)                           │              │   │
│  │    └─────┬──────────┬────────────┬─────────────────┘              │   │
│  │          │          │            │                                 │   │
│  │    ┌─────▼────┐ ┌──▼─────┐ ┌───▼──────┐ ┌─────────────┐          │   │
│  │    │ Frontend │ │  User  │ │ Product  │ │    Order    │          │   │
│  │    │  (React) │ │ Service│ │ Service  │ │   Service   │          │   │
│  │    │ 3 Pods   │ │ 3 Pods │ │ 3 Pods   │ │   3 Pods    │          │   │
│  │    └──────────┘ └────┬───┘ └────┬─────┘ └──────┬──────┘          │   │
│  │                      │          │              │                  │   │
│  └──────────────────────┼──────────┼──────────────┼──────────────────┘   │
│                         │          │              │                      │
│     ┌───────────────────┼──────────┼──────────────┼─────────┐            │
│     │ Data Tier         │          │              │         │            │
│     │                   │          │              │         │            │
│     │  ┌────────────────▼──────────▼──────────────▼───┐    │            │
│     │  │   Cloud SQL PostgreSQL (Private IP)         │    │            │
│     │  │   - users_db                                 │    │            │
│     │  │   - products_db                              │    │            │
│     │  │   - orders_db                                │    │            │
│     │  └──────────────────────────────────────────────┘    │            │
│     │                                                       │            │
│     │  ┌──────────────────┐    ┌─────────────────────┐    │            │
│     │  │  Redis           │    │  Google Pub/Sub     │    │            │
│     │  │  (Memorystore)   │    │  (Messaging)        │    │            │
│     │  └──────────────────┘    └─────────────────────┘    │            │
│     └───────────────────────────────────────────────────────┘            │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Monitoring & Logging                                            │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │    │
│  │  │  Prometheus  │  │   Grafana    │  │  Cloud Operations    │  │    │
│  │  └──────────────┘  └──────────────┘  └──────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Frontend** | React + TypeScript | 18.2.0 |
| **State Management** | Redux Toolkit | 2.0.1 |
| **Backend Framework** | Spring Boot | 3.2.0 |
| **Java** | OpenJDK | 17 LTS |
| **API Gateway** | Kong | 3.4.0 |
| **Primary Database** | PostgreSQL | 15 |
| **Cache** | Redis | 7.0 |
| **Container Runtime** | Docker | 24.0+ |
| **Container Orchestration** | Kubernetes (GKE) | 1.33.5 |
| **Infrastructure as Code** | Terraform | 1.5+ |
| **CI/CD** | Cloud Build | Latest |
| **Monitoring** | Prometheus + Grafana | 2.47 + 10.2 |
| **Cloud Platform** | Google Cloud Platform | - |

### Project Metrics

- **Total Pods:** 12 (Frontend: 3, User: 3, Product: 3, Order: 3)
- **GKE Nodes:** 3 (e2-standard-4)
- **Database:** Cloud SQL (db-custom-2-7680)
- **Redis:** 5GB Standard HA
- **Storage:** 2 Cloud Storage buckets
- **Load Balancer:** Global L7 with SSL

---

## 2. Prerequisites

### 2.1 Local Development Machine

**Operating System:**
- Linux (Ubuntu 20.04+ recommended)
- macOS 12+ (Monterey or later)
- Windows 11 with WSL2

**Hardware Requirements:**
- CPU: 4+ cores
- RAM: 16GB minimum, 32GB recommended
- Disk: 50GB free space
- Internet: Stable broadband connection

### 2.2 Required Software

Install the following tools on your development machine:

#### Core Tools

**1. Google Cloud SDK**
```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init

# Verify installation
gcloud version
```

**2. kubectl (Kubernetes CLI)**
```bash
# Install kubectl
gcloud components install kubectl

# Verify installation
kubectl version --client
```

**3. Terraform**
```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify
terraform version
```

**4. Docker & Docker Compose**
```bash
# Ubuntu
sudo apt-get update
sudo apt-get install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker

# macOS
brew install --cask docker

# Verify
docker version
docker compose version
```

**5. Git**
```bash
# Ubuntu/Debian
sudo apt-get install git

# macOS
brew install git

# Verify
git --version
```

#### Development Tools

**6. Java Development Kit (JDK 17)**
```bash
# Ubuntu/Debian
sudo apt-get install openjdk-17-jdk

# macOS
brew install openjdk@17

# Verify
java -version
javac -version
```

**7. Maven**
```bash
# Ubuntu/Debian
sudo apt-get install maven

# macOS
brew install maven

# Verify
mvn -version
```

**8. Node.js and npm**
```bash
# Ubuntu/Debian (using NodeSource)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node@18

# Verify
node --version
npm --version
```

**9. Helm (Optional, for Kong)**
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

### 2.3 Google Cloud Platform Setup

#### Create GCP Project

1. **Go to GCP Console:** https://console.cloud.google.com/

2. **Create New Project:**
   ```bash
   # Via gcloud CLI
   gcloud projects create YOUR-PROJECT-ID \
     --name="E-Commerce Platform" \
     --labels=environment=production,app=ecommerce
   
   # Set as default project
   gcloud config set project YOUR-PROJECT-ID
   ```

3. **Enable Billing:**
   - Go to: https://console.cloud.google.com/billing
   - Link a billing account to your project

4. **Enable Required APIs:**
   ```bash
   gcloud services enable \
     compute.googleapis.com \
     container.googleapis.com \
     sqladmin.googleapis.com \
     redis.googleapis.com \
     storage-api.googleapis.com \
     pubsub.googleapis.com \
     artifactregistry.googleapis.com \
     cloudbuild.googleapis.com \
     cloudresourcemanager.googleapis.com \
     servicenetworking.googleapis.com \
     monitoring.googleapis.com \
     logging.googleapis.com
   ```

#### Create Service Accounts

**1. Terraform Service Account:**
```bash
# Create service account
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account" \
  --description="Service account for Terraform infrastructure provisioning"

# Grant necessary roles
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:terraform-sa@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:terraform-sa@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:terraform-sa@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectIamAdmin"

# Create and download key
gcloud iam service-accounts keys create ~/terraform-key.json \
  --iam-account=terraform-sa@YOUR-PROJECT-ID.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=~/terraform-key.json
```

**2. GKE Service Account:**
```bash
# Create service account
gcloud iam service-accounts create gke-service-account \
  --display-name="GKE Service Account"

# Grant necessary roles
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:gke-service-account@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:gke-service-account@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:gke-service-account@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/cloudtrace.agent"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:gke-service-account@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"
```

**3. Cloud Build Service Account (for CI/CD):**
```bash
# Get project number
PROJECT_NUMBER=$(gcloud projects describe YOUR-PROJECT-ID --format='value(projectNumber)')

# Grant Cloud Build service account necessary permissions
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/container.developer"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"
```

### 2.4 Configure Local Environment

#### Set Environment Variables

Create a file `~/.ecommerce-env` with:

```bash
# GCP Configuration
export GCP_PROJECT_ID="YOUR-PROJECT-ID"
export GCP_REGION="us-central1"
export GCP_ZONE="us-central1-a"
export GOOGLE_APPLICATION_CREDENTIALS=~/terraform-key.json

# Database Configuration
export DB_NAME="ecommerce_users"
export DB_USER="postgres"
export DB_PASSWORD="YOUR-SECURE-PASSWORD"

# Redis Configuration
export REDIS_HOST="localhost"
export REDIS_PORT="6379"

# JWT Configuration
export JWT_SECRET="YOUR-JWT-SECRET-KEY-CHANGE-THIS-IN-PRODUCTION"

# Application Configuration
export USER_SERVICE_PORT="8081"
export PRODUCT_SERVICE_PORT="8082"
export ORDER_SERVICE_PORT="8083"
export FRONTEND_PORT="3000"
```

Load environment variables:
```bash
source ~/.ecommerce-env
echo "source ~/.ecommerce-env" >> ~/.bashrc  # or ~/.zshrc for zsh
```

### 2.5 Clone the Repository

```bash
# Clone the repository
git clone https://github.com/rupesh9999/gcp-three-tier-ecommerce-project.git
cd gcp-three-tier-ecommerce-project

# Verify repository structure
ls -la
```

Expected structure:
```
gcp-three-tier-ecommerce-project/
├── backend/
│   ├── user-service/
│   ├── product-service/
│   └── order-service/
├── frontend/
├── infrastructure/
│   ├── terraform/
│   ├── kubernetes/
│   ├── jenkins/
│   └── monitoring/
├── database/
├── docs/
├── docker-compose.yml
└── README.md
```

---

## 3. Architecture Understanding

Before deploying, it's crucial to understand the architecture components and their interactions.

### 3.1 Three-Tier Architecture Breakdown

**Tier 1: Presentation Layer**
- **Component:** React SPA (Single Page Application)
- **Technology:** React 18, TypeScript, Redux Toolkit
- **Responsibility:** User interface, client-side routing, state management
- **Communication:** REST API calls to Application Tier via Kong Gateway
- **Deployment:** Kubernetes Deployment with 3 replicas, served by Nginx

**Tier 2: Application Layer (Business Logic)**
- **Components:** 3 Microservices
  1. **User Service:** Authentication, user management, profiles
  2. **Product Service:** Catalog management, inventory, search
  3. **Order Service:** Order processing, cart management, checkout
- **Technology:** Spring Boot 3.2, Java 17
- **Responsibility:** Business logic, data validation, orchestration
- **Communication:** 
  - Synchronous: REST APIs via Kong Gateway
  - Asynchronous: Google Pub/Sub for inter-service messaging
- **Deployment:** Kubernetes Deployments with 3 replicas each, HorizontalPodAutoscaler enabled

**Tier 3: Data Layer**
- **Primary Database:** Cloud SQL PostgreSQL
  - `users_db`: User accounts, profiles, authentication
  - `products_db`: Product catalog, inventory, pricing
  - `orders_db`: Orders, order items, payment records
- **Cache:** Redis (Memorystore)
  - Session management
  - API response caching
  - Rate limiting data
- **Message Queue:** Google Pub/Sub
  - Order creation events
  - Inventory updates
  - Email notifications
- **Object Storage:** Cloud Storage
  - Product images
  - Static frontend assets

### 3.2 Key Architectural Patterns

**1. Microservices Architecture**
- Each service is independently deployable
- Database per service pattern
- API Gateway for unified entry point
- Service discovery via Kubernetes DNS

**2. Event-Driven Architecture**
- Pub/Sub for asynchronous communication
- Decoupled service interactions
- Event sourcing for order history

**3. Caching Strategy**
- Redis for session and data caching
- CDN for static content delivery
- Application-level caching in Spring Boot

**4. Security Patterns**
- JWT-based authentication
- API Gateway for centralized security
- Network policies for pod-to-pod communication
- Private IP for database (no public exposure)

**5. Scalability Patterns**
- Horizontal Pod Autoscaling (HPA)
- GKE cluster autoscaling
- Connection pooling for databases
- Stateless application design

### 3.3 Data Flow Example: User Registration

```
1. User submits registration form in React app
   └─> POST /api/v1/users/register

2. Request hits Load Balancer (34.8.28.111)
   └─> Routes to Kong API Gateway (136.119.114.180)

3. Kong validates request and forwards to User Service
   └─> POST http://user-service:8081/api/v1/users/register

4. User Service processes request:
   a. Validates input data
   b. Hashes password with BCrypt
   c. Saves user to PostgreSQL (users_db)
   d. Generates JWT token
   e. Publishes "UserCreated" event to Pub/Sub

5. Response flows back:
   User Service → Kong → Load Balancer → React App

6. Async processing:
   - Notification Service consumes "UserCreated" event
   - Sends welcome email via SendGrid
```

### 3.4 Network Architecture

**VPC Configuration:**
```
VPC Name: ecommerce-vpc
Region: us-central1
Subnets:
  - gke-subnet: 10.0.0.0/20 (GKE pods and nodes)
  - db-subnet: 10.1.0.0/24 (Cloud SQL private IP)
```

**Firewall Rules:**
- Allow ingress from Load Balancer to GKE (port 80, 443)
- Allow egress from GKE to Cloud SQL (port 5432)
- Allow egress from GKE to Redis (port 6379)
- Allow egress from GKE to internet (for external APIs)

**Private Service Connection:**
- Cloud SQL uses private IP (no public IP)
- Accessible only from VPC
- Connection via Private Service Connect

---

## 4. Local Development Setup

Before deploying to GCP, set up the application locally for development and testing.

### 4.1 Start Local Infrastructure

#### Option A: Using Docker Compose (Recommended)

**1. Create docker-compose.yml** (if not exists):
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: ecommerce-postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: ecommerce_users
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/postgresql/users/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
      - ./database/postgresql/users/initial-data.sql:/docker-entrypoint-initdb.d/02-data.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: ecommerce-redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

**2. Start services:**
```bash
docker compose up -d

# Verify services are running
docker compose ps

# Check logs
docker compose logs postgres
docker compose logs redis
```

**3. Verify database initialization:**
```bash
# Connect to PostgreSQL
docker exec -it ecommerce-postgres psql -U postgres -d ecommerce_users

# Check tables
\dt

# Check sample data
SELECT * FROM users LIMIT 5;

# Exit
\q
```

#### Option B: Manual Installation

**1. Install PostgreSQL:**
```bash
# Ubuntu/Debian
sudo apt-get install postgresql-15 postgresql-contrib

# macOS
brew install postgresql@15

# Start service
sudo systemctl start postgresql  # Linux
brew services start postgresql@15  # macOS
```

**2. Create database and user:**
```bash
sudo -u postgres psql

CREATE DATABASE ecommerce_users;
CREATE USER ecommerce WITH ENCRYPTED PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE ecommerce_users TO ecommerce;
\q
```

**3. Initialize schema:**
```bash
psql -U ecommerce -d ecommerce_users -f database/postgresql/users/schema.sql
psql -U ecommerce -d ecommerce_users -f database/postgresql/users/initial-data.sql
```

**4. Install and start Redis:**
```bash
# Ubuntu/Debian
sudo apt-get install redis-server
sudo systemctl start redis-server

# macOS
brew install redis
brew services start redis

# Verify
redis-cli ping
```

### 4.2 Build Backend Services

#### User Service

**1. Navigate to user service:**
```bash
cd backend/user-service
```

**2. Update application.yml for local development:**
```yaml
# src/main/resources/application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/ecommerce_users
    username: postgres
    password: postgres
  redis:
    host: localhost
    port: 6379
  
jwt:
  secret: ${JWT_SECRET:local-dev-secret-key}
  expiration: 86400000  # 24 hours

server:
  port: 8081
```

**3. Build and run:**
```bash
# Build
mvn clean install

# Run
mvn spring-boot:run

# Or run JAR directly
java -jar target/user-service-0.0.1-SNAPSHOT.jar
```

**4. Verify service is running:**
```bash
# Health check
curl http://localhost:8081/actuator/health

# Test registration
curl -X POST http://localhost:8081/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test123!",
    "firstName": "Test",
    "lastName": "User"
  }'
```

#### Product Service

**1. Navigate to product service:**
```bash
cd backend/product-service
```

**2. Update application.yml:**
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/ecommerce_products
    username: postgres
    password: postgres
  redis:
    host: localhost
    port: 6379

server:
  port: 8082
```

**3. Create products database:**
```bash
docker exec -it ecommerce-postgres psql -U postgres -c "CREATE DATABASE ecommerce_products;"
```

**4. Build and run:**
```bash
mvn clean install
mvn spring-boot:run
```

**5. Verify:**
```bash
curl http://localhost:8082/actuator/health
curl http://localhost:8082/api/v1/products
```

#### Order Service

**1. Navigate to order service:**
```bash
cd backend/order-service
```

**2. Update application.yml:**
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/ecommerce_orders
    username: postgres
    password: postgres
  redis:
    host: localhost
    port: 6379

server:
  port: 8083
```

**3. Create orders database:**
```bash
docker exec -it ecommerce-postgres psql -U postgres -c "CREATE DATABASE ecommerce_orders;"
```

**4. Build and run:**
```bash
mvn clean install
mvn spring-boot:run
```

**5. Verify:**
```bash
curl http://localhost:8083/actuator/health
```

### 4.3 Build Frontend

**1. Navigate to frontend:**
```bash
cd frontend
```

**2. Install dependencies:**
```bash
npm install
```

**3. Update API endpoint configuration:**

Edit `src/config/api.ts`:
```typescript
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8081';

export const API_ENDPOINTS = {
  USER_SERVICE: `${API_BASE_URL}/api/v1/users`,
  PRODUCT_SERVICE: 'http://localhost:8082/api/v1/products',
  ORDER_SERVICE: 'http://localhost:8083/api/v1/orders',
  AUTH: `${API_BASE_URL}/api/v1/auth`,
};
```

**4. Start development server:**
```bash
npm start
```

**5. Access application:**
- Open browser: http://localhost:3000
- You should see the e-commerce home page

**6. Test functionality:**
- Register a new user
- Browse products
- Add items to cart
- Place an order

### 4.4 Local Testing

**1. Run backend tests:**
```bash
cd backend/user-service
mvn test

cd ../product-service
mvn test

cd ../order-service
mvn test
```

**2. Run frontend tests:**
```bash
cd frontend
npm test
```

**3. Integration testing:**
```bash
# Create a test script
cat > test-local.sh << 'EOF'
#!/bin/bash

# Test user registration
echo "Testing user registration..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8081/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "integrationtest",
    "email": "integration@test.com",
    "password": "Test123!",
    "firstName": "Integration",
    "lastName": "Test"
  }')
echo $REGISTER_RESPONSE

# Extract token
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.token')

# Test get products
echo "Testing get products..."
curl -s http://localhost:8082/api/v1/products | jq '.'

# Test create order
echo "Testing create order..."
curl -s -X POST http://localhost:8083/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "items": [
      {
        "productId": 1,
        "quantity": 2,
        "price": 29.99
      }
    ],
    "totalAmount": 59.98
  }' | jq '.'

echo "Integration tests completed!"
EOF

chmod +x test-local.sh
./test-local.sh
```

---

## 5. GCP Project Initialization

Now that the application works locally, prepare GCP project for deployment.

### 5.1 Set Project Context

```bash
# Set your project ID
export GCP_PROJECT_ID="YOUR-PROJECT-ID"

# Set active project
gcloud config set project $GCP_PROJECT_ID

# Verify
gcloud config list
```

### 5.2 Create Terraform State Bucket

Terraform needs a Cloud Storage bucket to store state files:

```bash
# Create bucket for Terraform state
gsutil mb -p $GCP_PROJECT_ID \
  -c STANDARD \
  -l us-central1 \
  gs://ecommerce-terraform-state-${GCP_PROJECT_ID}/

# Enable versioning (for state file history)
gsutil versioning set on gs://ecommerce-terraform-state-${GCP_PROJECT_ID}/

# Verify
gsutil ls
```

### 5.3 Configure Terraform Backend

Edit `infrastructure/terraform/main.tf` to configure remote state:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "ecommerce-terraform-state-YOUR-PROJECT-ID"
    prefix = "terraform/state"
  }
}
```

### 5.4 Create Artifact Registry

Create a repository for Docker images:

```bash
# Create Artifact Registry repository
gcloud artifacts repositories create ecommerce-repo \
  --repository-format=docker \
  --location=us-central1 \
  --description="Docker repository for e-commerce microservices"

# Configure Docker authentication
gcloud auth configure-docker us-central1-docker.pkg.dev

# Verify
gcloud artifacts repositories list
```

### 5.5 Reserve Static IP Address

Reserve a static external IP for the load balancer:

```bash
# Reserve static IP
gcloud compute addresses create ecommerce-lb-ip \
  --global \
  --ip-version IPV4

# Get the IP address
gcloud compute addresses describe ecommerce-lb-ip \
  --global \
  --format="get(address)"

# Note this IP - you'll need it for DNS configuration
```

---

## 6. Infrastructure Provisioning (Terraform)

Deploy all GCP infrastructure using Terraform.

### 6.1 Review Terraform Configuration

**1. Navigate to Terraform directory:**
```bash
cd infrastructure/terraform
```

**2. Review main.tf:**
```bash
less main.tf
```

Key resources created:
- VPC network and subnets
- GKE cluster with node pool
- Cloud SQL PostgreSQL instance
- Redis (Memorystore) instance
- Cloud Storage buckets
- Pub/Sub topics and subscriptions
- Service accounts and IAM bindings
- Firewall rules
- Cloud NAT

**3. Review variables.tf:**
```bash
cat variables.tf
```

### 6.2 Create terraform.tfvars

Create a file with your specific values:

```bash
cat > terraform.tfvars << EOF
# Project Configuration
project_id = "$GCP_PROJECT_ID"
region     = "us-central1"
zone       = "us-central1-a"

# VPC Configuration
vpc_name = "ecommerce-vpc"

# GKE Configuration
gke_cluster_name = "ecommerce-cluster"
gke_node_count   = 3
gke_machine_type = "e2-standard-4"
gke_disk_size_gb = 50

# Cloud SQL Configuration
db_instance_name = "ecommerce-postgres"
db_tier          = "db-custom-2-7680"  # 2 vCPU, 7.5GB RAM
db_version       = "POSTGRES_15"
db_availability  = "REGIONAL"  # HA configuration

# Redis Configuration
redis_instance_name  = "ecommerce-redis"
redis_memory_size_gb = 5
redis_tier           = "STANDARD_HA"

# Cloud Storage Configuration
frontend_bucket_name = "ecommerce-frontend-${GCP_PROJECT_ID}"
images_bucket_name   = "ecommerce-images-${GCP_PROJECT_ID}"

# Pub/Sub Topics
pubsub_topics = [
  "order-created",
  "order-updated",
  "payment-processed",
  "inventory-updated",
  "notification-requested"
]

# Service Account
gke_sa_name = "gke-service-account"

# Labels
labels = {
  environment = "production"
  application = "ecommerce"
  managed-by  = "terraform"
}
EOF
```

### 6.3 Initialize Terraform

```bash
# Initialize Terraform (downloads providers, sets up backend)
terraform init

# Verify configuration
terraform validate

# Check formatting
terraform fmt
```

### 6.4 Plan Infrastructure

```bash
# Generate execution plan
terraform plan -out=tfplan

# Review the plan carefully
# This shows all resources that will be created
```

Expected output:
```
Plan: 45 to add, 0 to change, 0 to destroy.
```

Resources to be created:
- 1 VPC network
- 2 Subnets
- 1 Cloud Router
- 1 Cloud NAT
- 1 GKE Cluster
- 1 Node Pool
- 1 Cloud SQL Instance
- 1 Redis Instance
- 2 Storage Buckets
- 5 Pub/Sub Topics
- 5 Pub/Sub Subscriptions
- 4 Service Accounts
- 8 IAM Bindings
- Multiple Firewall Rules

### 6.5 Apply Terraform Configuration

```bash
# Apply the plan
terraform apply tfplan

# This will take 15-25 minutes
# Monitor progress in the terminal
```

**Note:** If you encounter any errors, see the Troubleshooting section.

### 6.6 Verify Infrastructure

**1. Check GKE cluster:**
```bash
gcloud container clusters list
gcloud container clusters describe ecommerce-cluster --zone=us-central1-a
```

**2. Check Cloud SQL:**
```bash
gcloud sql instances list
gcloud sql instances describe ecommerce-postgres
```

**3. Check Redis:**
```bash
gcloud redis instances list --region=us-central1
```

**4. Check Storage buckets:**
```bash
gsutil ls
```

**5. Check Pub/Sub topics:**
```bash
gcloud pubsub topics list
```

### 6.7 Save Terraform Outputs

```bash
# Save all outputs to file
terraform output -json > terraform-outputs.json

# View specific outputs
terraform output gke_cluster_name
terraform output cloudsql_connection_name
terraform output redis_host

# Export important values
export GKE_CLUSTER_NAME=$(terraform output -raw gke_cluster_name)
export CLOUDSQL_CONNECTION=$(terraform output -raw cloudsql_connection_name)
export REDIS_HOST=$(terraform output -raw redis_host)
```

---

## 7. Database Setup

Initialize databases and load schemas.

### 7.1 Get Cluster Credentials

```bash
# Configure kubectl to use GKE cluster
gcloud container clusters get-credentials ecommerce-cluster \
  --zone=us-central1-a \
  --project=$GCP_PROJECT_ID

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### 7.2 Set Up Cloud SQL Proxy

The Cloud SQL Proxy allows secure connections to Cloud SQL from your local machine or GKE pods.

**Option A: Local Machine (for initial setup)**

```bash
# Download Cloud SQL Proxy
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
chmod +x cloud_sql_proxy

# Start proxy in background
./cloud_sql_proxy -instances=$CLOUDSQL_CONNECTION=tcp:5432 &

# Save PID for later
PROXY_PID=$!
echo $PROXY_PID > proxy.pid
```

**Option B: Deploy in Kubernetes (for production)**

```yaml
# infrastructure/kubernetes/cloud-sql-proxy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-sql-proxy
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloud-sql-proxy
  template:
    metadata:
      labels:
        app: cloud-sql-proxy
    spec:
      serviceAccountName: gke-service-account
      containers:
      - name: cloud-sql-proxy
        image: gcr.io/cloudsql-docker/gce-proxy:latest
        command:
          - "/cloud_sql_proxy"
          - "-instances=$CLOUDSQL_CONNECTION=tcp:0.0.0.0:5432"
        ports:
        - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: cloud-sql-proxy
  namespace: ecommerce
spec:
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: cloud-sql-proxy
  type: ClusterIP
```

Apply:
```bash
kubectl apply -f infrastructure/kubernetes/cloud-sql-proxy.yaml
```

### 7.3 Initialize Databases

**1. Create databases:**
```bash
# Connect via proxy
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -c "CREATE DATABASE ecommerce_users;"
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -c "CREATE DATABASE ecommerce_products;"
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -c "CREATE DATABASE ecommerce_orders;"

# Verify
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -l
```

**2. Load user service schema:**
```bash
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -d ecommerce_users \
  -f ../../database/postgresql/users/schema.sql

# Load initial data
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -d ecommerce_users \
  -f ../../database/postgresql/users/initial-data.sql

# Verify
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -d ecommerce_users -c "\dt"
```

**3. Load product service schema:**

First, create the schema file if it doesn't exist:

```sql
-- database/postgresql/products/schema.sql
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    category VARCHAR(100),
    sku VARCHAR(50) UNIQUE NOT NULL,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_active ON products(is_active);

-- Sample products
INSERT INTO products (name, description, price, stock_quantity, category, sku, image_url) VALUES
('Laptop Pro 15', 'High-performance laptop with 16GB RAM', 1299.99, 50, 'Electronics', 'LAP-001', '/images/laptop-pro.jpg'),
('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 200, 'Electronics', 'MOU-001', '/images/wireless-mouse.jpg'),
('USB-C Cable', 'Fast charging USB-C cable 2m', 12.99, 500, 'Accessories', 'CAB-001', '/images/usb-cable.jpg'),
('Smartphone X', 'Latest smartphone with 5G', 899.99, 100, 'Electronics', 'PHO-001', '/images/smartphone-x.jpg'),
('Bluetooth Headphones', 'Noise-cancelling headphones', 199.99, 75, 'Electronics', 'HDP-001', '/images/headphones.jpg');
```

Load schema:
```bash
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -d ecommerce_products \
  -f ../../database/postgresql/products/schema.sql
```

**4. Load order service schema:**

Create schema file:

```sql
-- database/postgresql/orders/schema.sql
CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    total_amount DECIMAL(10, 2) NOT NULL,
    shipping_address TEXT,
    billing_address TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

Load schema:
```bash
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -d ecommerce_orders \
  -f ../../database/postgresql/orders/schema.sql
```

### 7.4 Create Kubernetes Secrets

Store database credentials in Kubernetes:

```bash
# Create namespace
kubectl create namespace ecommerce

# Create database secret
kubectl create secret generic db-credentials \
  --from-literal=username=postgres \
  --from-literal=password=$DB_PASSWORD \
  --namespace=ecommerce

# Create JWT secret
kubectl create secret generic jwt-secret \
  --from-literal=secret=$JWT_SECRET \
  --namespace=ecommerce

# Verify
kubectl get secrets -n ecommerce
```

### 7.5 Create ConfigMaps

```bash
# Create config for database connections
kubectl create configmap database-config \
  --from-literal=user-service-db=ecommerce_users \
  --from-literal=product-service-db=ecommerce_products \
  --from-literal=order-service-db=ecommerce_orders \
  --from-literal=db-host=$CLOUDSQL_CONNECTION \
  --from-literal=db-port=5432 \
  --namespace=ecommerce

# Create config for Redis
kubectl create configmap redis-config \
  --from-literal=host=$REDIS_HOST \
  --from-literal=port=6379 \
  --namespace=ecommerce

# Create config for GCP
kubectl create configmap gcp-config \
  --from-literal=project-id=$GCP_PROJECT_ID \
  --from-literal=region=us-central1 \
  --from-literal=artifact-registry=us-central1-docker.pkg.dev \
  --namespace=ecommerce

# Verify
kubectl get configmaps -n ecommerce
```

---

## 8. Build and Push Docker Images

Build Docker images for all services and push to Artifact Registry.

### 8.1 Build User Service Image

```bash
cd backend/user-service

# Build Docker image
docker build -t us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/user-service:v1.0.0 .
docker build -t us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/user-service:latest .

# Push to Artifact Registry
docker push us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/user-service:v1.0.0
docker push us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/user-service:latest

# Verify
gcloud artifacts docker images list us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo
```

### 8.2 Build Product Service Image

```bash
cd backend/product-service

docker build -t us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/product-service:v1.0.0 .
docker build -t us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/product-service:latest .

docker push us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/product-service:v1.0.0
docker push us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/product-service:latest
```

### 8.3 Build Order Service Image

```bash
cd backend/order-service

docker build -t us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/order-service:v1.0.0 .
docker build -t us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/order-service:latest .

docker push us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/order-service:v1.0.0
docker push us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/order-service:latest
```

### 8.4 Build Frontend Image

```bash
cd frontend

# Build production bundle
npm run build

# Build Docker image
docker build -t us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/frontend:v1.0.0 .
docker build -t us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/frontend:latest .

# Push to registry
docker push us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/frontend:v1.0.0
docker push us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/frontend:latest
```

### 8.5 Automated Build Script

Create a script to build all images:

```bash
cat > build-and-push.sh << 'EOF'
#!/bin/bash
set -e

# Configuration
PROJECT_ID=${GCP_PROJECT_ID}
REGISTRY="us-central1-docker.pkg.dev"
REPO="ecommerce-repo"
VERSION="v1.0.0"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

build_and_push() {
    SERVICE=$1
    CONTEXT=$2
    
    echo -e "${BLUE}Building $SERVICE...${NC}"
    docker build -t $REGISTRY/$PROJECT_ID/$REPO/$SERVICE:$VERSION $CONTEXT
    docker build -t $REGISTRY/$PROJECT_ID/$REPO/$SERVICE:latest $CONTEXT
    
    echo -e "${BLUE}Pushing $SERVICE...${NC}"
    docker push $REGISTRY/$PROJECT_ID/$REPO/$SERVICE:$VERSION
    docker push $REGISTRY/$PROJECT_ID/$REPO/$SERVICE:latest
    
    echo -e "${GREEN}✓ $SERVICE complete${NC}"
}

# Build all services
build_and_push "user-service" "backend/user-service"
build_and_push "product-service" "backend/product-service"
build_and_push "order-service" "backend/order-service"

# Build frontend
cd frontend && npm run build && cd ..
build_and_push "frontend" "frontend"

echo -e "${GREEN}All images built and pushed successfully!${NC}"
EOF

chmod +x build-and-push.sh
./build-and-push.sh
```

---

## 9. Deploy to Kubernetes

Deploy all application components to GKE.

### 9.1 Update Deployment Manifests

Update image references in deployment files to use your project ID:

```bash
# Update user-service deployment
sed -i "s/YOUR-PROJECT-ID/$GCP_PROJECT_ID/g" infrastructure/kubernetes/deployments/user-service-deployment.yaml

# Update product-service deployment
sed -i "s/YOUR-PROJECT-ID/$GCP_PROJECT_ID/g" infrastructure/kubernetes/deployments/product-service-deployment.yaml

# Update order-service deployment
sed -i "s/YOUR-PROJECT-ID/$GCP_PROJECT_ID/g" infrastructure/kubernetes/deployments/order-service-deployment.yaml

# Update frontend deployment
sed -i "s/YOUR-PROJECT-ID/$GCP_PROJECT_ID/g" infrastructure/kubernetes/deployments/frontend-deployment.yaml
```

### 9.2 Deploy Backend Services

**1. Deploy User Service:**
```bash
kubectl apply -f infrastructure/kubernetes/deployments/user-service-deployment.yaml
kubectl apply -f infrastructure/kubernetes/services/user-service-service.yaml

# Wait for rollout
kubectl rollout status deployment/user-service -n ecommerce

# Check pods
kubectl get pods -n ecommerce -l app=user-service
```

**2. Deploy Product Service:**
```bash
kubectl apply -f infrastructure/kubernetes/deployments/product-service-deployment.yaml
kubectl apply -f infrastructure/kubernetes/services/product-service-service.yaml

kubectl rollout status deployment/product-service -n ecommerce
kubectl get pods -n ecommerce -l app=product-service
```

**3. Deploy Order Service:**
```bash
kubectl apply -f infrastructure/kubernetes/deployments/order-service-deployment.yaml
kubectl apply -f infrastructure/kubernetes/services/order-service-service.yaml

kubectl rollout status deployment/order-service -n ecommerce
kubectl get pods -n ecommerce -l app=order-service
```

### 9.3 Deploy Frontend

```bash
kubectl apply -f infrastructure/kubernetes/deployments/frontend-deployment.yaml
kubectl apply -f infrastructure/kubernetes/services/frontend-service.yaml

kubectl rollout status deployment/frontend -n ecommerce
kubectl get pods -n ecommerce -l app=frontend
```

### 9.4 Deploy Ingress

```bash
# Deploy ingress controller (if not already installed)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Wait for ingress controller
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Deploy application ingress
kubectl apply -f infrastructure/kubernetes/ingress/ingress.yaml

# Get ingress IP
kubectl get ingress -n ecommerce
```

### 9.5 Verify All Deployments

```bash
# Check all pods
kubectl get pods -n ecommerce

# Check all services
kubectl get services -n ecommerce

# Check ingress
kubectl get ingress -n ecommerce

# View logs
kubectl logs -f -n ecommerce deployment/user-service
kubectl logs -f -n ecommerce deployment/product-service
kubectl logs -f -n ecommerce deployment/order-service
kubectl logs -f -n ecommerce deployment/frontend
```

Expected output:
```
NAME                              READY   STATUS    RESTARTS   AGE
user-service-xxx-xxx              1/1     Running   0          5m
user-service-xxx-xxx              1/1     Running   0          5m
user-service-xxx-xxx              1/1     Running   0          5m
product-service-xxx-xxx           1/1     Running   0          5m
product-service-xxx-xxx           1/1     Running   0          5m
product-service-xxx-xxx           1/1     Running   0          5m
order-service-xxx-xxx             1/1     Running   0          5m
order-service-xxx-xxx             1/1     Running   0          5m
order-service-xxx-xxx             1/1     Running   0          5m
frontend-xxx-xxx                  1/1     Running   0          5m
frontend-xxx-xxx                  1/1     Running   0          5m
frontend-xxx-xxx                  1/1     Running   0          5m
```

---

## 10. Configure API Gateway (Kong)

Kong API Gateway provides unified API management, routing, authentication, and rate limiting.

### 10.1 Deploy Kong

**1. Add Kong Helm repository:**
```bash
helm repo add kong https://charts.konghq.com
helm repo update
```

**2. Create Kong values file:**

The `infrastructure/kubernetes/kong-values.yaml` contains Kong configuration. Review it:

```bash
cat infrastructure/kubernetes/kong-values.yaml
```

**3. Install Kong:**
```bash
# Create kong namespace
kubectl create namespace kong

# Install Kong with Helm
helm install kong kong/kong \
  --namespace kong \
  --values infrastructure/kubernetes/kong-values.yaml \
  --set proxy.type=LoadBalancer \
  --set ingressController.enabled=true

# Wait for Kong to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kong -n kong --timeout=300s
```

**4. Get Kong endpoints:**
```bash
# Get Kong Proxy LoadBalancer IP
KONG_PROXY_IP=$(kubectl get svc -n kong kong-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Kong Proxy: http://$KONG_PROXY_IP"

# Get Kong Admin LoadBalancer IP
KONG_ADMIN_IP=$(kubectl get svc -n kong kong-kong-admin -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Kong Admin: http://$KONG_ADMIN_IP:8001"

# Export for later use
export KONG_PROXY_IP
export KONG_ADMIN_IP
```

### 10.2 Configure Kong Routes

**Option A: Using the configuration script:**

```bash
# Update the script with your Kong Admin IP
cd infrastructure/kubernetes
sed -i "s/34.44.244.168/$KONG_ADMIN_IP/g" configure-kong-routes.sh

# Make executable
chmod +x configure-kong-routes.sh

# Run configuration
./configure-kong-routes.sh
```

**Option B: Manual configuration via Kong Admin API:**

```bash
# 1. Create User Service
curl -i -X POST http://$KONG_ADMIN_IP:8001/services \
  --data name=user-service \
  --data url='http://user-service.ecommerce.svc.cluster.local:8081'

curl -i -X POST http://$KONG_ADMIN_IP:8001/services/user-service/routes \
  --data 'paths[]=/api/v1/users' \
  --data 'strip_path=false' \
  --data 'name=user-route'

# 2. Create Product Service
curl -i -X POST http://$KONG_ADMIN_IP:8001/services \
  --data name=product-service \
  --data url='http://product-service.ecommerce.svc.cluster.local:8082'

curl -i -X POST http://$KONG_ADMIN_IP:8001/services/product-service/routes \
  --data 'paths[]=/api/v1/products' \
  --data 'strip_path=false' \
  --data 'name=product-route'

# 3. Create Order Service
curl -i -X POST http://$KONG_ADMIN_IP:8001/services \
  --data name=order-service \
  --data url='http://order-service.ecommerce.svc.cluster.local:8083'

curl -i -X POST http://$KONG_ADMIN_IP:8001/services/order-service/routes \
  --data 'paths[]=/api/v1/orders' \
  --data 'strip_path=false' \
  --data 'name=order-route'

# 4. Create Frontend Service
curl -i -X POST http://$KONG_ADMIN_IP:8001/services \
  --data name=frontend \
  --data url='http://frontend.ecommerce.svc.cluster.local:80'

curl -i -X POST http://$KONG_ADMIN_IP:8001/services/frontend/routes \
  --data 'paths[]=/' \
  --data 'strip_path=false' \
  --data 'name=frontend-route'
```

### 10.3 Configure Kong Plugins

**1. Add Rate Limiting:**
```bash
# Rate limit for user service (100/min, 5000/hour)
curl -i -X POST http://$KONG_ADMIN_IP:8001/services/user-service/plugins \
  --data name=rate-limiting \
  --data config.minute=100 \
  --data config.hour=5000 \
  --data config.policy=local

# Rate limit for product service
curl -i -X POST http://$KONG_ADMIN_IP:8001/services/product-service/plugins \
  --data name=rate-limiting \
  --data config.minute=100 \
  --data config.hour=5000 \
  --data config.policy=local

# Rate limit for order service (more restrictive)
curl -i -X POST http://$KONG_ADMIN_IP:8001/services/order-service/plugins \
  --data name=rate-limiting \
  --data config.minute=50 \
  --data config.hour=2000 \
  --data config.policy=local
```

**2. Add CORS (Cross-Origin Resource Sharing):**
```bash
# CORS for user service
curl -i -X POST http://$KONG_ADMIN_IP:8001/services/user-service/plugins \
  --data name=cors \
  --data config.origins='*' \
  --data config.methods=GET,POST,PUT,PATCH,DELETE \
  --data config.headers=Accept,Content-Type,Authorization \
  --data config.exposed_headers=X-Auth-Token \
  --data config.credentials=true \
  --data config.max_age=3600

# CORS for product service
curl -i -X POST http://$KONG_ADMIN_IP:8001/services/product-service/plugins \
  --data name=cors \
  --data config.origins='*' \
  --data config.methods=GET,POST,PUT,PATCH,DELETE \
  --data config.headers=Accept,Content-Type,Authorization

# CORS for order service
curl -i -X POST http://$KONG_ADMIN_IP:8001/services/order-service/plugins \
  --data name=cors \
  --data config.origins='*' \
  --data config.methods=GET,POST,PUT,PATCH,DELETE \
  --data config.headers=Accept,Content-Type,Authorization
```

**3. Add Request/Response Logging (Optional):**
```bash
curl -i -X POST http://$KONG_ADMIN_IP:8001/plugins \
  --data name=file-log \
  --data config.path=/tmp/kong-access.log
```

**4. Add API Key Authentication (Optional):**
```bash
# Enable key-auth plugin on user service
curl -i -X POST http://$KONG_ADMIN_IP:8001/services/user-service/plugins \
  --data name=key-auth
```

### 10.4 Verify Kong Configuration

**1. List all services:**
```bash
curl http://$KONG_ADMIN_IP:8001/services | jq '.'
```

**2. List all routes:**
```bash
curl http://$KONG_ADMIN_IP:8001/routes | jq '.'
```

**3. List all plugins:**
```bash
curl http://$KONG_ADMIN_IP:8001/plugins | jq '.'
```

**4. Test routes via Kong Proxy:**
```bash
# Test product service through Kong
curl http://$KONG_PROXY_IP/api/v1/products

# Test user service
curl http://$KONG_PROXY_IP/api/v1/users/health

# Test frontend
curl http://$KONG_PROXY_IP/
```

### 10.5 Kong Ingress Controller (Alternative)

If you prefer declarative configuration using Kubernetes resources:

```yaml
# infrastructure/kubernetes/kong-ingress-routes.yaml
apiVersion: configuration.konghq.com/v1
kind: KongIngress
metadata:
  name: api-rate-limit
  namespace: ecommerce
route:
  strip_path: false
---
apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  name: rate-limiting
  namespace: ecommerce
plugin: rate-limiting
config:
  minute: 100
  hour: 5000
  policy: local
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kong-api-ingress
  namespace: ecommerce
  annotations:
    konghq.com/plugins: rate-limiting
    konghq.com/strip-path: "false"
spec:
  ingressClassName: kong
  rules:
  - http:
      paths:
      - path: /api/v1/users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 8081
      - path: /api/v1/products
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 8082
      - path: /api/v1/orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 8083
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
```

Apply:
```bash
kubectl apply -f infrastructure/kubernetes/kong-ingress-routes.yaml
```

---

## 11. Setup Monitoring

Deploy Prometheus and Grafana for monitoring the e-commerce platform.

### 11.1 Deploy Prometheus

**1. Add Prometheus Helm repository:**
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

**2. Create monitoring namespace:**
```bash
kubectl create namespace monitoring
```

**3. Install Prometheus:**
```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.retention=30d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi \
  --set grafana.enabled=true \
  --set grafana.adminPassword=admin123 \
  --set alertmanager.enabled=true

# Wait for deployment
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s
```

**4. Verify Prometheus deployment:**
```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

### 11.2 Access Prometheus UI

**Option A: Port-forward (for testing):**
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090 &
```

Then access: http://localhost:9090

**Option B: Create LoadBalancer service:**
```yaml
# Create file: prometheus-lb.yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus-external
  namespace: monitoring
spec:
  type: LoadBalancer
  ports:
  - port: 9090
    targetPort: 9090
  selector:
    app.kubernetes.io/name: prometheus
    prometheus: prometheus-kube-prometheus-prometheus
```

Apply:
```bash
kubectl apply -f prometheus-lb.yaml
kubectl get svc -n monitoring prometheus-external
```

### 11.3 Deploy Grafana

Grafana is already included with kube-prometheus-stack. Let's access it:

**1. Get Grafana LoadBalancer IP:**
```bash
# Expose Grafana via LoadBalancer
kubectl patch svc prometheus-grafana -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'

# Get external IP
GRAFANA_IP=$(kubectl get svc -n monitoring prometheus-grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Grafana: http://$GRAFANA_IP"
```

**2. Login to Grafana:**
- URL: http://<GRAFANA_IP>
- Username: `admin`
- Password: `admin123` (or the password you set)

**3. Verify Prometheus data source:**
- Go to Configuration → Data Sources
- You should see Prometheus already configured
- URL: http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090

### 11.4 Import E-Commerce Dashboard

**1. Create custom dashboard for e-commerce metrics:**

Apply the pre-configured dashboard:
```bash
kubectl apply -f infrastructure/monitoring/grafana-dashboard-configmap.yaml
```

**2. Import dashboard in Grafana UI:**
- Go to Dashboards → Import
- Upload `infrastructure/monitoring/grafana-ecommerce-dashboard.json`
- Select Prometheus data source
- Click Import

**3. Dashboard includes:**
- Total requests per service
- Response times (p50, p95, p99)
- Error rates
- Pod CPU and memory usage
- Database connection pool metrics
- Redis cache hit ratio
- Order processing time
- Active user sessions

### 11.5 Configure ServiceMonitor for Custom Metrics

Spring Boot Actuator exposes metrics that Prometheus can scrape:

```yaml
# infrastructure/kubernetes/config/servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ecommerce-services
  namespace: ecommerce
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      metrics: enabled
  endpoints:
  - port: http
    path: /actuator/prometheus
    interval: 30s
---
# Update service labels to enable monitoring
# Example for user-service-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: ecommerce
  labels:
    app: user-service
    metrics: enabled  # Add this label
spec:
  selector:
    app: user-service
  ports:
  - port: 8081
    targetPort: 8081
    name: http
```

Apply:
```bash
kubectl apply -f infrastructure/kubernetes/config/servicemonitor.yaml

# Update existing services with metrics label
kubectl label service user-service metrics=enabled -n ecommerce
kubectl label service product-service metrics=enabled -n ecommerce
kubectl label service order-service metrics=enabled -n ecommerce
```

### 11.6 Set Up Alerts

**1. Create PrometheusRule for alerts:**

```yaml
# alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: ecommerce-alerts
  namespace: monitoring
  labels:
    release: prometheus
spec:
  groups:
  - name: ecommerce
    interval: 30s
    rules:
    - alert: HighErrorRate
      expr: rate(http_server_requests_seconds_count{status=~"5.."}[5m]) > 0.05
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High error rate detected"
        description: "Service {{ $labels.service }} has error rate above 5%"
    
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ $labels.pod }} is restarting frequently"
    
    - alert: HighMemoryUsage
      expr: container_memory_usage_bytes{pod=~".*-service-.*"} / container_spec_memory_limit_bytes > 0.9
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage"
        description: "Pod {{ $labels.pod }} memory usage above 90%"
    
    - alert: DatabaseConnectionPoolExhausted
      expr: hikaricp_connections_active / hikaricp_connections_max > 0.9
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "Database connection pool near capacity"
        description: "Service {{ $labels.service }} connection pool at {{ $value }}%"
```

Apply:
```bash
kubectl apply -f alerts.yaml
```

**2. View active alerts:**
- Go to Prometheus UI: http://<PROMETHEUS_IP>:9090/alerts
- Or in Grafana: Alerting → Alert Rules

### 11.7 Monitoring Endpoints

Key metrics endpoints:

| Service | Metrics Endpoint | Health Check |
|---------|-----------------|--------------|
| User Service | http://user-service:8081/actuator/prometheus | http://user-service:8081/actuator/health |
| Product Service | http://product-service:8082/actuator/prometheus | http://product-service:8082/actuator/health |
| Order Service | http://order-service:8083/actuator/prometheus | http://order-service:8083/actuator/health |
| Prometheus | http://<PROMETHEUS_IP>:9090 | http://<PROMETHEUS_IP>:9090/-/ready |
| Grafana | http://<GRAFANA_IP> | http://<GRAFANA_IP>/api/health |

---

## 12. CI/CD Pipeline Setup

Set up automated build and deployment pipelines using Cloud Build.

### 12.1 Cloud Build Configuration

Each service has a `cloudbuild.yaml` file that defines the build pipeline.

**Example: User Service CI/CD Pipeline**

The file `backend/user-service/cloudbuild.yaml` contains:
- Maven build and test
- Docker image build
- Push to Artifact Registry
- Deploy to GKE
- Rollout verification

### 12.2 Create Cloud Build Triggers

**1. Connect GitHub repository:**
```bash
# Go to Cloud Build in Console
# https://console.cloud.google.com/cloud-build/triggers

# Or use gcloud CLI
gcloud beta builds triggers create github \
  --repo-name=gcp-three-tier-ecommerce-project \
  --repo-owner=rupesh9999 \
  --branch-pattern="^main$" \
  --build-config=backend/user-service/cloudbuild.yaml \
  --description="Build and deploy user-service on push to main" \
  --include-filter="backend/user-service/**" \
  --name=user-service-trigger
```

**2. Create triggers for all services:**

```bash
# Product Service
gcloud beta builds triggers create github \
  --repo-name=gcp-three-tier-ecommerce-project \
  --repo-owner=rupesh9999 \
  --branch-pattern="^main$" \
  --build-config=backend/product-service/cloudbuild.yaml \
  --include-filter="backend/product-service/**" \
  --name=product-service-trigger

# Order Service
gcloud beta builds triggers create github \
  --repo-name=gcp-three-tier-ecommerce-project \
  --repo-owner=rupesh9999 \
  --branch-pattern="^main$" \
  --build-config=backend/order-service/cloudbuild.yaml \
  --include-filter="backend/order-service/**" \
  --name=order-service-trigger

# Frontend
gcloud beta builds triggers create github \
  --repo-name=gcp-three-tier-ecommerce-project \
  --repo-owner=rupesh9999 \
  --branch-pattern="^main$" \
  --build-config=frontend/cloudbuild.yaml \
  --include-filter="frontend/**" \
  --name=frontend-trigger
```

**3. List all triggers:**
```bash
gcloud builds triggers list
```

### 12.3 Manual Build Execution

Trigger a build manually:

```bash
# Build user service
gcloud builds submit \
  --config=backend/user-service/cloudbuild.yaml \
  --project=$GCP_PROJECT_ID \
  backend/user-service/

# Build product service
gcloud builds submit \
  --config=backend/product-service/cloudbuild.yaml \
  --project=$GCP_PROJECT_ID \
  backend/product-service/

# Build order service
gcloud builds submit \
  --config=backend/order-service/cloudbuild.yaml \
  --project=$GCP_PROJECT_ID \
  backend/order-service/

# Build frontend
gcloud builds submit \
  --config=frontend/cloudbuild.yaml \
  --project=$GCP_PROJECT_ID \
  frontend/
```

### 12.4 Jenkins CI/CD (Alternative)

If you prefer Jenkins:

**1. Deploy Jenkins to GKE:**
```bash
kubectl apply -f infrastructure/kubernetes/jenkins/jenkins-deployment.yaml

# Wait for Jenkins
kubectl wait --for=condition=ready pod -l app=jenkins -n jenkins --timeout=300s

# Get Jenkins LoadBalancer IP
JENKINS_IP=$(kubectl get svc jenkins -n jenkins -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Jenkins: http://$JENKINS_IP:8080"
```

**2. Get Jenkins admin password:**
```bash
kubectl exec -n jenkins $(kubectl get pod -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /var/jenkins_home/secrets/initialAdminPassword
```

**3. Configure Jenkins:**
- Access: http://<JENKINS_IP>:8080
- Enter admin password from step 2
- Install suggested plugins
- Install additional plugins:
  - Google Kubernetes Engine Plugin
  - Docker Pipeline Plugin
  - GitHub Integration Plugin

**4. Create Jenkins pipelines:**

Each service has a `Jenkinsfile` (if present) that defines the pipeline.

Example Jenkinsfile structure:
```groovy
pipeline {
    agent any
    
    environment {
        GCP_PROJECT = credentials('gcp-project-id')
        ARTIFACT_REGISTRY = 'us-central1-docker.pkg.dev'
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('Docker Build') {
            steps {
                sh """
                    docker build -t ${ARTIFACT_REGISTRY}/${GCP_PROJECT}/ecommerce-repo/user-service:${BUILD_NUMBER} .
                    docker push ${ARTIFACT_REGISTRY}/${GCP_PROJECT}/ecommerce-repo/user-service:${BUILD_NUMBER}
                """
            }
        }
        
        stage('Deploy to GKE') {
            steps {
                sh """
                    kubectl set image deployment/user-service \
                        user-service=${ARTIFACT_REGISTRY}/${GCP_PROJECT}/ecommerce-repo/user-service:${BUILD_NUMBER} \
                        -n ecommerce
                """
            }
        }
    }
}
```

**5. Configure GitHub webhook:**
- Go to GitHub repository settings
- Webhooks → Add webhook
- Payload URL: http://<JENKINS_IP>:8080/github-webhook/
- Content type: application/json
- Select: Just the push event
- Active: ✓

### 12.5 View Build History

**Cloud Build:**
```bash
# List recent builds
gcloud builds list --limit=10

# Get specific build details
gcloud builds describe <BUILD_ID>

# View build logs
gcloud builds log <BUILD_ID>

# Or view in Console
# https://console.cloud.google.com/cloud-build/builds
```

**Jenkins:**
- Access: http://<JENKINS_IP>:8080/blue
- View pipeline execution history
- Check console output for each build

### 12.6 CI/CD Best Practices Implemented

1. **Automated Testing:** Maven tests run before Docker build
2. **Image Tagging:** Uses build ID and 'latest' tags
3. **Rollout Verification:** Waits for Kubernetes rollout to complete
4. **Health Checks:** Verifies pods are running after deployment
5. **Path Filtering:** Only builds when relevant files change
6. **Parallel Builds:** Multiple services can build simultaneously
7. **Rollback Capability:** Previous images remain in registry

---

## 13. Testing and Validation

Comprehensive testing to ensure the platform works correctly.

### 13.1 Health Checks

**1. Check all pods are running:**
```bash
kubectl get pods -n ecommerce
```

Expected: All pods show `Running` status with `1/1` or `2/2` ready.

**2. Check services:**
```bash
kubectl get svc -n ecommerce
```

**3. Test service health endpoints:**
```bash
# User service
kubectl run -it --rm test-pod --image=curlimages/curl --restart=Never -n ecommerce -- \
  curl http://user-service:8081/actuator/health

# Product service
kubectl run -it --rm test-pod --image=curlimages/curl --restart=Never -n ecommerce -- \
  curl http://product-service:8082/actuator/health

# Order service
kubectl run -it --rm test-pod --image=curlimages/curl --restart=Never -n ecommerce -- \
  curl http://order-service:8083/actuator/health
```

### 13.2 API Testing

**1. Get ingress IP:**
```bash
INGRESS_IP=$(kubectl get ingress ecommerce-ingress -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Application URL: http://$INGRESS_IP"
```

**2. Test user registration:**
```bash
curl -X POST http://$INGRESS_IP/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser123",
    "email": "testuser123@example.com",
    "password": "SecurePass123!",
    "firstName": "Test",
    "lastName": "User"
  }' | jq '.'
```

Expected response:
```json
{
  "id": 1,
  "username": "testuser123",
  "email": "testuser123@example.com",
  "firstName": "Test",
  "lastName": "User",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**3. Test user login:**
```bash
LOGIN_RESPONSE=$(curl -s -X POST http://$INGRESS_IP/api/v1/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser123",
    "password": "SecurePass123!"
  }')

# Extract token
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')
echo "Token: $TOKEN"
```

**4. Test product listing:**
```bash
curl http://$INGRESS_IP/api/v1/products | jq '.'
```

**5. Test create order (authenticated):**
```bash
curl -X POST http://$INGRESS_IP/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "items": [
      {
        "productId": 1,
        "quantity": 2,
        "price": 1299.99
      }
    ],
    "totalAmount": 2599.98,
    "shippingAddress": "123 Test St, City, State 12345"
  }' | jq '.'
```

### 13.3 Kong Gateway Testing

**1. Test through Kong Proxy:**
```bash
# Get Kong Proxy IP
KONG_PROXY=$(kubectl get svc -n kong kong-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test products through Kong
curl http://$KONG_PROXY/api/v1/products | jq '.'

# Test rate limiting (send 110 requests in 1 minute)
for i in {1..110}; do
  curl -s http://$KONG_PROXY/api/v1/products > /dev/null
  echo "Request $i"
done
```

After ~100 requests, you should see:
```json
{
  "message": "API rate limit exceeded"
}
```

**2. Verify Kong plugins:**
```bash
KONG_ADMIN=$(kubectl get svc -n kong kong-kong-admin -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$KONG_ADMIN:8001/plugins | jq '.data[] | {name: .name, service: .service.name}'
```

### 13.4 Database Testing

**1. Connect to Cloud SQL:**
```bash
# Start Cloud SQL Proxy if not running
./cloud_sql_proxy -instances=$CLOUDSQL_CONNECTION=tcp:5432 &

# Connect to database
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -d ecommerce_users
```

**2. Verify data:**
```sql
-- Check registered users
SELECT id, username, email, created_at FROM users ORDER BY created_at DESC LIMIT 10;

-- Check user count
SELECT COUNT(*) as total_users FROM users;

-- Exit
\q
```

**3. Test Redis connection:**
```bash
# Port-forward to Redis
kubectl port-forward -n ecommerce svc/redis 6379:6379 &

# Connect with redis-cli (if installed)
redis-cli -h 127.0.0.1 -p 6379

# Or use kubectl exec
kubectl run -it --rm redis-test --image=redis:7-alpine --restart=Never -n ecommerce -- redis-cli -h $REDIS_HOST ping
```

### 13.5 Load Testing

**1. Install Apache Bench (ab):**
```bash
sudo apt-get install apache2-utils  # Ubuntu/Debian
```

**2. Run load test on product listing:**
```bash
ab -n 1000 -c 50 http://$INGRESS_IP/api/v1/products
```

This sends 1000 requests with 50 concurrent connections.

**3. Analyze results:**
- Requests per second
- Time per request
- Connection times (mean, median)
- Failed requests (should be 0)

**4. Use k6 for advanced load testing:**

Create load test script:
```javascript
// loadtest.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '1m', target: 50 },  // Ramp up to 50 users
    { duration: '3m', target: 50 },  // Stay at 50 users
    { duration: '1m', target: 0 },   // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.01'],   // Error rate under 1%
  },
};

export default function () {
  // Test product listing
  let res = http.get(`http://${__ENV.INGRESS_IP}/api/v1/products`);
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  sleep(1);
}
```

Run:
```bash
k6 run -e INGRESS_IP=$INGRESS_IP loadtest.js
```

### 13.6 End-to-End Testing

**1. Test complete user journey:**

```bash
#!/bin/bash
# e2e-test.sh

set -e

INGRESS_IP=$(kubectl get ingress ecommerce-ingress -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
BASE_URL="http://$INGRESS_IP"

echo "=== E2E Test: Complete User Journey ==="

# Step 1: Register user
echo "Step 1: Register user..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "e2etest_'$(date +%s)'",
    "email": "e2etest_'$(date +%s)'@example.com",
    "password": "Test123!",
    "firstName": "E2E",
    "lastName": "Test"
  }')

USER_ID=$(echo $REGISTER_RESPONSE | jq -r '.id')
TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.token')
echo "✓ User created with ID: $USER_ID"

# Step 2: Login
echo "Step 2: Login..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/v1/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "'$(echo $REGISTER_RESPONSE | jq -r '.username')'",
    "password": "Test123!"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')
echo "✓ Login successful, token received"

# Step 3: Browse products
echo "Step 3: Browse products..."
PRODUCTS=$(curl -s $BASE_URL/api/v1/products)
PRODUCT_ID=$(echo $PRODUCTS | jq -r '.[0].id')
PRODUCT_PRICE=$(echo $PRODUCTS | jq -r '.[0].price')
echo "✓ Retrieved products, selected product ID: $PRODUCT_ID"

# Step 4: Create order
echo "Step 4: Create order..."
ORDER_RESPONSE=$(curl -s -X POST $BASE_URL/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "items": [
      {
        "productId": '$PRODUCT_ID',
        "quantity": 1,
        "price": '$PRODUCT_PRICE'
      }
    ],
    "totalAmount": '$PRODUCT_PRICE',
    "shippingAddress": "123 E2E Test St"
  }')

ORDER_ID=$(echo $ORDER_RESPONSE | jq -r '.id')
echo "✓ Order created with ID: $ORDER_ID"

# Step 5: Get order details
echo "Step 5: Get order details..."
ORDER_DETAILS=$(curl -s $BASE_URL/api/v1/orders/$ORDER_ID \
  -H "Authorization: Bearer $TOKEN")
ORDER_STATUS=$(echo $ORDER_DETAILS | jq -r '.status')
echo "✓ Order status: $ORDER_STATUS"

echo ""
echo "=== E2E Test Completed Successfully! ==="
```

Make executable and run:
```bash
chmod +x e2e-test.sh
./e2e-test.sh
```

### 13.7 Monitoring Validation

**1. Check metrics in Prometheus:**
- Go to Prometheus UI
- Query: `http_server_requests_seconds_count{job="user-service"}`
- Should show request counts

**2. View dashboards in Grafana:**
- Access Grafana
- Open E-Commerce Dashboard
- Verify metrics are populating

**3. Test alerting:**
```bash
# Trigger high error rate by sending malformed requests
for i in {1..100}; do
  curl -s -X POST http://$INGRESS_IP/api/v1/users/register \
    -H "Content-Type: application/json" \
    -d '{}' > /dev/null
done

# Check alerts in Prometheus after 5 minutes
```

---

## 14. Troubleshooting Guide

Common issues and their solutions.

### 14.1 Pod Issues

**Problem: Pods stuck in Pending state**

```bash
# Check pod events
kubectl describe pod <POD_NAME> -n ecommerce

# Common causes and solutions:
# 1. Insufficient resources
kubectl describe nodes  # Check node capacity

# Solution: Scale up node pool
gcloud container clusters resize ecommerce-cluster \
  --num-nodes=4 \
  --zone=us-central1-a

# 2. Image pull errors
kubectl get events -n ecommerce --sort-by='.lastTimestamp'

# Solution: Verify image exists
gcloud artifacts docker images list us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo
```

**Problem: Pods in CrashLoopBackOff**

```bash
# Check logs
kubectl logs <POD_NAME> -n ecommerce --previous

# Common causes:
# 1. Database connection failure
# Check database connectivity
kubectl run -it --rm db-test --image=postgres:15 --restart=Never -n ecommerce -- \
  psql -h $CLOUDSQL_CONNECTION -U postgres -c "SELECT 1"

# 2. Missing ConfigMap or Secret
kubectl get configmaps -n ecommerce
kubectl get secrets -n ecommerce

# Recreate if missing (see section 7.4)

# 3. Application error
kubectl logs -f <POD_NAME> -n ecommerce
```

**Problem: Pods running but not ready**

```bash
# Check readiness probe
kubectl describe pod <POD_NAME> -n ecommerce | grep -A 10 "Readiness"

# Test health endpoint manually
kubectl exec -it <POD_NAME> -n ecommerce -- curl localhost:8081/actuator/health
```

### 14.2 Service Issues

**Problem: Service not accessible**

```bash
# 1. Check service exists
kubectl get svc -n ecommerce

# 2. Check endpoints
kubectl get endpoints <SERVICE_NAME> -n ecommerce

# If endpoints are empty, no pods match selector
kubectl get pods -n ecommerce --show-labels
kubectl describe svc <SERVICE_NAME> -n ecommerce

# 3. Test from within cluster
kubectl run -it --rm test-pod --image=curlimages/curl --restart=Never -n ecommerce -- \
  curl http://<SERVICE_NAME>:8081/actuator/health
```

**Problem: LoadBalancer IP not assigned**

```bash
# Check service
kubectl describe svc <SERVICE_NAME> -n ecommerce

# Common causes:
# 1. GCP quota exceeded
gcloud compute project-info describe --project=$GCP_PROJECT_ID

# 2. Takes time to provision (wait 5-10 minutes)
kubectl get svc -w -n ecommerce

# 3. Use NodePort temporarily
kubectl patch svc <SERVICE_NAME> -n ecommerce -p '{"spec":{"type":"NodePort"}}'
```

### 14.3 Database Issues

**Problem: Cannot connect to Cloud SQL**

```bash
# 1. Check Cloud SQL Proxy is running
ps aux | grep cloud_sql_proxy

# Start if not running
./cloud_sql_proxy -instances=$CLOUDSQL_CONNECTION=tcp:5432 &

# 2. Check instance is running
gcloud sql instances describe ecommerce-postgres

# 3. Verify connection string
echo $CLOUDSQL_CONNECTION

# 4. Test connection
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -c "SELECT 1"
```

**Problem: Database migration failures**

```bash
# Check current schema
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -d ecommerce_users -c "\dt"

# Re-run schema
PGPASSWORD=$DB_PASSWORD psql -h 127.0.0.1 -U postgres -d ecommerce_users \
  -f database/postgresql/users/schema.sql

# Check for errors in application logs
kubectl logs -f <POD_NAME> -n ecommerce | grep -i "database\|sql"
```

### 14.4 Ingress Issues

**Problem: Ingress not getting IP**

```bash
# Check ingress status
kubectl describe ingress ecommerce-ingress -n ecommerce

# Check ingress controller
kubectl get pods -n ingress-nginx

# Reinstall ingress controller
kubectl delete namespace ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

**Problem: 502 Bad Gateway**

```bash
# 1. Check backend services are running
kubectl get pods -n ecommerce

# 2. Check service endpoints
kubectl get endpoints -n ecommerce

# 3. Test backend directly
kubectl port-forward svc/user-service -n ecommerce 8081:8081 &
curl http://localhost:8081/actuator/health

# 4. Check ingress logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### 14.5 Kong Issues

**Problem: Kong routes not working**

```bash
# 1. Check Kong pods
kubectl get pods -n kong

# 2. Verify routes
KONG_ADMIN=$(kubectl get svc -n kong kong-kong-admin -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$KONG_ADMIN:8001/routes | jq '.'

# 3. Reconfigure routes
cd infrastructure/kubernetes
./configure-kong-routes.sh

# 4. Check Kong logs
kubectl logs -f -n kong -l app.kubernetes.io/name=kong
```

### 14.6 CI/CD Issues

**Problem: Cloud Build fails**

```bash
# Get build logs
gcloud builds list --limit=1
gcloud builds log <BUILD_ID>

# Common issues:
# 1. IAM permissions
gcloud projects get-iam-policy $GCP_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com"

# Grant missing permissions
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/container.developer"

# 2. Timeout - increase in cloudbuild.yaml
# timeout: 1800s  # 30 minutes

# 3. Test locally
cd backend/user-service
gcloud builds submit --config=cloudbuild.yaml .
```

### 14.7 Performance Issues

**Problem: Slow API response times**

```bash
# 1. Check pod resource usage
kubectl top pods -n ecommerce

# 2. Check HPA status
kubectl get hpa -n ecommerce

# If HPA doesn't exist, create it
kubectl autoscale deployment user-service \
  --cpu-percent=70 \
  --min=3 \
  --max=10 \
  -n ecommerce

# 3. Check database connection pool
kubectl logs <POD_NAME> -n ecommerce | grep -i "pool\|connection"

# 4. Enable query logging
kubectl exec -it <POD_NAME> -n ecommerce -- sh
# Edit application.yml to set logging.level.org.hibernate.SQL=DEBUG

# 5. Check Redis cache
kubectl port-forward svc/redis -n ecommerce 6379:6379 &
redis-cli -h localhost INFO stats
```

**Problem: High memory usage**

```bash
# Check memory usage
kubectl top pods -n ecommerce

# Increase memory limits
kubectl set resources deployment/user-service \
  --limits=memory=2Gi \
  --requests=memory=1Gi \
  -n ecommerce

# Check for memory leaks
kubectl exec -it <POD_NAME> -n ecommerce -- jmap -heap 1
```

### 14.8 Useful Debugging Commands

```bash
# Get all resources in namespace
kubectl get all -n ecommerce

# Describe pod with full details
kubectl describe pod <POD_NAME> -n ecommerce

# Get logs from all pods of a deployment
kubectl logs -f -n ecommerce deployment/user-service --all-containers=true

# Execute command in pod
kubectl exec -it <POD_NAME> -n ecommerce -- bash

# Port forward to service
kubectl port-forward svc/user-service -n ecommerce 8081:8081

# Get events sorted by time
kubectl get events -n ecommerce --sort-by='.lastTimestamp'

# Check resource quotas
kubectl describe resourcequota -n ecommerce

# Get pod YAML
kubectl get pod <POD_NAME> -n ecommerce -o yaml

# Copy files from pod
kubectl cp ecommerce/<POD_NAME>:/path/to/file ./local-file

# Run debug container
kubectl debug <POD_NAME> -n ecommerce -it --image=busybox --share-processes
```

---

## 15. Operations and Maintenance

Ongoing operational tasks and maintenance procedures.

### 15.1 Backup Procedures

**1. Backup Cloud SQL:**
```bash
# Create on-demand backup
gcloud sql backups create \
  --instance=ecommerce-postgres \
  --description="Manual backup before maintenance"

# List backups
gcloud sql backups list --instance=ecommerce-postgres

# Configure automated backups (already set in Terraform)
gcloud sql instances patch ecommerce-postgres \
  --backup-start-time=03:00 \
  --retained-backups-count=30
```

**2. Export database:**
```bash
# Export to Cloud Storage
gcloud sql export sql ecommerce-postgres \
  gs://ecommerce-backups-$GCP_PROJECT_ID/backup-$(date +%Y%m%d).sql \
  --database=ecommerce_users,ecommerce_products,ecommerce_orders
```

**3. Backup Kubernetes configurations:**
```bash
# Backup all resources
kubectl get all -n ecommerce -o yaml > k8s-backup-$(date +%Y%m%d).yaml

# Backup configmaps and secrets
kubectl get configmaps -n ecommerce -o yaml > configmaps-backup.yaml
kubectl get secrets -n ecommerce -o yaml > secrets-backup.yaml

# Upload to Cloud Storage
gsutil cp k8s-backup-$(date +%Y%m%d).yaml gs://ecommerce-backups-$GCP_PROJECT_ID/
```

### 15.2 Restore Procedures

**1. Restore from Cloud SQL backup:**
```bash
# List available backups
gcloud sql backups list --instance=ecommerce-postgres

# Restore from backup
gcloud sql backups restore <BACKUP_ID> \
  --backup-instance=ecommerce-postgres \
  --backup-id=<BACKUP_ID>
```

**2. Restore from SQL export:**
```bash
gcloud sql import sql ecommerce-postgres \
  gs://ecommerce-backups-$GCP_PROJECT_ID/backup-20241117.sql \
  --database=ecommerce_users
```

**3. Restore Kubernetes resources:**
```bash
kubectl apply -f k8s-backup-20241117.yaml
```

### 15.3 Scaling

**1. Scale pods manually:**
```bash
# Scale specific deployment
kubectl scale deployment user-service --replicas=5 -n ecommerce

# Scale all backend services
kubectl scale deployment product-service --replicas=5 -n ecommerce
kubectl scale deployment order-service --replicas=5 -n ecommerce
```

**2. Configure Horizontal Pod Autoscaler:**
```bash
# Create HPA for user service
kubectl autoscale deployment user-service \
  --cpu-percent=70 \
  --min=3 \
  --max=10 \
  -n ecommerce

# Create HPA for product service
kubectl autoscale deployment product-service \
  --cpu-percent=70 \
  --min=3 \
  --max=10 \
  -n ecommerce

# Create HPA for order service
kubectl autoscale deployment order-service \
  --cpu-percent=70 \
  --min=3 \
  --max=10 \
  -n ecommerce

# Check HPA status
kubectl get hpa -n ecommerce
```

**3. Scale GKE cluster:**
```bash
# Scale node pool
gcloud container clusters resize ecommerce-cluster \
  --num-nodes=5 \
  --zone=us-central1-a

# Enable cluster autoscaling
gcloud container clusters update ecommerce-cluster \
  --enable-autoscaling \
  --min-nodes=3 \
  --max-nodes=10 \
  --zone=us-central1-a
```

**4. Scale database:**
```bash
# Upgrade Cloud SQL tier
gcloud sql instances patch ecommerce-postgres \
  --tier=db-custom-4-15360  # 4 vCPU, 15GB RAM

# Scale Redis
gcloud redis instances update ecommerce-redis \
  --size=10 \
  --region=us-central1
```

### 15.4 Updates and Rollouts

**1. Update application image:**
```bash
# Update to new version
kubectl set image deployment/user-service \
  user-service=us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo/user-service:v2.0.0 \
  -n ecommerce

# Watch rollout progress
kubectl rollout status deployment/user-service -n ecommerce

# Check rollout history
kubectl rollout history deployment/user-service -n ecommerce
```

**2. Rollback deployment:**
```bash
# Rollback to previous version
kubectl rollout undo deployment/user-service -n ecommerce

# Rollback to specific revision
kubectl rollout undo deployment/user-service --to-revision=2 -n ecommerce

# Verify
kubectl rollout status deployment/user-service -n ecommerce
```

**3. Update ConfigMap or Secret:**
```bash
# Update ConfigMap
kubectl create configmap database-config \
  --from-literal=user-service-db=ecommerce_users \
  --from-literal=product-service-db=ecommerce_products \
  --from-literal=order-service-db=ecommerce_orders \
  --from-literal=db-host=$CLOUDSQL_CONNECTION \
  --from-literal=db-port=5432 \
  -n ecommerce \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart pods to pick up changes
kubectl rollout restart deployment/user-service -n ecommerce
```

**4. Update GKE cluster:**
```bash
# Check available versions
gcloud container get-server-config --zone=us-central1-a

# Upgrade master
gcloud container clusters upgrade ecommerce-cluster \
  --master \
  --cluster-version=1.28 \
  --zone=us-central1-a

# Upgrade nodes (one by one)
gcloud container clusters upgrade ecommerce-cluster \
  --zone=us-central1-a
```

### 15.5 Monitoring and Alerts

**1. Check cluster health:**
```bash
# Cluster info
kubectl cluster-info

# Node status
kubectl get nodes
kubectl top nodes

# Component status
kubectl get componentstatuses
```

**2. Review logs:**
```bash
# Application logs
kubectl logs -f deployment/user-service -n ecommerce --tail=100

# View logs in Cloud Logging
gcloud logging read "resource.type=k8s_container AND resource.labels.namespace_name=ecommerce" \
  --limit=50 \
  --format=json
```

**3. Set up uptime checks:**
```bash
# Create uptime check
gcloud monitoring uptime create http-check \
  --display-name="E-Commerce Frontend" \
  --resource-type=uptime-url \
  --host=$INGRESS_IP \
  --path="/"
```

### 15.6 Cost Optimization

**1. Review resource usage:**
```bash
# Check pod resource requests vs actual usage
kubectl top pods -n ecommerce

# Identify underutilized resources
# Adjust resource requests/limits accordingly
```

**2. Enable GKE Autopilot (optional):**
```bash
# Create new autopilot cluster
gcloud container clusters create-auto ecommerce-autopilot \
  --region=us-central1

# Migrate workloads
```

**3. Use committed use discounts:**
```bash
# Purchase committed use discount for VMs
gcloud compute commitments create commitment-1year \
  --plan=12-month \
  --resources=vcpu=12,memory=48GB \
  --region=us-central1
```

**4. Set up budget alerts:**
```bash
gcloud billing budgets create \
  --billing-account=<BILLING_ACCOUNT_ID> \
  --display-name="E-Commerce Budget" \
  --budget-amount=1000USD \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100
```

### 15.7 Security Maintenance

**1. Rotate secrets:**
```bash
# Generate new JWT secret
NEW_JWT_SECRET=$(openssl rand -base64 32)

# Update secret
kubectl create secret generic jwt-secret \
  --from-literal=secret=$NEW_JWT_SECRET \
  --namespace=ecommerce \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart services
kubectl rollout restart deployment -n ecommerce
```

**2. Update SSL certificates:**
```bash
# Generate new certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=$INGRESS_IP/O=E-Commerce"

# Update secret
kubectl create secret tls tls-secret \
  --cert=tls.crt \
  --key=tls.key \
  --namespace=ecommerce \
  --dry-run=client -o yaml | kubectl apply -f -
```

**3. Scan images for vulnerabilities:**
```bash
# Enable vulnerability scanning
gcloud artifacts repositories update ecommerce-repo \
  --location=us-central1 \
  --enable-remote-source-api

# View vulnerabilities
gcloud artifacts docker images list us-central1-docker.pkg.dev/$GCP_PROJECT_ID/ecommerce-repo \
  --show-occurrences
```

**4. Update IAM policies:**
```bash
# Review current IAM policies
gcloud projects get-iam-policy $GCP_PROJECT_ID

# Remove unnecessary permissions
gcloud projects remove-iam-policy-binding $GCP_PROJECT_ID \
  --member="serviceAccount:old-service-account@$GCP_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"
```

### 15.8 Disaster Recovery

**1. Document recovery procedures:**
- RTO (Recovery Time Objective): < 1 hour
- RPO (Recovery Point Objective): < 15 minutes

**2. Test disaster recovery:**
```bash
# Simulate node failure
gcloud compute instances delete <NODE_NAME> --zone=us-central1-a

# Verify pods reschedule automatically
kubectl get pods -n ecommerce -w

# Simulate database failure
# Test restore from backup (see section 15.2)
```

**3. Multi-region setup (for high availability):**
```bash
# Create cluster in secondary region
gcloud container clusters create ecommerce-cluster-backup \
  --zone=us-east1-b \
  --num-nodes=3 \
  --machine-type=e2-standard-4

# Set up Cloud SQL replication
gcloud sql instances create ecommerce-postgres-replica \
  --master-instance-name=ecommerce-postgres \
  --tier=db-custom-2-7680 \
  --replica-type=READ \
  --region=us-east1
```

### 15.9 Decommissioning

**If you need to tear down the environment:**

```bash
# Delete Kubernetes resources
kubectl delete namespace ecommerce
kubectl delete namespace kong
kubectl delete namespace monitoring
kubectl delete namespace jenkins

# Delete GKE cluster
gcloud container clusters delete ecommerce-cluster --zone=us-central1-a

# Delete Cloud SQL
gcloud sql instances delete ecommerce-postgres

# Delete Redis
gcloud redis instances delete ecommerce-redis --region=us-central1

# Delete Cloud Storage buckets
gsutil -m rm -r gs://ecommerce-frontend-$GCP_PROJECT_ID
gsutil -m rm -r gs://ecommerce-images-$GCP_PROJECT_ID

# Run Terraform destroy
cd infrastructure/terraform
terraform destroy
```

---

## Appendix

### A. Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| GCP_PROJECT_ID | GCP Project ID | my-ecommerce-project |
| GCP_REGION | GCP Region | us-central1 |
| GCP_ZONE | GCP Zone | us-central1-a |
| GOOGLE_APPLICATION_CREDENTIALS | Service account key path | ~/terraform-key.json |
| CLOUDSQL_CONNECTION | Cloud SQL connection string | project:region:instance |
| DB_NAME | Database name | ecommerce_users |
| DB_USER | Database username | postgres |
| DB_PASSWORD | Database password | SecurePassword123! |
| REDIS_HOST | Redis host | 10.x.x.x |
| JWT_SECRET | JWT signing secret | random-secure-string |
| KONG_PROXY_IP | Kong proxy IP | 136.119.114.180 |
| KONG_ADMIN_IP | Kong admin IP | 34.44.244.168 |
| INGRESS_IP | Ingress load balancer IP | 34.8.28.111 |

### B. Port Reference

| Service | Internal Port | External Port | Purpose |
|---------|--------------|---------------|---------|
| User Service | 8081 | - | REST API |
| Product Service | 8082 | - | REST API |
| Order Service | 8083 | - | REST API |
| Frontend | 80 | 80/443 | Web UI |
| PostgreSQL | 5432 | - | Database |
| Redis | 6379 | - | Cache |
| Kong Proxy | 8000 | 80 | API Gateway |
| Kong Admin | 8001 | 8001 | Admin API |
| Prometheus | 9090 | 9090 | Monitoring |
| Grafana | 3000 | 80 | Dashboards |
| Jenkins | 8080 | 8080 | CI/CD |

### C. Resource Sizing Guide

**Development Environment:**
- GKE: 2 nodes, e2-medium (2 vCPU, 4GB RAM)
- Cloud SQL: db-f1-micro
- Redis: 1GB Basic
- Replicas: 1 per service

**Production Environment:**
- GKE: 3+ nodes, e2-standard-4 (4 vCPU, 16GB RAM)
- Cloud SQL: db-custom-2-7680 (2 vCPU, 7.5GB RAM) with HA
- Redis: 5GB Standard HA
- Replicas: 3+ per service with HPA

**High-Traffic Production:**
- GKE: 5+ nodes, e2-standard-8 (8 vCPU, 32GB RAM)
- Cloud SQL: db-custom-4-15360 (4 vCPU, 15GB RAM) with replicas
- Redis: 10GB+ Standard HA with replicas
- Replicas: 5-10 per service with aggressive HPA

### D. Useful Links

- **Project Repository:** https://github.com/rupesh9999/gcp-three-tier-ecommerce-project
- **GCP Console:** https://console.cloud.google.com
- **Kubernetes Dashboard:** Deploy with `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml`
- **Kong Documentation:** https://docs.konghq.com
- **Spring Boot Docs:** https://docs.spring.io/spring-boot/docs/current/reference/html/
- **React Documentation:** https://react.dev
- **Terraform GCP Provider:** https://registry.terraform.io/providers/hashicorp/google/latest/docs

### E. Support and Troubleshooting

For issues not covered in this runbook:

1. Check application logs: `kubectl logs -f <POD_NAME> -n ecommerce`
2. Review GCP Operations logs: https://console.cloud.google.com/logs
3. Verify resource quotas: `gcloud compute project-info describe --project=$GCP_PROJECT_ID`
4. Check service health: `kubectl get pods -n ecommerce`
5. Test connectivity: `kubectl run -it --rm test-pod --image=curlimages/curl --restart=Never`

---

**Congratulations!** 🎉

You have successfully deployed a production-ready three-tier e-commerce platform on Google Cloud Platform.

**Key Achievements:**
- ✅ Infrastructure as Code with Terraform
- ✅ Kubernetes orchestration on GKE
- ✅ Microservices architecture with Spring Boot
- ✅ Modern React frontend
- ✅ Cloud-native data layer (Cloud SQL, Redis, Pub/Sub)
- ✅ API Gateway with Kong
- ✅ Comprehensive monitoring with Prometheus & Grafana
- ✅ CI/CD pipeline with Cloud Build
- ✅ Production-grade security and scalability

**Next Steps:**
1. Set up custom domain with Cloud DNS
2. Configure Cloud CDN for frontend
3. Implement Cloud Armor for DDoS protection
4. Add Cloud Trace for distributed tracing
5. Set up Cloud Profiler for performance analysis
6. Implement disaster recovery procedures
7. Add integration tests to CI/CD
8. Set up staging environment

**Thank you for using this runbook!**

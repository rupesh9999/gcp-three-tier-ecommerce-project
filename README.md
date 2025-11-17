# GCP Three-Tier E-Commerce Platform

A comprehensive three-tier e-commerce web application built on Google Cloud Platform with modern microservices architecture, fully automated CI/CD, and production-ready infrastructure.

## ✨ Project Status

- ✅ **Deployed on GKE** - Running on Google Kubernetes Engine
- ✅ **HTTPS Enabled** - SSL/TLS configured with self-signed certificate
- ✅ **CI/CD Ready** - Cloud Build + Jenkins pipelines configured
- ✅ **Production Ready** - Monitoring, logging, and auto-scaling enabled

**Live URLs:**
- **Application:** https://34.8.28.111
- **Jenkins CI/CD:** http://34.46.37.36/jenkins (admin/admin@123)

---

## 🚀 Quick Start

### Option 1: Complete CI/CD Setup (Recommended - 10 minutes)

Run the automated setup script:

```bash
cd /home/ubuntu/gcp-three-tier-ecommerce-project
./setup-cicd.sh
```

This will:
- ✅ Enable Cloud Build API
- ✅ Configure service account permissions
- ✅ Create 4 build triggers (user, product, order, frontend)
- ✅ Test your first build
- ✅ Set up automatic deployments on push

### Option 2: Manual Setup

See detailed instructions in [CI_CD_SETUP_SUMMARY.md](CI_CD_SETUP_SUMMARY.md)

### Local Development

```bash
# Clone the repository
git clone https://github.com/rupesh9999/gcp-three-tier-ecommerce-project.git
cd gcp-three-tier-ecommerce-project

# Start all services
docker-compose up -d

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8081/api/v1
```

### Production Deployment

Full runbook: [docs/runbook/RUNBOOK.md](docs/runbook/RUNBOOK.md)

## 🏗️ Architecture

### Infrastructure Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Google Cloud Platform                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────┐      ┌──────────────────────────────┐  │
│  │   Cloud Build  │──────▶│  Artifact Registry           │  │
│  │   CI/CD        │      │  Docker Images               │  │
│  └────────────────┘      └──────────────────────────────┘  │
│          │                                                   │
│          ▼                                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Google Kubernetes Engine (GKE)              │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │  Namespace: ecommerce                           │ │  │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐      │ │  │
│  │  │  │ Frontend │  │  User    │  │ Product  │      │ │  │
│  │  │  │ (React)  │  │ Service  │  │ Service  │      │ │  │
│  │  │  └──────────┘  └──────────┘  └──────────┘      │ │  │
│  │  │       │              │              │            │ │  │
│  │  │       └──────────────┼──────────────┘            │ │  │
│  │  │                      │                            │ │  │
│  │  │  ┌──────────────────▼────────────────────────┐  │ │  │
│  │  │  │  PostgreSQL  │  Redis  │  Elasticsearch  │  │ │  │
│  │  │  └─────────────────────────────────────────┘  │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  │                                                        │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │  Namespace: jenkins                             │ │  │
│  │  │  ┌────────────────────────────────────────────┐ │ │  │
│  │  │  │  Jenkins (CI/CD Orchestration)             │ │ │  │
│  │  │  └────────────────────────────────────────────┘ │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌────────────────┐      ┌──────────────────────────────┐  │
│  │  LoadBalancer  │──────▶│  Ingress Controller          │  │
│  │  (HTTPS/TLS)   │      │  34.8.28.111                 │  │
│  └────────────────┘      └──────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

**Presentation Tier:**
- React 18 + TypeScript
- Redux Toolkit for state management
- Material-UI components
- Responsive design

**Application Tier:**
- Spring Boot 3.2.0 microservices
- Java 17, Spring Security
- JWT authentication
- RESTful APIs
- Service mesh ready

**Data Tier:**
- PostgreSQL (primary database)
- Redis (caching layer)
- Elasticsearch (search engine)
- Cloud SQL (managed database)

**Infrastructure:**
- Google Kubernetes Engine (GKE)
- Cloud Build (CI/CD)
- Jenkins (orchestration)
- Artifact Registry (Docker images)
- Cloud Load Balancer
- Terraform (IaC)

## 📋 Features

### E-Commerce Features
- ✅ Complete product catalog with categories
- ✅ Advanced search and filtering
- ✅ Shopping cart functionality
- ✅ Secure checkout process
- ✅ Order tracking and history
- ✅ User account management
- ✅ Payment integration ready
- ✅ Inventory management

### DevOps Features
- ✅ **Automated CI/CD** - Cloud Build triggers on push
- ✅ **Infrastructure as Code** - Terraform for GCP resources
- ✅ **Container Orchestration** - Kubernetes on GKE
- ✅ **HTTPS/TLS** - Secure communication
- ✅ **Service Mesh Ready** - Istio compatible
- ✅ **Monitoring & Logging** - Cloud Operations Suite
- ✅ **Auto-scaling** - HPA and cluster autoscaling
- ✅ **High Availability** - Multi-zone deployment

### Security Features
- ✅ JWT-based authentication
- ✅ Role-based access control (RBAC)
- ✅ Kubernetes RBAC for pods
- ✅ Network policies configured
- ✅ Secret management with Kubernetes Secrets
- ✅ Service account isolation
- ✅ TLS encryption for ingress

## 🛠️ Tech Stack

### Frontend
- **Framework:** React 18 with TypeScript
- **State Management:** Redux Toolkit
- **Routing:** React Router v6
- **HTTP Client:** Axios
- **UI Components:** Material-UI
- **Build Tool:** Webpack
- **Container:** Docker multi-stage build
- **Testing:** Jest + React Testing Library

### Backend Services
- **Framework:** Spring Boot 3.2.0
- **Language:** Java 17 (LTS)
- **Security:** Spring Security + JWT
- **Database ORM:** Spring Data JPA
- **API Documentation:** SpringDoc OpenAPI
- **Caching:** Spring Cache + Redis
- **Container:** Docker with optimized layers
- **Testing:** JUnit 5 + Mockito

### Data Layer
- **Primary Database:** PostgreSQL 15 (Cloud SQL)
- **Cache:** Redis 7
- **Search Engine:** Elasticsearch 8
- **Message Queue:** Google Pub/Sub
- **Object Storage:** Cloud Storage

### DevOps & Infrastructure
- **Container Orchestration:** Kubernetes 1.33 (GKE)
- **CI/CD:** Google Cloud Build + Jenkins 2.x
- **IaC:** Terraform 1.5+
- **Container Registry:** Artifact Registry
- **Load Balancer:** GCP Cloud Load Balancer
- **Monitoring:** Cloud Monitoring + Grafana
- **Logging:** Cloud Logging + Elasticsearch
- **Secrets:** Google Secret Manager + K8s Secrets

### Development Tools
- **Version Control:** Git + GitHub
- **IDE:** VS Code, IntelliJ IDEA
- **API Testing:** Postman
- **Container:** Docker 24+, Docker Compose
- **CLI:** gcloud, kubectl, helm

## 🧹 Resource Cleanup

If you need to clean up all GCP resources created during deployment:

```bash
# Run the comprehensive cleanup script
./cleanup-all.sh

# Or manually clean up resources in this order:
# 1. Delete GKE cluster
gcloud container clusters delete ecommerce-gke-cluster --zone=us-central1-a --project=YOUR_PROJECT_ID --quiet

# 2. Delete Cloud SQL instance (disable deletion protection first)
gcloud sql instances patch ecommerce-postgres --project=YOUR_PROJECT_ID --no-deletion-protection --quiet
gcloud sql instances delete ecommerce-postgres --project=YOUR_PROJECT_ID --quiet

# 3. Delete storage buckets
gcloud storage rm --recursive gs://ecommerce-terraform-state-t8/
gcloud storage rm --recursive gs://frontend-static-bucket/
gcloud storage rm --recursive gs://product-images-bucket/

# 4. Delete Pub/Sub topics and subscriptions
gcloud pubsub topics delete order-created order-updated payment-processed notification-requested inventory-updated --project=YOUR_PROJECT_ID --quiet

# 5. Delete VPC network and subnet
gcloud compute networks subnets delete ecommerce-vpc-gke-subnet --region=us-central1 --project=YOUR_PROJECT_ID --quiet
gcloud compute addresses delete private-ip-address --global --project=YOUR_PROJECT_ID --quiet
gcloud compute networks delete ecommerce-vpc --project=YOUR_PROJECT_ID --quiet
```

## 📚 Documentation

### Getting Started
- [CI/CD Setup Summary](CI_CD_SETUP_SUMMARY.md) - **START HERE** for CI/CD
- [Quick Start Guide](QUICKSTART.md) - Local development setup
- [Project Summary](PROJECT_SUMMARY.md) - Complete project overview

### Architecture & Design
- [Architecture Overview](docs/architecture/ARCHITECTURE.md)
- [Deployment Runbook](docs/runbook/RUNBOOK.md)
- [API Documentation](docs/api/README.md)

### CI/CD Documentation
- [Jenkins Setup Guide](infrastructure/jenkins/JENKINS_SETUP_GUIDE.md)
- [CI/CD Completion Guide](infrastructure/jenkins/CICD_COMPLETION_GUIDE.md)
- [Cloud Build Configurations](backend/*/cloudbuild.yaml)

### Infrastructure
- [Kubernetes Manifests](infrastructure/kubernetes/)
- [Terraform Modules](terraform/)
- [Docker Configurations](docker-compose.yml)

---

## 🚦 CI/CD Pipeline

### Automated Build Process

1. **Code Push** → GitHub main branch
2. **Trigger** → Cloud Build detects changes
3. **Build** → Maven/npm builds + tests
4. **Test** → Unit tests + integration tests
5. **Docker** → Build and tag images
6. **Push** → Upload to Artifact Registry
7. **Deploy** → Rolling update on GKE
8. **Verify** → Health checks + rollout status

### Build Triggers

- **user-service-trigger** - Watches `backend/user-service/**`
- **product-service-trigger** - Watches `backend/product-service/**`
- **order-service-trigger** - Watches `backend/order-service/**`
- **frontend-trigger** - Watches `frontend/**`

### Manual Build

```bash
# Build specific service
gcloud builds submit --config backend/user-service/cloudbuild.yaml .

# View build logs
gcloud builds log $(gcloud builds list --limit=1 --format='value(id)')

# List recent builds
gcloud builds list --limit=10
```

---

## 🔧 Development Workflow

### Local Development

```bash
# 1. Clone and setup
git clone https://github.com/rupesh9999/gcp-three-tier-ecommerce-project.git
cd gcp-three-tier-ecommerce-project

# 2. Start backend services
docker-compose up -d postgres redis elasticsearch

# 3. Run backend services
cd backend/user-service
mvn spring-boot:run

# 4. Run frontend
cd frontend
npm install
npm start

# 5. Access
# Frontend: http://localhost:3000
# User Service API: http://localhost:8081
# Product Service API: http://localhost:8082
# Order Service API: http://localhost:8083
```

### Production Deployment

```bash
# 1. Authenticate with GCP
gcloud auth login
gcloud config set project vaulted-harbor-476903-t8

# 2. Get cluster credentials
gcloud container clusters get-credentials ecommerce-cluster \
  --zone us-central1-a

# 3. Deploy services
kubectl apply -f infrastructure/kubernetes/deployments/
kubectl apply -f infrastructure/kubernetes/services/
kubectl apply -f infrastructure/kubernetes/ingress/

# 4. Check deployment status
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
kubectl get ingress -n ecommerce

# 5. View logs
kubectl logs -f deployment/user-service -n ecommerce
```

### Running Tests

```bash
# Backend tests
cd backend/user-service
mvn test
mvn verify  # Integration tests

# Frontend tests
cd frontend
npm test
npm run test:coverage

# E2E tests
npm run test:e2e
```

---

## 🌐 API Endpoints

### User Service (Port 8081)
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `GET /api/v1/users/{id}` - Get user profile
- `PUT /api/v1/users/{id}` - Update user profile

### Product Service (Port 8082)
- `GET /api/v1/products` - List all products
- `GET /api/v1/products/{id}` - Get product details
- `POST /api/v1/products` - Create product (Admin)
- `PUT /api/v1/products/{id}` - Update product (Admin)
- `DELETE /api/v1/products/{id}` - Delete product (Admin)

### Order Service (Port 8083)
- `POST /api/v1/orders` - Create new order
- `GET /api/v1/orders` - List user orders
- `GET /api/v1/orders/{id}` - Get order details
- `PUT /api/v1/orders/{id}/status` - Update order status

### Frontend (Port 80)
- `/` - Home page
- `/products` - Product catalog
- `/product/:id` - Product details
- `/cart` - Shopping cart
- `/checkout` - Checkout process
- `/orders` - Order history
- `/login` - User login
- `/register` - User registration

---

## 📊 Monitoring & Operations

### Access Monitoring Dashboards

```bash
# Cloud Console
open https://console.cloud.google.com/monitoring/dashboards?project=vaulted-harbor-476903-t8

# View logs
gcloud logging read "resource.type=k8s_container" --limit=50 --format=json

# Check service health
kubectl get --raw /healthz
kubectl top nodes
kubectl top pods -n ecommerce
```

### Common Operations

```bash
# Scale deployment
kubectl scale deployment user-service --replicas=5 -n ecommerce

# Rolling restart
kubectl rollout restart deployment/user-service -n ecommerce

# View rollout status
kubectl rollout status deployment/user-service -n ecommerce

# Rollback deployment
kubectl rollout undo deployment/user-service -n ecommerce

# Update image
kubectl set image deployment/user-service \
  user-service=us-central1-docker.pkg.dev/vaulted-harbor-476903-t8/ecommerce-repo/user-service:v2 \
  -n ecommerce
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

**Status**: Production Ready | **Version**: 1.0.0

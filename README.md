# Three-Tier E-Commerce Application on Google Cloud Platform

## Project Overview

A production-ready, scalable e-commerce platform built on Google Cloud Platform (GCP) following a multi-tier architecture with microservices design patterns, DevOps best practices, and comprehensive observability.

## Architecture Components

### 🎨 Presentation Tier
- **Frontend Framework**: React 18 with TypeScript
- **CDN**: Google Cloud CDN
- **Static Assets**: Google Cloud Storage
- **Features**: Product catalog, shopping cart, checkout, user authentication

### 🔌 Integration & Messaging Tier
- **API Gateway**: Google Cloud API Gateway (REST/GraphQL routing, auth, rate limiting)
- **Message Queue**: Google Pub/Sub (async processing, event-driven architecture)
- **API Testing**: Postman collections included

### 🚀 Application/Business Logic Tier
- **Framework**: Java Spring Boot 3.x
- **Microservices**:
  - User Service (authentication, profile management)
  - Product Service (catalog, search, inventory)
  - Order Service (cart, checkout, order processing)
  - Notification Service (email, SMS alerts)
- **Authentication**: JWT-based security
- **API**: RESTful endpoints with OpenAPI/Swagger documentation

### 💾 Data Tier
- **RDBMS**: PostgreSQL (primary transactional data)
- **ORM**: Spring Data JPA
- **Search Engine**: Elasticsearch (product search, analytics)
- **Caching**: Redis (session management, API caching)

### 🛠️ Infrastructure & DevOps Layer
- **Containerization**: Docker
- **Orchestration**: Google Kubernetes Engine (GKE)
- **IaC**: Terraform (complete GCP resource provisioning)
- **CI/CD**: Jenkins + ArgoCD (GitOps)
- **Code Quality**: SonarQube
- **Monitoring**: Prometheus + Grafana
- **Version Control**: Git
- **Artifact Registry**: Google Artifact Registry

## Project Structure

```
gcp-three-tier-ecommerce-project/
├── frontend/                      # React application
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   └── package.json
├── backend/                       # Spring Boot microservices
│   ├── user-service/
│   ├── product-service/
│   ├── order-service/
│   └── notification-service/
├── infrastructure/                # Infrastructure as Code
│   ├── terraform/
│   │   ├── vpc/
│   │   ├── gke/
│   │   ├── storage/
│   │   ├── pubsub/
│   │   └── api-gateway/
│   └── kubernetes/
│       ├── deployments/
│       ├── services/
│       └── ingress/
├── ci-cd/                        # CI/CD configurations
│   ├── jenkins/
│   ├── argocd/
│   └── sonarqube/
├── monitoring/                   # Observability stack
│   ├── prometheus/
│   └── grafana/
├── database/                     # Database schemas & migrations
│   ├── postgresql/
│   └── elasticsearch/
├── docs/                         # Documentation
│   ├── architecture/
│   ├── api/
│   └── runbook/
├── scripts/                      # Utility scripts
└── postman/                      # API test collections
```

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | React, TypeScript | User interface |
| CDN | Google Cloud CDN | Content delivery |
| API Gateway | GCP API Gateway | API management |
| Message Queue | Google Pub/Sub | Async communication |
| Backend | Spring Boot 3, Java 17 | Business logic |
| ORM | Spring Data JPA | Data access |
| Database | PostgreSQL | Relational data |
| Search | Elasticsearch | Full-text search |
| Cache | Redis | Performance optimization |
| Container | Docker | Application packaging |
| Orchestration | GKE (Kubernetes) | Container management |
| IaC | Terraform | Infrastructure provisioning |
| CI/CD | Jenkins, ArgoCD | Automated deployment |
| Code Quality | SonarQube | Static analysis |
| Monitoring | Prometheus, Grafana | Observability |
| Storage | GCS | Object storage |
| Networking | VPC, Firewall Rules | Security |

## Prerequisites

### Local Development Environment
- **OS**: Linux/macOS/Windows with WSL2
- **Java**: JDK 17 or higher
- **Node.js**: v18 or higher
- **Docker**: v20.10 or higher
- **kubectl**: v1.27 or higher
- **Terraform**: v1.5 or higher
- **Git**: v2.30 or higher
- **Maven**: 3.8 or higher

### Google Cloud Platform
- GCP Account with billing enabled
- Project created with appropriate APIs enabled:
  - Compute Engine API
  - Kubernetes Engine API
  - Cloud Storage API
  - Cloud CDN API
  - Pub/Sub API
  - API Gateway API
  - Artifact Registry API
  - Cloud Build API
- Service account with required permissions
- gcloud CLI installed and authenticated

### Third-Party Services (Optional)
- GitHub/GitLab account for version control
- Domain name for production deployment
- SSL certificates for HTTPS

## Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd gcp-three-tier-ecommerce-project
```

### 2. Set Up GCP Credentials
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```

### 3. Initialize Terraform
```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

### 4. Build and Deploy Backend Services
```bash
cd backend/user-service
mvn clean package
docker build -t gcr.io/YOUR_PROJECT_ID/user-service:latest .
docker push gcr.io/YOUR_PROJECT_ID/user-service:latest
```

### 5. Deploy to Kubernetes
```bash
kubectl apply -f infrastructure/kubernetes/
```

### 6. Build and Deploy Frontend
```bash
cd frontend
npm install
npm run build
gsutil -m rsync -r build/ gs://YOUR_BUCKET_NAME/
```

## Detailed Documentation

- **[Architecture Overview](docs/architecture/ARCHITECTURE.md)** - System design and component interactions
- **[Deployment Runbook](docs/runbook/RUNBOOK.md)** - Complete deployment guide
- **[API Documentation](docs/api/API.md)** - REST API endpoints and contracts
- **[Monitoring Guide](docs/monitoring/MONITORING.md)** - Observability and alerting setup

## Key Features

### Security
- ✅ JWT-based authentication and authorization
- ✅ HTTPS/TLS encryption via Cloud Load Balancer
- ✅ VPC isolation and security groups
- ✅ IAM role-based access control
- ✅ Secrets management via Kubernetes secrets
- ✅ API rate limiting and throttling

### Scalability
- ✅ Horizontal pod autoscaling in GKE
- ✅ Cloud CDN for global edge caching
- ✅ Database connection pooling
- ✅ Redis caching layer
- ✅ Elasticsearch for distributed search
- ✅ Pub/Sub for async processing

### Reliability
- ✅ Multi-zone GKE cluster
- ✅ Database backups and replication
- ✅ Health checks and liveness probes
- ✅ Circuit breaker patterns
- ✅ Dead-letter queues for failed messages
- ✅ Rolling updates with zero downtime

### Observability
- ✅ Prometheus metrics collection
- ✅ Grafana dashboards
- ✅ Centralized logging
- ✅ Distributed tracing (optional: Jaeger)
- ✅ Alerting rules and notifications

## Development Workflow

1. **Feature Development**: Create feature branch from `develop`
2. **Local Testing**: Run services locally with Docker Compose
3. **Code Quality**: SonarQube analysis on commit
4. **CI Pipeline**: Jenkins builds and tests on PR
5. **Container Build**: Docker images pushed to Artifact Registry
6. **GitOps Deployment**: ArgoCD syncs to GKE cluster
7. **Monitoring**: Track metrics in Grafana dashboards

## Cost Optimization Tips

- Use preemptible VMs for non-critical workloads
- Enable GKE cluster autoscaling
- Implement Cloud CDN caching strategies
- Set up budget alerts in GCP
- Use committed use discounts for predictable workloads
- Implement resource quotas and limits

## Troubleshooting

See [docs/runbook/TROUBLESHOOTING.md](docs/runbook/TROUBLESHOOTING.md) for common issues and solutions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Support

For questions or issues, please:
1. Check the [documentation](docs/)
2. Review [troubleshooting guide](docs/runbook/TROUBLESHOOTING.md)
3. Open an issue on GitHub

## Authors

- DevOps Team
- Backend Team
- Frontend Team

## Acknowledgments

- Google Cloud Platform documentation
- Spring Boot community
- React community
- Kubernetes community

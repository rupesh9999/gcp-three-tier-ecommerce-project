# GCP Three-Tier E-Commerce Platform

A comprehensive three-tier e-commerce web application built on Google Cloud Platform with modern microservices architecture.

## 🚀 Quick Start

### Local Development
```bash
# Clone the repository
git clone <your-repo-url>
cd gcp-three-tier-ecommerce-project

# Start all services
docker-compose up -d

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8081/api/v1
```

### Production Deployment
See [docs/runbook/RUNBOOK.md](docs/runbook/RUNBOOK.md) for complete deployment instructions.

## 🏗️ Architecture

- **Presentation Tier**: React 18 + TypeScript SPA
- **Application Tier**: Spring Boot microservices with JWT authentication
- **Data Tier**: PostgreSQL + Redis + Elasticsearch
- **Infrastructure**: Google Kubernetes Engine (GKE)
- **CI/CD**: Jenkins + ArgoCD GitOps

## 📋 Features

- ✅ Complete e-commerce functionality (products, cart, checkout, orders)
- ✅ User authentication and authorization
- ✅ Product catalog with search capabilities
- ✅ Shopping cart and checkout flow
- ✅ Order management and history
- ✅ Responsive React frontend
- ✅ RESTful API backend
- ✅ Production-ready Docker containers
- ✅ Infrastructure as Code with Terraform
- ✅ Automated CI/CD pipelines
- ✅ Monitoring and observability setup

## 🛠️ Tech Stack

### Frontend
- React 18, TypeScript, Redux Toolkit
- React Router, Axios, Docker

### Backend
- Spring Boot 3.2.0, Java 17
- Spring Security, JWT, JPA
- PostgreSQL, Redis, Docker

### Infrastructure
- Google Cloud Platform
- Kubernetes (GKE), Terraform
- Jenkins, ArgoCD, Docker

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

- [Quick Start Guide](QUICKSTART.md)
- [Architecture Overview](docs/architecture/ARCHITECTURE.md)
- [Deployment Runbook](docs/runbook/RUNBOOK.md)
- [Project Summary](PROJECT_SUMMARY.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

**Status**: Production Ready | **Version**: 1.0.0

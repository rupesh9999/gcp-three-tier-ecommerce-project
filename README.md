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

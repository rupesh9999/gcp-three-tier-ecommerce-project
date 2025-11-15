# Comprehensive Deployment Runbook
# Three-Tier E-Commerce Application on Google Cloud Platform

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Google Cloud Platform Setup](#google-cloud-platform-setup)
4. [Infrastructure Provisioning with Terraform](#infrastructure-provisioning-with-terraform)
5. [Database Setup and Migration](#database-setup-and-migration)
6. [Application Deployment](#application-deployment)
7. [CI/CD Pipeline Setup](#cicd-pipeline-setup)
8. [Monitoring and Observability](#monitoring-and-observability)
9. [Security Configuration](#security-configuration)
10. [Troubleshooting](#troubleshooting)
11. [Maintenance and Operations](#maintenance-and-operations)

---

## 1. Prerequisites

### Required Tools and Versions
- **Java Development Kit (JDK)**: 17 or higher
- **Node.js**: v18 or higher
- **npm**: 9.x or higher
- **Maven**: 3.8 or higher
- **Docker**: 20.10 or higher
- **Docker Compose**: 2.x (for local development)
- **kubectl**: v1.27 or higher
- **Terraform**: v1.5 or higher
- **gcloud CLI**: Latest version
- **Git**: v2.30 or higher

### Google Cloud Platform Requirements
- Active GCP account with billing enabled
- Project created with appropriate permissions
- Service account with following roles:
  - Compute Admin
  - Kubernetes Engine Admin
  - Storage Admin
  - Pub/Sub Admin
  - Cloud SQL Admin
  - IAM Admin
  - Network Admin

### Third-Party Accounts (Optional)
- GitHub/GitLab for version control
- SendGrid API key for email notifications
- Twilio account for SMS notifications
- Domain name and SSL certificates for production

---

## 2. Local Development Setup

### Step 1: Clone the Repository
```bash
git clone <repository-url>
cd gcp-three-tier-ecommerce-project
```

### Step 2: Setup Backend Services Locally

#### 2.1 Start PostgreSQL Database
```bash
docker run -d \
  --name postgres-local \
  -e POSTGRES_DB=ecommerce_users \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:15-alpine
```

#### 2.2 Start Redis Cache
```bash
docker run -d \
  --name redis-local \
  -p 6379:6379 \
  redis:7-alpine
```

#### 2.3 Start Elasticsearch
```bash
docker run -d \
  --name elasticsearch-local \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  -p 9200:9200 \
  -p 9300:9300 \
  elasticsearch:8.11.0
```

#### 2.4 Build and Run User Service
```bash
cd backend/user-service

# Build the application
mvn clean install

# Run the service
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=ecommerce_users
export DB_USER=postgres
export DB_PASSWORD=postgres
export REDIS_HOST=localhost
export JWT_SECRET=your-development-secret-key

mvn spring-boot:run
```

The service will be available at: http://localhost:8081/api/v1

### Step 3: Setup Frontend Locally

```bash
cd frontend

# Install dependencies
npm install

# Create environment file
cp .env.example .env.local

# Update .env.local with local backend URL
echo "REACT_APP_API_URL=http://localhost:8081/api/v1" > .env.local

# Start development server
npm start
```

The frontend will be available at: http://localhost:3000

### Step 4: Verify Local Setup

Test the health endpoints:
```bash
# Backend health check
curl http://localhost:8081/api/v1/actuator/health

# Expected response:
# {"status":"UP"}
```

Test user registration:
```bash
curl -X POST http://localhost:8081/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "password": "SecurePass123"
  }'
```

---

## 3. Google Cloud Platform Setup

### Step 1: Install and Configure gcloud CLI

```bash
# Install gcloud CLI (if not already installed)
# For Ubuntu/Debian:
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# For macOS with Homebrew:
brew install google-cloud-sdk

# Initialize gcloud
gcloud init

# Authenticate
gcloud auth login
gcloud auth application-default login
```

### Step 2: Create GCP Project

```bash
# Set variables
export PROJECT_ID="ecommerce-platform-$(date +%s)"
export PROJECT_NAME="E-Commerce Platform"
export BILLING_ACCOUNT_ID="YOUR_BILLING_ACCOUNT_ID"
export REGION="us-central1"
export ZONE="us-central1-a"

# Create project
gcloud projects create $PROJECT_ID --name="$PROJECT_NAME"

# Link billing account
gcloud billing projects link $PROJECT_ID --billing-account=$BILLING_ACCOUNT_ID

# Set default project
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
```

### Step 3: Enable Required APIs

```bash
# Enable all required Google Cloud APIs
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  cloudbuild.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  serviceusage.googleapis.com \
  storage-api.googleapis.com \
  storage-component.googleapis.com \
  sqladmin.googleapis.com \
  pubsub.googleapis.com \
  redis.googleapis.com \
  secretmanager.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  cloudtrace.googleapis.com \
  artifactregistry.googleapis.com \
  apigateway.googleapis.com \
  servicecontrol.googleapis.com \
  servicemanagement.googleapis.com
```

### Step 4: Create Service Account

```bash
# Create service account for Terraform and deployments
export SA_NAME="ecommerce-deployer"
export SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud iam service-accounts create $SA_NAME \
  --display-name="E-Commerce Deployment Service Account"

# Grant necessary roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/iam.serviceAccountAdmin"

# Create and download key
gcloud iam service-accounts keys create ~/gcp-key.json \
  --iam-account=$SA_EMAIL

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=~/gcp-key.json
```

---

## 4. Infrastructure Provisioning with Terraform

### Step 1: Navigate to Terraform Directory

```bash
cd infrastructure/terraform
```

### Step 2: Initialize Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate
```

### Step 3: Create terraform.tfvars

Create a file named `terraform.tfvars`:

```hcl
project_id = "YOUR_PROJECT_ID"
region     = "us-central1"
zone       = "us-central1-a"

# VPC Configuration
vpc_name = "ecommerce-vpc"

# GKE Configuration
gke_cluster_name = "ecommerce-gke-cluster"
gke_node_count   = 3
gke_machine_type = "e2-standard-4"

# Database Configuration
db_instance_name = "ecommerce-postgres"
db_tier          = "db-custom-2-7680"
db_version       = "POSTGRES_15"

# Redis Configuration
redis_instance_name   = "ecommerce-redis"
redis_memory_size_gb  = 2

# Storage Configuration
frontend_bucket_name  = "ecommerce-frontend-static"
images_bucket_name    = "ecommerce-product-images"

# Pub/Sub Configuration
pubsub_topics = [
  "order-created",
  "order-updated",
  "payment-processed",
  "notification-requested",
  "inventory-updated"
]
```

### Step 4: Plan Infrastructure Changes

```bash
# Review what will be created
terraform plan -out=tfplan

# Review the plan carefully
```

### Step 5: Apply Terraform Configuration

```bash
# Apply the configuration
terraform apply tfplan

# This will take 15-20 minutes to complete

# Save important outputs
terraform output -json > terraform-outputs.json
```

### Step 6: Verify Infrastructure

```bash
# Verify GKE cluster
gcloud container clusters list

# Get GKE credentials
gcloud container clusters get-credentials ecommerce-gke-cluster \
  --region=$REGION

# Verify kubectl access
kubectl get nodes

# Verify Cloud SQL instance
gcloud sql instances list

# Verify Cloud Storage buckets
gsutil ls

# Verify Pub/Sub topics
gcloud pubsub topics list
```

---

## 5. Database Setup and Migration

### Step 1: Connect to Cloud SQL

```bash
# Install Cloud SQL Proxy
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
chmod +x cloud_sql_proxy

# Get connection name
export CONNECTION_NAME=$(gcloud sql instances describe ecommerce-postgres \
  --format='value(connectionName)')

# Start proxy
./cloud_sql_proxy -instances=$CONNECTION_NAME=tcp:5432 &
```

### Step 2: Create Databases

```bash
# Create databases for each service
gcloud sql databases create ecommerce_users \
  --instance=ecommerce-postgres

gcloud sql databases create ecommerce_products \
  --instance=ecommerce-postgres

gcloud sql databases create ecommerce_orders \
  --instance=ecommerce-postgres
```

### Step 3: Create Database Users

```bash
# Create application user
gcloud sql users create appuser \
  --instance=ecommerce-postgres \
  --password=STRONG_PASSWORD_HERE
```

### Step 4: Run Database Migrations

```bash
# For User Service
cd database/postgresql/users
psql -h localhost -U appuser -d ecommerce_users -f schema.sql
psql -h localhost -U appuser -d ecommerce_users -f initial-data.sql

# For Product Service
cd ../products
psql -h localhost -U appuser -d ecommerce_products -f schema.sql
psql -h localhost -U appuser -d ecommerce_products -f initial-data.sql

# For Order Service
cd ../orders
psql -h localhost -U appuser -d ecommerce_orders -f schema.sql
```

---

## 6. Application Deployment

### Step 1: Build and Push Docker Images

```bash
# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central1"

# Create Artifact Registry repository
gcloud artifacts repositories create ecommerce-repo \
  --repository-format=docker \
  --location=$REGION \
  --description="E-Commerce Docker images"

# Configure Docker authentication
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Build and push User Service
cd backend/user-service
docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-repo/user-service:v1.0.0 .
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-repo/user-service:v1.0.0

# Build and push Frontend
cd ../../frontend
docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-repo/frontend:v1.0.0 .
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-repo/frontend:v1.0.0
```

### Step 2: Create Kubernetes Secrets

```bash
# Create secret for database credentials
kubectl create secret generic db-credentials \
  --from-literal=username=appuser \
  --from-literal=password=STRONG_PASSWORD_HERE \
  --namespace=production

# Create secret for JWT
kubectl create secret generic jwt-secret \
  --from-literal=secret=YOUR_JWT_SECRET_KEY \
  --namespace=production

# Create secret for GCP service account
kubectl create secret generic gcp-service-account \
  --from-file=key.json=$GOOGLE_APPLICATION_CREDENTIALS \
  --namespace=production
```

### Step 3: Deploy to Kubernetes

```bash
cd infrastructure/kubernetes

# Create namespace
kubectl create namespace production

# Deploy ConfigMaps
kubectl apply -f config/configmap.yaml -n production

# Deploy Services
kubectl apply -f deployments/user-service-deployment.yaml -n production
kubectl apply -f services/user-service-service.yaml -n production

# Deploy Frontend
kubectl apply -f deployments/frontend-deployment.yaml -n production
kubectl apply -f services/frontend-service.yaml -n production

# Deploy Ingress
kubectl apply -f ingress/ingress.yaml -n production
```

### Step 4: Verify Deployments

```bash
# Check pods
kubectl get pods -n production

# Check services
kubectl get services -n production

# Check ingress
kubectl get ingress -n production

# Get external IP
kubectl get ingress -n production -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'

# Check logs
kubectl logs -f deployment/user-service -n production
```

---

## 7. CI/CD Pipeline Setup

### Step 1: Setup Jenkins on GKE

```bash
# Apply Jenkins deployment
kubectl apply -f ci-cd/jenkins/jenkins-deployment.yaml

# Get Jenkins password
kubectl exec -it deployment/jenkins -n jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword

# Port forward to access Jenkins UI
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Access Jenkins at: http://localhost:8080

### Step 2: Configure Jenkins Pipeline

1. Install required plugins:
   - Docker Pipeline
   - Kubernetes
   - Git
   - Google Cloud SDK

2. Add credentials:
   - GCP Service Account (JSON key)
   - GitHub/GitLab token
   - DockerHub/Artifact Registry credentials

3. Create pipeline job from `ci-cd/jenkins/Jenkinsfile`

### Step 3: Setup ArgoCD

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8443:443
```

Access ArgoCD at: https://localhost:8443

### Step 4: Configure ArgoCD Applications

```bash
# Apply ArgoCD application manifests
kubectl apply -f ci-cd/argocd/applications/ -n argocd

# Sync applications
argocd app sync user-service-prod
argocd app sync frontend-prod
```

---

## 8. Monitoring and Observability

### Step 1: Deploy Prometheus

```bash
# Add Prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f monitoring/prometheus/values.yaml
```

### Step 2: Configure Grafana

```bash
# Get Grafana password
kubectl get secret --namespace monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode

# Port forward Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Access Grafana at: http://localhost:3000

Import dashboards from `monitoring/grafana/dashboards/`

### Step 3: Setup Cloud Logging

```bash
# Enable Cloud Logging
gcloud logging sinks create ecommerce-logs-sink \
  storage.googleapis.com/ecommerce-logs-bucket

# View logs
gcloud logging read "resource.type=k8s_container" --limit 50
```

### Step 4: Configure Alerting

```bash
# Apply Prometheus alerting rules
kubectl apply -f monitoring/prometheus/alerts/ -n monitoring

# Configure notification channels (Slack, Email, PagerDuty)
# Update monitoring/prometheus/alertmanager-config.yaml
kubectl apply -f monitoring/prometheus/alertmanager-config.yaml -n monitoring
```

---

## 9. Security Configuration

### Step 1: Configure Cloud Armor

```bash
# Create security policy
gcloud compute security-policies create ecommerce-security-policy \
  --description="Security policy for e-commerce application"

# Add rate limiting rule
gcloud compute security-policies rules create 1000 \
  --security-policy=ecommerce-security-policy \
  --expression="true" \
  --action=rate-based-ban \
  --rate-limit-threshold-count=100 \
  --rate-limit-threshold-interval-sec=60 \
  --ban-duration-sec=600

# Attach to backend service
gcloud compute backend-services update ecommerce-backend \
  --security-policy=ecommerce-security-policy \
  --global
```

### Step 2: Configure SSL/TLS

```bash
# Create managed SSL certificate
gcloud compute ssl-certificates create ecommerce-ssl-cert \
  --domains=your-domain.com,www.your-domain.com \
  --global

# Update load balancer to use HTTPS
kubectl apply -f infrastructure/kubernetes/ingress/https-ingress.yaml
```

### Step 3: Setup IAM Policies

```bash
# Apply least privilege principle
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:gke-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"

# Enable Workload Identity
gcloud iam service-accounts add-iam-policy-binding gke-sa@${PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[production/user-service]"
```

---

## 10. Troubleshooting

### Common Issues and Solutions

#### Issue 1: Pods Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n production

# Check events
kubectl get events -n production --sort-by='.lastTimestamp'

# Common fixes:
# - Check resource limits
# - Verify image pull secrets
# - Check ConfigMap/Secret references
```

#### Issue 2: Database Connection Errors

```bash
# Test database connectivity
kubectl run -it --rm debug --image=postgres:15 --restart=Never -- \
  psql -h <CLOUDSQL_IP> -U appuser -d ecommerce_users

# Verify Cloud SQL Proxy
kubectl logs deployment/user-service -n production | grep "database"

# Check firewall rules
gcloud compute firewall-rules list
```

#### Issue 3: High Latency

```bash
# Check pod resources
kubectl top pods -n production

# Scale up if needed
kubectl scale deployment user-service --replicas=5 -n production

# Check HPA status
kubectl get hpa -n production

# Review metrics in Grafana
```

#### Issue 4: Image Pull Errors

```bash
# Verify image exists
gcloud artifacts docker images list ${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-repo

# Check image pull secret
kubectl get secret -n production

# Recreate secret if needed
kubectl delete secret regcred -n production
kubectl create secret docker-registry regcred \
  --docker-server=${REGION}-docker.pkg.dev \
  --docker-username=_json_key \
  --docker-password="$(cat ~/gcp-key.json)" \
  -n production
```

---

## 11. Maintenance and Operations

### Daily Tasks

1. **Monitor Application Health**
```bash
# Check all pods
kubectl get pods -n production

# Check services
kubectl get svc -n production

# View logs for errors
kubectl logs -l app=user-service -n production --tail=100 | grep ERROR
```

2. **Review Metrics**
- Access Grafana dashboards
- Check error rates, latency, throughput
- Review resource utilization

### Weekly Tasks

1. **Review and Rotate Logs**
```bash
# Archive old logs
gcloud logging logs delete --before="7d" resource.type=k8s_container
```

2. **Update Dependencies**
```bash
# Check for security updates
mvn versions:display-dependency-updates
npm audit
```

3. **Database Maintenance**
```bash
# Run vacuum on PostgreSQL
gcloud sql operations list --instance=ecommerce-postgres
```

### Monthly Tasks

1. **Review and Optimize Costs**
```bash
# Check GKE resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Review Cloud Storage usage
gsutil du -sh gs://*/
```

2. **Security Audit**
```bash
# Run security scan
gcloud container images scan <image-url>

# Review IAM policies
gcloud projects get-iam-policy $PROJECT_ID
```

3. **Backup Verification**
```bash
# Test database restore
gcloud sql backups list --instance=ecommerce-postgres
```

### Scaling Operations

#### Horizontal Pod Autoscaling
```bash
# Already configured in HPA manifests
kubectl get hpa -n production

# Manual scaling if needed
kubectl scale deployment user-service --replicas=10 -n production
```

#### Vertical Scaling (Node Pool)
```bash
# Add larger nodes
gcloud container node-pools create high-memory-pool \
  --cluster=ecommerce-gke-cluster \
  --machine-type=n2-highmem-4 \
  --num-nodes=3
```

### Disaster Recovery

#### Backup Procedures
```bash
# Database backups (automatic daily)
gcloud sql backups create --instance=ecommerce-postgres

# Kubernetes manifests backup
kubectl get all -n production -o yaml > backup-$(date +%Y%m%d).yaml
```

#### Recovery Procedures
```bash
# Restore database
gcloud sql backups restore <BACKUP_ID> \
  --backup-instance=ecommerce-postgres

# Restore Kubernetes resources
kubectl apply -f backup-YYYYMMDD.yaml
```

---

## Success Criteria

✅ All services running in production namespace  
✅ Health checks passing for all components  
✅ HTTPS enabled with valid SSL certificate  
✅ Monitoring dashboards configured and accessible  
✅ CI/CD pipeline operational  
✅ Database backups running daily  
✅ Logs aggregated in Cloud Logging  
✅ Alerts configured and tested  
✅ Documentation complete and accessible  

---

## Support and Contact

For issues or questions:
- **Documentation**: [docs/](../docs/)
- **Issue Tracker**: GitHub Issues
- **Team Email**: devops@your-company.com
- **Slack Channel**: #ecommerce-platform

---

**Last Updated**: 2025-01-15  
**Version**: 1.0.0  
**Maintained By**: DevOps Team

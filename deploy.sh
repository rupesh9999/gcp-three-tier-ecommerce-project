#!/bin/bash

# Complete Deployment Script for GCP Three-Tier E-Commerce Project
# This script orchestrates the entire deployment process

set -e

# Configuration
PROJECT_ID="vaulted-harbor-476903-t8"
REGION="us-central1"
CLUSTER_NAME="ecommerce-gke-cluster"
DB_INSTANCE_NAME="ecommerce-postgres"
VERSION="${1:-v1.0.0}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Step 1: Configure kubectl for GKE
configure_kubectl() {
    print_status "Configuring kubectl for GKE cluster..."
    
    gcloud container clusters get-credentials ${CLUSTER_NAME} \
        --region=${REGION} \
        --project=${PROJECT_ID}
    
    if [ $? -eq 0 ]; then
        print_success "kubectl configured successfully"
        kubectl cluster-info
    else
        print_error "Failed to configure kubectl"
        exit 1
    fi
}

# Step 2: Create Kubernetes namespaces
create_namespaces() {
    print_status "Creating Kubernetes namespaces..."
    
    kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    print_success "Namespaces created"
}

# Step 3: Get infrastructure outputs from Terraform
get_infrastructure_info() {
    print_status "Getting infrastructure information from Terraform..."
    
    cd "${SCRIPT_DIR}/infrastructure/terraform"
    
    export CLOUDSQL_CONNECTION_NAME=$(terraform output -raw cloudsql_connection_name 2>/dev/null || echo "")
    export CLOUDSQL_PRIVATE_IP=$(terraform output -raw cloudsql_private_ip 2>/dev/null || echo "")
    export REDIS_HOST=$(terraform output -raw redis_host 2>/dev/null || echo "")
    export REDIS_PORT=$(terraform output -raw redis_port 2>/dev/null || echo "")
    
    print_success "Infrastructure info retrieved"
    echo "  Cloud SQL: ${CLOUDSQL_PRIVATE_IP}"
    echo "  Redis: ${REDIS_HOST}:${REDIS_PORT}"
}

# Step 4: Create Kubernetes secrets
create_secrets() {
    print_status "Creating Kubernetes secrets..."
    
    # Database credentials (using default for now, should be changed in production)
    kubectl create secret generic db-credentials \
        --from-literal=username=ecommerce_user \
        --from-literal=password=SecureP@ssw0rd123 \
        --namespace=ecommerce \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # JWT secret
    JWT_SECRET=$(openssl rand -base64 32)
    kubectl create secret generic jwt-secret \
        --from-literal=secret=${JWT_SECRET} \
        --namespace=ecommerce \
        --dry-run=client -o yaml | kubectl apply -f -
    
    print_success "Secrets created"
}

# Step 5: Create ConfigMaps
create_configmaps() {
    print_status "Creating Kubernetes ConfigMaps..."
    
    # Application config
    kubectl create configmap app-config \
        --from-literal=SPRING_PROFILES_ACTIVE=production \
        --from-literal=DB_HOST=${CLOUDSQL_PRIVATE_IP} \
        --from-literal=DB_PORT=5432 \
        --from-literal=DB_NAME=ecommerce \
        --from-literal=REDIS_HOST=${REDIS_HOST} \
        --from-literal=REDIS_PORT=${REDIS_PORT} \
        --namespace=ecommerce \
        --dry-run=client -o yaml | kubectl apply -f -
    
    print_success "ConfigMaps created"
}

# Step 6: Initialize database
initialize_database() {
    print_status "Initializing PostgreSQL database..."
    
    # Check if gcloud sql connect is available
    if command -v gcloud &> /dev/null; then
        print_status "Connecting to Cloud SQL instance..."
        
        # Create database and user
        gcloud sql databases create ecommerce \
            --instance=${DB_INSTANCE_NAME} \
            --project=${PROJECT_ID} 2>/dev/null || print_warning "Database already exists"
        
        print_success "Database initialized"
        
        print_warning "Manual step required: Execute database schema"
        print_warning "Run: gcloud sql connect ${DB_INSTANCE_NAME} --user=postgres --project=${PROJECT_ID}"
        print_warning "Then execute the SQL files in: database/postgresql/users/"
    else
        print_error "gcloud CLI not found"
        exit 1
    fi
}

# Step 7: Deploy applications to Kubernetes
deploy_applications() {
    print_status "Deploying applications to Kubernetes..."
    
    cd "${SCRIPT_DIR}/kubernetes"
    
    # Update image tags in deployments
    sed -i "s|image:.*frontend:.*|image: ${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-repo/frontend:${VERSION}|g" deployments/frontend-deployment.yaml 2>/dev/null || true
    sed -i "s|image:.*user-service:.*|image: ${REGION}-docker.pkg.dev/${PROJECT_ID}/ecommerce-repo/user-service:${VERSION}|g" deployments/user-service-deployment.yaml 2>/dev/null || true
    
    # Apply configurations
    print_status "Applying ConfigMaps..."
    kubectl apply -f config/ -n ecommerce 2>/dev/null || print_warning "No config files found"
    
    print_status "Applying Deployments..."
    kubectl apply -f deployments/ -n ecommerce
    
    print_status "Applying Services..."
    kubectl apply -f services/ -n ecommerce
    
    print_status "Applying Ingress..."
    kubectl apply -f ingress/ 2>/dev/null || print_warning "No ingress files found"
    
    print_success "Applications deployed"
}

# Step 8: Wait for deployments to be ready
wait_for_deployments() {
    print_status "Waiting for deployments to be ready..."
    
    kubectl wait --for=condition=available --timeout=300s \
        deployment --all -n ecommerce 2>/dev/null || print_warning "Some deployments may not be ready yet"
    
    print_success "Deployments are ready"
}

# Step 9: Display deployment information
display_info() {
    print_status "=== Deployment Information ==="
    echo ""
    
    print_status "Pods:"
    kubectl get pods -n ecommerce
    echo ""
    
    print_status "Services:"
    kubectl get services -n ecommerce
    echo ""
    
    print_status "Ingress:"
    kubectl get ingress -n ecommerce 2>/dev/null || echo "No ingress configured"
    echo ""
    
    # Get LoadBalancer IP if available
    LB_IP=$(kubectl get service -n ecommerce -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    if [ ! -z "$LB_IP" ]; then
        print_success "Application URL: http://${LB_IP}"
    else
        print_warning "LoadBalancer IP not yet assigned. Run: kubectl get services -n ecommerce --watch"
    fi
}

# Main execution
main() {
    echo "================================================================"
    echo "  GCP Three-Tier E-Commerce Platform Deployment"
    echo "================================================================"
    echo ""
    print_status "Starting deployment process..."
    echo ""
    
    configure_kubectl
    echo ""
    
    create_namespaces
    echo ""
    
    get_infrastructure_info
    echo ""
    
    create_secrets
    echo ""
    
    create_configmaps
    echo ""
    
    print_warning "Skipping database initialization (requires manual setup)"
    echo ""
    
    deploy_applications
    echo ""
    
    wait_for_deployments
    echo ""
    
    display_info
    echo ""
    
    print_success "=== Deployment Complete ==="
    echo ""
    print_status "Next steps:"
    echo "  1. Initialize the database schema (see database/postgresql/users/)"
    echo "  2. Verify all pods are running: kubectl get pods -n ecommerce"
    echo "  3. Access the application via the LoadBalancer IP"
    echo "  4. Monitor logs: kubectl logs -f deployment/<deployment-name> -n ecommerce"
}

# Run main function
main "$@"

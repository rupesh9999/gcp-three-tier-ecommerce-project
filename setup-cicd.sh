#!/bin/bash

# Quick Start Script for Cloud Build CI/CD Setup
# This script completes the CI/CD setup using Google Cloud Build
# Total time: ~10 minutes

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="vaulted-harbor-476903-t8"
REGION="us-central1"
CLUSTER_NAME="ecommerce-cluster"
CLUSTER_ZONE="us-central1-a"
GITHUB_OWNER="rupesh9999"
REPO_NAME="gcp-three-tier-ecommerce-project"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GCP E-Commerce CI/CD Quick Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print step
print_step() {
    echo -e "${GREEN}[STEP $1/${2}]${NC} $3"
}

# Function to print info
print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print error
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed. Please install it first."
    exit 1
fi

# Verify project
print_step 1 6 "Verifying GCP project"
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
if [ "$CURRENT_PROJECT" != "$PROJECT_ID" ]; then
    print_info "Setting project to $PROJECT_ID"
    gcloud config set project $PROJECT_ID
fi
print_success "Project: $PROJECT_ID"
echo ""

# Check Cloud Build API
print_step 2 6 "Checking Cloud Build API"
API_ENABLED=$(gcloud services list --enabled --filter="name:cloudbuild.googleapis.com" --format="value(name)" 2>/dev/null)
if [ -z "$API_ENABLED" ]; then
    print_info "Enabling Cloud Build API..."
    gcloud services enable cloudbuild.googleapis.com
    print_success "Cloud Build API enabled"
else
    print_success "Cloud Build API already enabled"
fi
echo ""

# Grant Cloud Build permissions
print_step 3 6 "Granting Cloud Build service account permissions"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
CLOUD_BUILD_SA="$PROJECT_NUMBER@cloudbuild.gserviceaccount.com"
print_info "Service Account: $CLOUD_BUILD_SA"

# Check if permissions already granted
EXISTING_ROLE=$(gcloud projects get-iam-policy $PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:$CLOUD_BUILD_SA AND bindings.role:roles/container.developer" \
    --format="value(bindings.role)" 2>/dev/null)

if [ -z "$EXISTING_ROLE" ]; then
    print_info "Granting roles/container.developer..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member=serviceAccount:$CLOUD_BUILD_SA \
        --role=roles/container.developer \
        --no-user-output-enabled > /dev/null
    print_success "Container developer role granted"
else
    print_success "Permissions already configured"
fi
echo ""

# Connect GitHub repository
print_step 4 6 "GitHub Repository Connection"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}  ACTION REQUIRED: Manual Step${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo ""
echo "1. Open this URL in your browser:"
echo -e "   ${BLUE}https://console.cloud.google.com/cloud-build/triggers?project=$PROJECT_ID${NC}"
echo ""
echo "2. Click the 'CONNECT REPOSITORY' button"
echo ""
echo "3. Select 'GitHub' as the source"
echo ""
echo "4. Authenticate with GitHub (if prompted)"
echo ""
echo "5. Select repository: ${GREEN}$GITHUB_OWNER/$REPO_NAME${NC}"
echo ""
echo "6. Click 'CONNECT' → then 'DONE'"
echo ""
read -p "Press ENTER after you've connected the repository..."
echo ""
print_success "Repository connected"
echo ""

# Create Build Triggers
print_step 5 6 "Creating Cloud Build Triggers"
echo ""

# Function to create trigger
create_trigger() {
    local SERVICE_NAME=$1
    local BUILD_CONFIG=$2
    local INCLUDE_FILTER=$3
    local TRIGGER_NAME="${SERVICE_NAME}-trigger"
    
    # Check if trigger already exists
    EXISTING_TRIGGER=$(gcloud builds triggers list --filter="name=$TRIGGER_NAME" --format="value(name)" 2>/dev/null)
    
    if [ -n "$EXISTING_TRIGGER" ]; then
        print_info "Trigger '$TRIGGER_NAME' already exists, skipping..."
        return 0
    fi
    
    print_info "Creating trigger: $TRIGGER_NAME"
    
    gcloud builds triggers create github \
        --name="$TRIGGER_NAME" \
        --repo-name=$REPO_NAME \
        --repo-owner=$GITHUB_OWNER \
        --branch-pattern="^main$" \
        --build-config=$BUILD_CONFIG \
        --included-files="$INCLUDE_FILTER" \
        --no-user-output-enabled > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "✓ $TRIGGER_NAME created"
    else
        print_error "Failed to create $TRIGGER_NAME (you may need to connect GitHub first)"
    fi
}

# Create all triggers
create_trigger "user-service" "backend/user-service/cloudbuild.yaml" "backend/user-service/**"
create_trigger "product-service" "backend/product-service/cloudbuild.yaml" "backend/product-service/**"
create_trigger "order-service" "backend/order-service/cloudbuild.yaml" "backend/order-service/**"
create_trigger "frontend" "frontend/cloudbuild.yaml" "frontend/**"

echo ""
print_success "All triggers created"
echo ""

# Test manual build
print_step 6 6 "Testing Manual Build (Optional)"
echo ""
read -p "Do you want to test a manual build now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Starting test build for user-service..."
    echo ""
    
    cd /home/ubuntu/gcp-three-tier-ecommerce-project
    
    gcloud builds submit \
        --config backend/user-service/cloudbuild.yaml \
        --no-source \
        --async \
        . 2>&1 | grep -E "Created|build|ID:|logs"
    
    echo ""
    print_info "Build started! Monitor it here:"
    echo -e "   ${BLUE}https://console.cloud.google.com/cloud-build/builds?project=$PROJECT_ID${NC}"
    echo ""
    print_info "Or use: ${BLUE}gcloud builds list --limit=5${NC}"
else
    print_info "Skipping test build"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ CI/CD Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}What's Next?${NC}"
echo ""
echo "1. View your triggers:"
echo -e "   ${BLUE}https://console.cloud.google.com/cloud-build/triggers?project=$PROJECT_ID${NC}"
echo ""
echo "2. View build history:"
echo -e "   ${BLUE}https://console.cloud.google.com/cloud-build/builds?project=$PROJECT_ID${NC}"
echo ""
echo "3. Test automatic builds:"
echo "   Make any change to the code and push to 'main' branch"
echo "   The build will trigger automatically!"
echo ""
echo "4. Monitor deployments:"
echo "   ${BLUE}kubectl get deployments -n ecommerce${NC}"
echo "   ${BLUE}kubectl get pods -n ecommerce${NC}"
echo ""
echo -e "${YELLOW}Jenkins Access:${NC}"
echo "   URL: http://34.46.37.36/jenkins"
echo "   User: admin"
echo "   Pass: admin@123"
echo ""
echo -e "${YELLOW}Application Access:${NC}"
echo "   HTTPS: https://34.8.28.111"
echo "   HTTP: http://34.8.28.111"
echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"
echo ""

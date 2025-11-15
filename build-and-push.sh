#!/bin/bash

# Build and Push Docker Images to GCP Artifact Registry
# This script builds frontend and backend Docker images and pushes them to Artifact Registry

set -e

# Configuration
PROJECT_ID="vaulted-harbor-476903-t8"
REGION="us-central1"
REPO_NAME="ecommerce-repo"
VERSION="${1:-v1.0.0}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configure Docker for GCP
configure_docker() {
    print_status "Configuring Docker for GCP Artifact Registry..."
    gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet
    if [ $? -eq 0 ]; then
        print_success "Docker configured successfully"
    else
        print_error "Failed to configure Docker"
        exit 1
    fi
}

# Build and push frontend image
build_frontend() {
    print_status "Building frontend Docker image..."
    
    cd "${SCRIPT_DIR}/frontend"
    
    IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/frontend:${VERSION}"
    IMAGE_LATEST="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/frontend:latest"
    
    docker build -t ${IMAGE_NAME} -t ${IMAGE_LATEST} .
    
    if [ $? -eq 0 ]; then
        print_success "Frontend image built successfully"
        
        print_status "Pushing frontend image to Artifact Registry..."
        docker push ${IMAGE_NAME}
        docker push ${IMAGE_LATEST}
        
        print_success "Frontend image pushed: ${IMAGE_NAME}"
    else
        print_error "Failed to build frontend image"
        exit 1
    fi
}

# Build and push backend image
build_backend() {
    print_status "Building backend Docker image..."
    
    cd "${SCRIPT_DIR}/backend/user-service"
    
    IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/user-service:${VERSION}"
    IMAGE_LATEST="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/user-service:latest"
    
    docker build -t ${IMAGE_NAME} -t ${IMAGE_LATEST} .
    
    if [ $? -eq 0 ]; then
        print_success "Backend image built successfully"
        
        print_status "Pushing backend image to Artifact Registry..."
        docker push ${IMAGE_NAME}
        docker push ${IMAGE_LATEST}
        
        print_success "Backend image pushed: ${IMAGE_NAME}"
    else
        print_error "Failed to build backend image"
        exit 1
    fi
}

# Main execution
main() {
    print_status "=== Building and Pushing Docker Images ==="
    print_status "Project ID: ${PROJECT_ID}"
    print_status "Region: ${REGION}"
    print_status "Repository: ${REPO_NAME}"
    print_status "Version: ${VERSION}"
    echo ""
    
    configure_docker
    echo ""
    
    build_frontend
    echo ""
    
    build_backend
    echo ""
    
    print_success "=== All images built and pushed successfully ==="
    echo ""
    print_status "Images:"
    echo "  - ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/frontend:${VERSION}"
    echo "  - ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/user-service:${VERSION}"
}

# Run main function
main "$@"

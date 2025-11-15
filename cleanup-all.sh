#!/bin/bash

# Comprehensive cleanup script for GCP Three-Tier E-Commerce Project
# This script removes all resources created during the deployment

set -e

PROJECT_ID="vaulted-harbor-476903-t8"
REGION="us-central1"
ZONE="us-central1-a"
CLUSTER_NAME="ecommerce-gke-cluster"

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

# Function to delete GKE cluster
delete_gke_cluster() {
    print_status "Checking for GKE cluster..."
    if gcloud container clusters list --project=$PROJECT_ID --filter="name=$CLUSTER_NAME" --format="value(name)" | grep -q "$CLUSTER_NAME"; then
        print_status "Deleting GKE cluster: $CLUSTER_NAME"
        gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE --project=$PROJECT_ID --quiet --async 2>/dev/null || print_warning "GKE cluster deletion initiated"
    else
        print_status "No GKE cluster found"
    fi
}

# Function to delete Cloud SQL instance
delete_cloudsql() {
    print_status "Checking for Cloud SQL instance..."
    if gcloud sql instances list --project=$PROJECT_ID --filter="name:ecommerce-postgres" --format="value(name)" | grep -q "ecommerce-postgres"; then
        print_status "Deleting Cloud SQL instance: ecommerce-postgres"
        # First disable deletion protection
        gcloud sql instances patch ecommerce-postgres --project=$PROJECT_ID --no-deletion-protection --quiet 2>/dev/null || true
        gcloud sql instances delete ecommerce-postgres --project=$PROJECT_ID --quiet 2>/dev/null || print_warning "Cloud SQL deletion initiated"
    else
        print_status "No Cloud SQL instance found"
    fi
}

# Function to delete Redis instance
delete_redis() {
    print_status "Checking for Redis instance..."
    if gcloud redis instances list --region=$REGION --project=$PROJECT_ID --format="value(name)" | grep -q "ecommerce-redis"; then
        print_status "Deleting Redis instance: ecommerce-redis"
        gcloud redis instances delete ecommerce-redis --region=$REGION --project=$PROJECT_ID --quiet 2>/dev/null || print_warning "Redis deletion initiated"
    else
        print_status "No Redis instance found"
    fi
}

# Function to delete storage buckets
delete_buckets() {
    print_status "Checking for storage buckets..."
    BUCKETS=$(gcloud storage buckets list --project=$PROJECT_ID --format="value(name)" | grep -E "(ecommerce|frontend-static|product-images)" || true)

    for bucket in $BUCKETS; do
        print_status "Deleting bucket: $bucket"
        gcloud storage rm --recursive gs://$bucket/ 2>/dev/null || print_warning "Bucket deletion initiated: $bucket"
    done
}

# Function to delete Pub/Sub topics and subscriptions
delete_pubsub() {
    print_status "Checking for Pub/Sub resources..."

    # Delete subscriptions first
    SUBSCRIPTIONS=$(gcloud pubsub subscriptions list --project=$PROJECT_ID --format="value(name)" | grep -E "(order-created|order-updated|payment-processed|notification-requested|inventory-updated|dead-letter)" || true)

    for sub in $SUBSCRIPTIONS; do
        print_status "Deleting subscription: $sub"
        gcloud pubsub subscriptions delete $sub --project=$PROJECT_ID --quiet 2>/dev/null || print_warning "Subscription deletion failed: $sub"
    done

    # Delete topics
    TOPICS=$(gcloud pubsub topics list --project=$PROJECT_ID --format="value(name)" | grep -E "(order-created|order-updated|payment-processed|notification-requested|inventory-updated|dead-letter)" || true)

    for topic in $TOPICS; do
        print_status "Deleting topic: $topic"
        gcloud pubsub topics delete $topic --project=$PROJECT_ID --quiet 2>/dev/null || print_warning "Topic deletion failed: $topic"
    done
}

# Function to delete Artifact Registry repository
delete_artifact_registry() {
    print_status "Checking for Artifact Registry repository..."
    if gcloud artifacts repositories list --location=$REGION --project=$PROJECT_ID --format="value(name)" | grep -q "ecommerce-repo"; then
        print_status "Deleting Artifact Registry repository: ecommerce-repo"
        gcloud artifacts repositories delete ecommerce-repo --location=$REGION --project=$PROJECT_ID --quiet 2>/dev/null || print_warning "Artifact Registry deletion initiated"
    else
        print_status "No Artifact Registry repository found"
    fi
}

# Function to delete service accounts
delete_service_accounts() {
    print_status "Checking for service accounts..."
    if gcloud iam service-accounts list --project=$PROJECT_ID --format="value(email)" | grep -q "gke-service-account"; then
        print_status "Deleting service account: gke-service-account"
        gcloud iam service-accounts delete gke-service-account@vaulted-harbor-476903-t8.iam.gserviceaccount.com --project=$PROJECT_ID --quiet 2>/dev/null || print_warning "Service account deletion failed"
    else
        print_status "No service account found"
    fi
}

# Function to delete Terraform state bucket
delete_terraform_state() {
    print_status "Checking for Terraform state bucket..."
    if gcloud storage buckets list --project=$PROJECT_ID --format="value(name)" | grep -q "ecommerce-terraform-state-t8"; then
        print_status "Deleting Terraform state bucket: ecommerce-terraform-state-t8"
        gcloud storage rm --recursive gs://ecommerce-terraform-state-t8/ 2>/dev/null || print_warning "Terraform state bucket deletion initiated"
    else
        print_status "No Terraform state bucket found"
    fi
}

# Function to clean up Terraform state
cleanup_terraform() {
    print_status "Cleaning up Terraform state..."
    cd /home/ubuntu/gcp-three-tier-ecommerce-project/infrastructure/terraform

    # Remove all resources from state
    terraform state list 2>/dev/null | xargs -I {} terraform state rm {} 2>/dev/null || true

    print_success "Terraform state cleaned"
}

# Main cleanup function
main() {
    echo "================================================================="
    echo "  GCP Three-Tier E-Commerce Project - Resource Cleanup"
    echo "================================================================="
    echo ""
    print_warning "This will delete ALL resources created for the e-commerce project!"
    echo ""

    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        print_status "Cleanup cancelled"
        exit 0
    fi

    echo ""

    # Delete resources in dependency order
    delete_gke_cluster
    sleep 10

    delete_cloudsql
    sleep 5

    delete_redis
    sleep 5

    delete_buckets
    sleep 5

    delete_pubsub
    sleep 5

    delete_artifact_registry
    sleep 5

    delete_service_accounts
    sleep 5

    # Clean up Terraform state
    cleanup_terraform

    # Finally delete Terraform state bucket
    delete_terraform_state

    echo ""
    print_success "Cleanup initiated! Some resources may take time to delete."
    print_status "Monitor progress with:"
    echo "  gcloud container clusters list --project=$PROJECT_ID"
    echo "  gcloud sql instances list --project=$PROJECT_ID"
    echo "  gcloud redis instances list --region=$REGION --project=$PROJECT_ID"
    echo ""
    print_status "Once all resources are deleted, you can safely delete the VPC network and subnets manually if needed."
}

# Run main function
main "$@"
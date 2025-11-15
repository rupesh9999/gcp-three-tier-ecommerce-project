#!/bin/bash

# Script to wait for GKE cluster to be ready and import into Terraform

PROJECT_ID="vaulted-harbor-476903-t8"
CLUSTER_NAME="ecommerce-gke-cluster"
ZONE="us-central1-a"

echo "Waiting for GKE cluster to be RUNNING..."

while true; do
    STATUS=$(gcloud container clusters list --project=$PROJECT_ID --filter="name=$CLUSTER_NAME" --format="value(status)" 2>/dev/null)
    
    if [ "$STATUS" == "RUNNING" ]; then
        echo "✅ Cluster is RUNNING!"
        break
    else
        echo "⏳ Cluster status: $STATUS - waiting 30 seconds..."
        sleep 30
    fi
done

echo ""
echo "Importing GKE cluster into Terraform state..."
terraform import google_container_cluster.primary projects/$PROJECT_ID/locations/$ZONE/clusters/$CLUSTER_NAME

echo ""
echo "Importing node pool into Terraform state..."
NODE_POOL=$(gcloud container node-pools list --cluster=$CLUSTER_NAME --zone=$ZONE --project=$PROJECT_ID --format="value(name)" | head -1)
terraform import google_container_node_pool.primary_nodes projects/$PROJECT_ID/locations/$ZONE/clusters/$CLUSTER_NAME/nodePools/$NODE_POOL

echo ""
echo "✅ Import complete! Verifying state..."
terraform state list | grep google_container

echo ""
echo "🎉 GKE cluster is ready and managed by Terraform!"

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "vaulted-harbor-476903-t8"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for zonal resources like GKE cluster"
  type        = string
  default     = "us-central1-a"
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "ecommerce-vpc"
}

variable "gke_cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "ecommerce-gke-cluster"
}

variable "gke_node_count" {
  description = "Number of GKE nodes"
  type        = number
  default     = 3
}

variable "gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "db_instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
  default     = "ecommerce-postgres"
}

variable "db_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-custom-2-7680"
}

variable "db_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_15"
}

variable "redis_instance_name" {
  description = "Name of the Redis instance"
  type        = string
  default     = "ecommerce-redis"
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB"
  type        = number
  default     = 2
}

variable "frontend_bucket_name" {
  description = "Name of the frontend static files bucket"
  type        = string
  default     = "frontend-static"
}

variable "images_bucket_name" {
  description = "Name of the product images bucket"
  type        = string
  default     = "product-images"
}

variable "pubsub_topics" {
  description = "List of Pub/Sub topics to create"
  type        = list(string)
  default = [
    "order-created",
    "order-updated",
    "payment-processed",
    "notification-requested",
    "inventory-updated"
  ]
}

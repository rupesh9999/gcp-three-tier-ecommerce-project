output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}

output "vpc_network_name" {
  description = "VPC Network Name"
  value       = google_compute_network.vpc_network.name
}

output "gke_cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.primary.name
}

output "gke_cluster_endpoint" {
  description = "GKE Cluster Endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "gke_cluster_ca_certificate" {
  description = "GKE Cluster CA Certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cloudsql_instance_name" {
  description = "Cloud SQL Instance Name"
  value       = google_sql_database_instance.postgres.name
}

output "cloudsql_connection_name" {
  description = "Cloud SQL Connection Name"
  value       = google_sql_database_instance.postgres.connection_name
}

output "cloudsql_private_ip" {
  description = "Cloud SQL Private IP Address"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "redis_instance_name" {
  description = "Redis Instance Name"
  value       = google_redis_instance.cache.name
}

output "redis_host" {
  description = "Redis Host IP"
  value       = google_redis_instance.cache.host
}

output "redis_port" {
  description = "Redis Port"
  value       = google_redis_instance.cache.port
}

output "frontend_bucket_name" {
  description = "Frontend Static Files Bucket Name"
  value       = google_storage_bucket.frontend_static.name
}

output "frontend_bucket_url" {
  description = "Frontend Static Files Bucket URL"
  value       = google_storage_bucket.frontend_static.url
}

output "images_bucket_name" {
  description = "Product Images Bucket Name"
  value       = google_storage_bucket.product_images.name
}

output "images_bucket_url" {
  description = "Product Images Bucket URL"
  value       = google_storage_bucket.product_images.url
}

output "artifact_registry_repository" {
  description = "Artifact Registry Repository Name"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "static_ip_address" {
  description = "Static IP Address for Load Balancer"
  value       = google_compute_global_address.default.address
}

output "pubsub_topics" {
  description = "Pub/Sub Topics"
  value       = { for k, v in google_pubsub_topic.topics : k => v.name }
}

output "gke_service_account_email" {
  description = "GKE Service Account Email"
  value       = google_service_account.gke_sa.email
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}

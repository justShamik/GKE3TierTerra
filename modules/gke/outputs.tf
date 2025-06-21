# modules/gke/outputs.tf
# Defines outputs for GKE module resources.

# Endpoint of the GKE cluster
output "cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = google_container_cluster.democluster.endpoint
}

# Name of the GKE cluster
output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.democluster.name
}

# CA certificate of the GKE cluster
output "cluster_ca_certificate" {
  description = "CA certificate of the GKE cluster"
  value       = google_container_cluster.democluster.master_auth[0].cluster_ca_certificate
}
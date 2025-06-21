# modules/vpc/outputs.tf
# Defines outputs for VPC module resources.

# ID of the created VPC
output "vpc_id" {
  description = "ID of the created VPC"
  value       = google_compute_network.test-vpc.id
}

# Name of the created VPC
output "vpc_name" {
  description = "Name of the created VPC"
  value       = google_compute_network.test-vpc.name
}

# Name of the public subnet
output "public_subnet_name" {
  description = "Name of the public subnet"
  value       = google_compute_subnetwork.test-vpc_public.name
}

# Self_link of the public subnet
output "public_subnet_self_link" {
  description = "Self_link of the public subnet"
  value       = google_compute_subnetwork.test-vpc_public.self_link
}

# Name of the private subnet
output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.test-vpc_private.name
}
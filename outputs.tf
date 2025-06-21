output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "gke_cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = module.gke.cluster_endpoint
}

output "service_account_email" {
  description = "Email of the created service account"
  value       = module.iam.service_account_email
}

output "bastion_nat_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.bastion_nat_ip
}
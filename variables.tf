variable "project_name" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "service_account_key" {
  description = "Path to the service account key file"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "master_cluster_cidr" {
  description = "CIDR block for the GKE master cluster"
  type        = string
}

variable "node_zone" {
  description = "GCP zone for nodes and bastion"
  type        = string
}
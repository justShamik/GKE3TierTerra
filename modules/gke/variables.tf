variable "project_name" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "node_zone" {
  description = "GCP zone for nodes"
  type        = string
}

variable "master_cluster_cidr" {
  description = "CIDR block for the GKE master cluster"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
}

variable "service_account_email" {
  description = "Email of the service account"
  type        = string
}

variable "bastion_ip" {
  description = "Public IP of the bastion host"
  type        = string
}
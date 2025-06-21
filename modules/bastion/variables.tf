variable "project_name" {
  description = "GCP project ID"
  type        = string
}

variable "node_zone" {
  description = "GCP zone for the bastion host"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "public_subnet_self_link" {
  description = "Self_link of the public subnet"
  type        = string
}
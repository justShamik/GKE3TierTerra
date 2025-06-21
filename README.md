GKE 3-Tier Infrastructure with Terraform

This project deploys a 3-tier architecture on Google Cloud Platform (GCP) using Terraform. It includes a VPC with public and private subnets, a private GKE cluster, a service account with necessary IAM roles, and a bastion host for secure cluster access. The bastion host also sets up ArgoCD for GitOps.

Table of Contents





Overview



Prerequisites



Directory Structure



Modules



Setup Instructions



Usage



Outputs



Notes

Overview

The infrastructure includes:





VPC: Custom VPC with public and private subnets, firewall rules, and a NAT gateway for private subnet egress.



GKE Cluster: Private GKE cluster with a single node pool, restricted to bastion host access.



IAM: Service account with roles for storage, compute, container, and artifact registry access.



Bastion Host: Compute instance in the public subnet, configured with kubectl, gcloud, and ArgoCD.

Prerequisites





GCP Account: Access to a GCP project with billing enabled.



Terraform: Version 1.5 or higher.



Service Account Key: JSON key file for a service account with permissions to manage GCP resources.



GCS Bucket: A bucket for Terraform state (e.g., shamiktestbucket).



gcloud CLI: Optional, for manual interaction with the GKE cluster.

Directory Structure

.
├── main.tf                # Root Terraform configuration
├── variables.tf           # Input variables
├── outputs.tf             # Output values
├── provider.tf            # Google Cloud provider configuration
├── backend.tf             # GCS backend for Terraform state
├── terraform.tfvars       # Variable values
├── modules
│   ├── vpc
│   │   ├── main.tf        # VPC, subnets, firewall, router, NAT
│   │   ├── variables.tf   # VPC module variables
│   │   ├── outputs.tf     # VPC module outputs
│   ├── gke
│   │   ├── main.tf        # GKE cluster and node pool
│   │   ├── variables.tf   # GKE module variables
│   │   ├── outputs.tf     # GKE module outputs
│   ├── iam
│   │   ├── main.tf        # Service account and IAM roles
│   │   ├── variables.tf   # IAM module variables
│   │   ├── outputs.tf     # IAM module outputs
│   ├── bastion
│   │   ├── main.tf        # Bastion host configuration
│   │   ├── variables.tf   # Bastion module variables
│   │   ├── outputs.tf     # Bastion module outputs

Modules





VPC Module:





Creates a custom VPC (test-vpc) with public and private subnets.



Configures firewall rules to allow HTTP, HTTPS, SSH, ICMP, and ports 1000-2000.



Sets up a cloud router and NAT gateway for private subnet egress.



GKE Module:





Deploys a private GKE cluster (democluster) with private nodes.



Configures a single node pool with preemptible e2-medium instances.



Restricts master access to the bastion host's public IP.



IAM Module:





Creates a service account (test-automation-user) with roles:





roles/storage.admin



roles/artifactregistry.reader



roles/compute.admin



roles/container.admin



Bastion Module:





Deploys a bastion host (bastion-vm-gke) in the public subnet.



Installs kubectl, gcloud, and ArgoCD via a startup script.



Configures ArgoCD with a LoadBalancer service.

Setup Instructions





Clone the Repository:

git clone https://github.com/justShamik/GKE3TierTerra.git
cd GKE3TierTerra



Configure Variables:





Update terraform.tfvars with your GCP project details:



Set Up Authentication:





Place your service account key file in the project directory.



Set the GOOGLE_CREDENTIALS environment variable:

export GOOGLE_CREDENTIALS=$(cat path/to/your-service-account-key.json)



Initialize Terraform:

terraform init



Plan and Apply:

terraform plan -out=tfplan
terraform apply tfplan

Usage





Access the GKE Cluster:





SSH into the bastion host to interact with the GKE cluster:

gcloud compute ssh bastion-vm-gke --zone us-central1-a --project your-project-id



Use kubectl on the bastion to manage the cluster.



ArgoCD:





The bastion host automatically installs ArgoCD and exposes it as a LoadBalancer.



Get the ArgoCD service IP:

kubectl get svc argocd-server -n argocd



Access the ArgoCD UI using the external IP.

Outputs





vpc_id: ID of the created VPC.



gke_cluster_endpoint: Endpoint of the GKE cluster.



service_account_email: Email of the service account.



bastion_nat_ip: Public IP of the bastion host.

Notes





Service Account Key: Ensure the key file specified in terraform.tfvars has sufficient permissions.



ArgoCD: The startup script patches ArgoCD to use a LoadBalancer. Verify the service is accessible.



Extensions: To add a GCP load balancer or Helm deployments, create additional modules or extend the bastion startup script.



Testing: Test in a non-production environment first to validate the configuration.

For issues or enhancements, open a pull request or issue on the repository.

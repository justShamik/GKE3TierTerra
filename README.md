# 🚀 GKE 3-Tier Infrastructure with Terraform

This project deploys a **3-tier architecture** on **Google Cloud Platform (GCP)** using **Terraform**. It provisions:

* A custom VPC with public/private subnets and firewall rules
* A private GKE cluster with restricted access
* A service account with necessary IAM roles
* A bastion host for secure access and GitOps (via ArgoCD)

---

## 📚 Table of Contents

* [Overview](#overview)
* [Prerequisites](#prerequisites)
* [Directory Structure](#directory-structure)
* [Modules](#modules)
* [Setup Instructions](#setup-instructions)
* [Usage](#usage)
* [Outputs](#outputs)
* [Notes](#notes)

---

## 🧭 Overview

### Infrastructure Components

* **VPC**: Custom network with public and private subnets, firewall rules, and NAT gateway for egress.
* **GKE Cluster**: Private cluster with one node pool, restricted to bastion access.
* **IAM**: Service account with required GCP permissions.
* **Bastion Host**: Public VM with `kubectl`, `gcloud`, and ArgoCD installed.

---

## ✅ Prerequisites

* **GCP Account**: Billing-enabled project
* **Terraform**: Version 1.5 or higher
* **Service Account Key**: JSON key file with permissions to manage GCP resources
* **GCS Bucket**: For storing Terraform state (e.g., `shamiktestbucket`)
* **gcloud CLI** *(optional)*: For manual GKE interaction

---

## 🗂️ Directory Structure

```
.
├── main.tf                # Root Terraform config
├── variables.tf           # Input variables
├── outputs.tf             # Output values
├── provider.tf            # GCP provider config
├── backend.tf             # GCS backend config
├── terraform.tfvars       # Variable values
├── modules
│   ├── vpc
│   │   ├── main.tf        # VPC, subnets, firewall, NAT
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── gke
│   │   ├── main.tf        # GKE cluster and node pool
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam
│   │   ├── main.tf        # Service account and roles
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── bastion
│       ├── main.tf        # Bastion host and ArgoCD
│       ├── variables.tf
│       └── outputs.tf
```

---

## 📦 Modules

### 🔹 VPC Module

* Creates `test-vpc` with public/private subnets
* Adds firewall rules (HTTP, HTTPS, SSH, ICMP, ports 1000-2000)
* Sets up Cloud Router and NAT for egress

### 🔹 GKE Module

* Deploys private cluster `democluster`
* Single node pool (preemptible `e2-medium` instances)
* Master access restricted to bastion public IP

### 🔹 IAM Module

* Creates service account `test-automation-user`
* Grants roles:

  * `roles/storage.admin`
  * `roles/artifactregistry.reader`
  * `roles/compute.admin`
  * `roles/container.admin`

### 🔹 Bastion Module

* Deploys `bastion-vm-gke` in public subnet
* Installs:

  * `kubectl`
  * `gcloud`
  * **ArgoCD** (via startup script with LoadBalancer)

---

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/justShamik/GKE3TierTerra.git
cd GKE3TierTerra
```

### 2. Configure Variables

Edit `terraform.tfvars` with your GCP project settings.

### 3. Set Up Authentication

Place your service account key JSON in the root directory. Then run:

```bash
export GOOGLE_CREDENTIALS=$(cat path/to/your-service-account-key.json)
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Plan and Apply

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

---

## 🛠️ Usage

### Access the GKE Cluster

1. SSH into the bastion:

```bash
gcloud compute ssh bastion-vm-gke --zone us-central1-a --project <your-project-id>
```

2. Use `kubectl` from the bastion to manage the cluster.

### Access ArgoCD

1. Get ArgoCD service external IP:

```bash
kubectl get svc argocd-server -n argocd
```

2. Visit the external IP in your browser to open the ArgoCD UI.

---

## 📤 Outputs

| Output Name             | Description                   |
| ----------------------- | ----------------------------- |
| `vpc_id`                | ID of the created VPC         |
| `gke_cluster_endpoint`  | Endpoint of the GKE cluster   |
| `service_account_email` | Email of the service account  |
| `bastion_nat_ip`        | Public IP of the bastion host |

---

## 📝 Notes

* **Service Account Key**: Ensure it has sufficient permissions (as outlined above).
* **ArgoCD**: The startup script patches the service to use a LoadBalancer.

---

📬 For issues or enhancements, feel free to open an [issue](https://github.com/justShamik/GKE3TierTerra/issues) or a [pull request](https://github.com/justShamik/GKE3TierTerra/pulls).


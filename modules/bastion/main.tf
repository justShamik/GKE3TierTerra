# modules/bastion/main.tf
# Configures the bastion host with startup script for tooling and ArgoCD.

# Create a bastion host for cluster access
resource "google_compute_instance" "bastion" {
  name         = "bastion-vm-gke"                   # Bastion host name
  machine_type = "e2-standard-2"                   # Machine type
  zone         = var.node_zone                     # GCP zone
  project      = var.project_name                  # GCP project ID
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"             # Debian 11 image
    }
  }
  network_interface {
    network    = var.vpc_name                      # VPC name from variable
    subnetwork = var.public_subnet_self_link       # Public subnet self_link from variable
    access_config {}                               # Assign public IP
  }
  tags = ["bastion"]                               # Network tag for firewall
  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Configure DNS
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
    # Install dependencies
    sudo apt-get update -y
    sudo apt-get install -y curl apt-transport-https ca-certificates gnupg lsb-release gnupg2 unzip
    # Install kubectl
    sudo apt-get update
    sudo apt-get install kubectl
    # Install GKE auth plugin
    sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
    # Install Google Cloud SDK
    echo "Installing Google Cloud SDK..."
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo apt-get update -y && sudo apt-get install -y google-cloud-sdk
    # Configure gcloud
    gcloud config set project ${var.project_name}
    gcloud container clusters get-credentials democluster --region ${var.region} --project ${var.project_name}
    # Install ArgoCD
    kubectl create namespace argocd || true
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
  EOT
}
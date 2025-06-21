# ===============================
# Service Account
# ===============================
resource "google_service_account" "test-automation-user" {
  account_id   = var.project_name
  project      = var.project_name
  display_name = "Test Automation User Service Account"
}

#Binding service account with the storage admin role
resource "google_project_iam_binding" "storage-admin" {
  depends_on = [google_service_account.test-automation-user]
  project    = var.project_name
  role       = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.test-automation-user.email}"
  ]
}

#Binding service account with the compute role
resource "google_project_iam_binding" "compute-admin" {
  depends_on = [google_service_account.test-automation-user]
  project    = var.project_name
  role       = "roles/compute.admin"
  members = [
    "serviceAccount:${google_service_account.test-automation-user.email}"
  ]
}

#Binding service account with the Container admin role
resource "google_project_iam_binding" "container-admin" {
  depends_on = [google_service_account.test-automation-user]
  project    = var.project_name
  role       = "roles/container.admin"
  members = [
    "serviceAccount:${google_service_account.test-automation-user.email}"
  ]
}

# ===============================
# VPC and Subnets
# ===============================
resource "google_compute_network" "test-vpc" {
  name                            = "test-vpc"
  delete_default_routes_on_create = false
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  project                         = var.project_name
}

# SUBNETS
resource "google_compute_subnetwork" "test-vpc_public" {
  name                     = "subnetwork-test-vpc-public"
  ip_cidr_range            = var.public_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.test-vpc.id
  private_ip_google_access = false
  project                  = var.project_name
  depends_on               = [google_compute_network.test-vpc]
}
resource "google_compute_subnetwork" "test-vpc_private" {
  name                     = "subnetwork-test-vpc-private"
  ip_cidr_range            = var.private_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.test-vpc.id
  project                  = var.project_name
  private_ip_google_access = true
  depends_on               = [google_compute_network.test-vpc]
  # secondary_ip_range = {
  #   cluster_secondary_range_name = "pods"
  #   services_secondary_range_name = "service"
  #   ip_cidr_range = "10.20.20.0/24"
  # }
}

# ===============================
# Firewall
# ===============================
resource "google_compute_firewall" "default" {
  name    = "default-firewall"
  network = google_compute_network.test-vpc.id
  project = var.project_name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000", "22", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# ===============================
# NAT Gateway
# ===============================
resource "google_compute_router" "test-vpc" {
  name    = "testvpc-router"
  region  = var.region
  project = var.project_name
  #  region  = google_compute_subnetwork.test-vpc_private.region
  network = google_compute_network.test-vpc.id
}

resource "google_compute_router_nat" "test-vpc" {
  name                               = "devops-router-nat"
  project                            = var.project_name
  router                             = google_compute_router.test-vpc.name
  region                             = google_compute_router.test-vpc.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.test-vpc_private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}


# ===============================
# GKE Cluster
# ===============================
resource "google_container_cluster" "democluster" {
  name     = "democluster"
  location = var.region
  project  = var.project_name
  # network = google_compute_network.test-vpc.id
  network    = google_compute_network.test-vpc.name
  subnetwork = google_compute_subnetwork.test-vpc_private.name

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  node_config {
    service_account = google_service_account.test-automation-user.email
  }
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_cluster_cidr
  }
  master_authorized_networks_config {

    cidr_blocks {
      cidr_block = format("%s/32", google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip)
    }
  }
  depends_on = [google_service_account.test-automation-user]
}

# ===============================
# GKE Node Pool
# ===============================
resource "google_container_node_pool" "master" {
  name     = "master"
  project  = var.project_name
  location = var.region

  cluster    = google_container_cluster.democluster.name
  node_count = 1
  node_locations = [
    var.node_zone
  ]
  # when you set just the region (us-central1) you are creating a regional cluster in 3 zones.
  #  The initial_node_count field is per zone. So even if you set it to 1, you are getting 1 per 
  # zone. Adding node_locations turns the cluster into a zonal one
  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.test-automation-user.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  depends_on = [google_service_account.test-automation-user]
}



# ===============================
# Bastion Host
# ===============================
resource "google_compute_instance" "bastion" {
  name         = "bastion-vm-gke"
  machine_type = "e2-standard-2"
  zone         = var.node_zone
  project      = var.project_name
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.test-vpc.self_link
    subnetwork = google_compute_subnetwork.test-vpc_public.self_link
    access_config {

    }
  }
  tags                    = ["bastion"]
  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y curl apt-transport-https ca-certificates gnupg lsb-release gnupg2 unzip

    # Kubectl install
    sudo apt-get update
    sudo apt-get install kubectl
    sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

    # Install gcloud CLI
    echo "Installing Google Cloud SDK..."
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo apt-get update -y && sudo apt-get install -y google-cloud-sdk

    # Authenticate and configure gcloud CLI
    gcloud config set project ${var.project_name}
    gcloud container clusters get-credentials democluster --region ${var.region} --project ${var.project_name}

    # Install ArgoCD in Kubernetes
    kubectl create namespace argocd || true
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
  EOT
}

# Use local provisioners or remote provisioners

# create a service account in gke to create a LB

# deploy helm in gke

# GCP Loadbalancer

# ArgoCD
# modules/gke/main.tf
resource "google_container_cluster" "democluster" {
  name                     = "democluster"
  location                 = var.region
  project                  = var.project_name
  network                  = var.vpc_name
  subnetwork               = var.private_subnet_name
  deletion_protection      = false
  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    service_account = var.service_account_email
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_cluster_cidr
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "${var.bastion_ip}/32"
    }
  }

  depends_on = [var.service_account_email]
}

resource "google_container_node_pool" "master" {
  name           = "master"
  project        = var.project_name
  location       = var.region
  cluster        = google_container_cluster.democluster.name
  node_count     = 1
  node_locations = [var.node_zone]

  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = var.service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  depends_on = [var.service_account_email]
}
# modules/vpc/main.tf
resource "google_compute_network" "test-vpc" {
  name                            = "test-vpc"
  project                         = var.project_name
  delete_default_routes_on_create = false
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
}

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
}

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

resource "google_compute_router" "test-vpc" {
  name    = "testvpc-router"
  region  = var.region
  project = var.project_name
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
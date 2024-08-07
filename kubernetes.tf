# Terraform code for GKE Kubernetes cluster and node pool

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.gke_cluster.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

resource "google_container_cluster" "gke_cluster" {
  project = var.gcp_project

  // Ignore gcp_zone_list and set to single Zone to bypass Region SSD_TOTAL_GB quota
  // location                 = var.gcp_zone_list

  location   = var.gcp_zone
  name       = var.gke_cluster
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet0.name
  // For use with Google Private Service Connect (PSC)
  // network    = google_compute_network.private_network.name
  // subnetwork = google_compute_subnetwork.private_subnetwork.name
  remove_default_node_pool = true
  initial_node_count       = 2
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  deletion_protection = false
}

resource "google_container_node_pool" "primary_preemptible_nodes" {

  // Ignore gcp_zone_list and set to single Zone to bypass Region SSD_TOTAL_GB quota
  // location   = var.gcp_zone_list

  location   = var.gcp_zone
  cluster    = google_container_cluster.gke_cluster.name
  name       = "node-pool-0"
  node_count = 1
  node_config {
    preemptible  = true
    disk_size_gb = 50
    machine_type = var.gke_vm_type
    metadata = {
      disable-legacy-endpoints = false
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

// For use with Google Private Service Connect (PSC)
// resource "google_compute_subnetwork" "private_subnetwork" {
// name          = "your-subnetwork-name"
// ip_cidr_range = "10.2.0.0/16"
// region        = "us-central1"
// network       = google_compute_network.private_network.id
// private_ip_google_access = true
// }

// resource "google_compute_global_address" "private_ip_address" {
// name          = "your-ip-address-name"
// purpose       = "VPC_PEERING"
// address_type  = "INTERNAL"
// prefix_length = 16
// network       = google_compute_network.private_network.id
// }

// resource "google_service_networking_connection" "private_vpc_connection" {
// network                 = google_compute_network.private_network.id
// service                 = "servicenetworking.googleapis.com"
// reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
// }

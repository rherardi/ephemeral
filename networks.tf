# Terraform code for networks, subnets, and firewall rules

# Create VPC
resource "google_compute_network" "vpc" {
  name                    = var.gcp_vpc_name
  project                 = var.gcp_project
  description             = "VPC"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# Create Subnets
resource "google_compute_subnetwork" "subnet0" {
  name                     = "subnet0"
  ip_cidr_range            = "10.10.1.0/24"
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

# Create firewall rules
module "firewall_rules" {
  source = "terraform-google-modules/network/google//modules/firewall-rules"

  project_id   = var.gcp_project
  network_name = google_compute_network.vpc.name

  rules = [
    {
      name               = "allow-http-lb-ingress"
      direction          = "INGRESS"
      priority           = null
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = ["10.10.1.2"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["80"]
        }
      ]
      description = "Inbound HTTP"
    },
    {
      name               = "allow-https-ingress-to-lb"
      direction          = "INGRESS"
      priority           = null
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = ["10.10.1.2"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["443"]
        }
      ]
      description = "Inbound HTTPS"
    },
    {
      name      = "allow-sql-from-gke"
      direction = "INGRESS"
      priority  = null

      //      source_ranges      = [google_container_cluster.gke_cluster.network]
      //      destination_ranges = [google_sql_database_instance.db_instance.private_ip_address]
      //      source_ranges      = ["0.0.0.0/0"]

      source_ranges      = ["10.10.1.2"]
      destination_ranges = ["34.132.192.160"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["3306"]
        }
      ]
      description = "Allow SQL traffic from GKE cluster"
    },
    {
      name      = "allow-sql-to-gke"
      direction = "INGRESS"
      priority  = null

      //      source_ranges      = [google_container_cluster.gke_cluster.network]
      //      destination_ranges = [google_sql_database_instance.db_instance.private_ip_address]
      //      source_ranges      = ["0.0.0.0/0"]

      source_ranges      = ["34.132.192.160"]
      destination_ranges = ["10.10.1.2"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["3306"]
        }
      ]
      description = "Allow MySQL traffic to GKE cluster"
    },
  ]
}

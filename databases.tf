# Terraform code for database clusters (back-end subnet)

resource "google_sql_database" "clprimary" {
  name     = "mysql-cluster"
  instance = google_sql_database_instance.db_instance.name
}

resource "google_sql_database_instance" "db_instance" {
  project          = var.gcp_project
  region           = var.gcp_region
  name             = "mysql-database"
  database_version = "MYSQL_5_7"
  settings {
    tier              = "db-f1-micro"
    disk_size         = 10
    disk_type         = "PD_SSD"
    availability_type = "ZONAL"
    ip_configuration {
      ipv4_enabled = true
      // Wide open ***FOR TROUBLESHOOTING ONLY***
      // Note: This requires policy "sql.restrictAuthorizedNetwork" to be disabled for the project.
      authorized_networks {
        name  = "tfpgv2-vpc"
        value = "0.0.0.0/0"
      }
      // For use with Google Privarte Service Connect (PSC)
      // private_network = google_compute_network.vpc.self_link
    }
  }
  deletion_protection = false
}

resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.db_instance.name
  password = var.db_password
}

# Output relevant information (for debug) about the database instance
output "database_name" {
  value = google_sql_database.clprimary.name
}
output "connection_name" {
  value = google_sql_database_instance.db_instance.connection_name
}
output "db_public_ip" {
  value = google_sql_database_instance.db_instance.public_ip_address
}
output "db_private_ip" {
  value = google_sql_database_instance.db_instance.private_ip_address
}

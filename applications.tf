# Terraform code to deploy WordPress on GKE cluster

# PVC for WordPress files
resource "kubernetes_persistent_volume_claim" "gke_pvc0" {
  metadata {
    name = "gke-pvc0"
    labels = {
      env = "US"
    }
  }
  wait_until_bound = true
  timeouts {
    create = "10m"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "standard"
  }
  depends_on = [
    google_container_cluster.gke_cluster,
    google_container_node_pool.primary_preemptible_nodes
  ]
}

# Create WordPress Deployment
resource "kubernetes_deployment" "wp_dep" {
  metadata {
    name = "wp-dep"
    labels = {
      env = "US"
    }
  }
  depends_on = [
    kubernetes_persistent_volume_claim.gke_pvc0,
    google_sql_database_instance.db_instance,
    google_sql_database.clprimary
  ]
  wait_for_rollout = true
  spec {
    replicas = 2
    selector {
      match_labels = {
        pod = "wp-dep"
        env = "US"
      }
    }
    template {
      metadata {
        labels = {
          pod = "wp-dep"
          env = "US"
        }
      }
      spec {
        volume {
          name = "pvc0-vol"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.gke_pvc0.metadata[0].name
          }
        }

        container {
          image = "wordpress:latest"
          name  = "wp-container"
          env {
            name = "WORDPRESS_DB_HOST"
            // For use with Google Private Service Connect (PSC)
            // value = "${google_sql_database_instance.db_instance.private_ip_address}:3306"
            // For use with standard IPv4
            value = "${google_sql_database_instance.db_instance.public_ip_address}:3306"
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value = "root"
          }
          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = var.db_password
          }
          env {
            name  = "WORDPRESS_DB_NAME"
            value = google_sql_database.clprimary.name
          }
          env {
            name  = "WORDPRESS_TABLE_PREFIX"
            value = "wp_"
          }
          volume_mount {
            name       = "pvc0-vol"
            mount_path = "/var/www/html/"
          }
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "google_compute_address" "static_ip" {
  name   = "static-ip-address"
  region = var.gcp_region
}

resource "kubernetes_service" "wp-lb-svc" {
  metadata {
    name = "wp-svc"
    labels = {
      env = "US"
    }
  }
  depends_on = [
    kubernetes_deployment.wp_dep
  ]
  spec {
    type = "LoadBalancer"
    selector = {
      pod = "wp-dep"
    }
    port {
      name = "wp-port"
      port = 80
    }
    load_balancer_ip = google_compute_address.static_ip.address
  }
}

# Terraform provider configuration

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

// Kubernetes provider configuration is located in file "kubernetes.tf"

# Store Terraform state in cloud storage bucket (for shared state)

terraform {
  backend "gcs" {
    bucket = "gke_tf_state"
    prefix = "terraform/state"
  }
}

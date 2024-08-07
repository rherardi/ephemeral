# Terraform variable definitions (for all ".tf" files)

variable "db_password" {
  type        = string
  description = "DB root password"
}
variable "db_user" {
  type        = string
  description = "DB root user"
}
variable "gcp_project" {
  type        = string
  description = "GCP Project ID"
}
variable "gcp_region" {
  type        = string
  description = "GCP Region"
}
variable "gcp_sa" {
  type        = string
  description = "GCP Service account"
}
variable "gcp_vpc_name" {
  type        = string
  description = "VPC network"
}
variable "gcp_zone" {
  type        = string
  description = "GCP Zone (primary)"
}
variable "gcp_zone_list" {
  type        = list(any)
  description = "GCP Zone list"
}
variable "gke_cluster" {
  type        = string
  description = "GKE cluster name"
}
variable "gke_vm_type" {
  type        = string
  description = "Machine type for GKE node pool"
}

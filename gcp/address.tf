resource "google_compute_address" "kube_api" {
  name    = var.network_name
  project = var.project
  region  = var.region
}

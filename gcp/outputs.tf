output "external_ip" {
  value = google_compute_address.kube_api.address
}

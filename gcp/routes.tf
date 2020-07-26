# from https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/11-pod-network-routes.md
resource google_compute_route "pods" {
  count = var.worker_count
  name  = "pods-route-worker-${count.index}"
  network = google_compute_network.default.id
  next_hop_ip = "10.240.0.2${count.index}"
  dest_range  = "10.200.${count.index}.0/24"
  depends_on = [
    google_compute_subnetwork.default
  ]
}

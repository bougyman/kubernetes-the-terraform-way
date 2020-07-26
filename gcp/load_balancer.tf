# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/08-bootstrapping-kubernetes-controllers.md#enable-http-health-checks

resource "google_compute_http_health_check" "http_health_check" {
  name        = "kubernetes"
  description = "Kubernetes health check"

  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5

  port         = "80"
  host         = "kubernetes.default.svc.cluster.local"
  request_path = "/healthz"
}

# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/08-bootstrapping-kubernetes-controllers.md#provision-a-network-load-balancer
resource "google_compute_firewall" "http_health_check" {
  name    = "http-health-check"
  network = google_compute_network.default.name
  allow {
    protocol = "tcp"
    ports    = ["80", "6443"]
  }
  source_ranges = [
    "209.85.152.0/22",
    "209.85.204.0/22",
    "35.191.0.0/16"
  ]
}

resource "google_compute_target_pool" "kubernetes" {
  name      = "kubernetes"
  instances = google_compute_instance.controller.*.self_link
  health_checks = [
    google_compute_http_health_check.http_health_check.name
  ]
}

resource "google_compute_forwarding_rule" "kubernetes" {
  name        = "kubernetes"
  target      = google_compute_target_pool.kubernetes.id
  port_range  = "6443"
  ip_protocol = "TCP"
  ip_address  = google_compute_address.kube_api.address
}

# Bootstrapping worker nodes happens in worker-provisioner.tf

resource "google_compute_firewall" "internal" {
  direction      = "INGRESS"
  disabled       = false
  enable_logging = false
  name           = "${var.network_name}-allow-internal"
  network        = google_compute_network.default.id
  priority       = 1000
  project        = var.project
  source_ranges = [
    "10.200.0.0/16",
    "10.240.0.0/24",
  ]

  allow {
    ports    = []
    protocol = "icmp"
  }
  allow {
    ports    = []
    protocol = "tcp"
  }
  allow {
    ports    = []
    protocol = "udp"
  }

  timeouts {}
}

resource "google_compute_firewall" "external" {
  direction      = "INGRESS"
  disabled       = false
  enable_logging = false
  name           = "${var.network_name}-allow-external"
  network        = google_compute_network.default.id
  priority       = 1000
  project        = var.project

  source_ranges = [
    "0.0.0.0/0",
  ]

  allow {
    ports = [
      "22",
    ]
    protocol = "tcp"
  }

  allow {
    ports = [
      "6443",
    ]
    protocol = "tcp"
  }

  allow {
    ports    = []
    protocol = "icmp"
  }

  timeouts {}
}

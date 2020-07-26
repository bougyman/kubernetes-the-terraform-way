# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md#firewall-rules

# Create the internal firewall rules to allow comunication of all cluster members
# From k-t-h-w lab
# gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
#    --allow tcp,udp,icmp \
#    --network kubernetes-the-hard-way \
#    --source-ranges 10.240.0.0/24,10.200.0.0/16
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

# Create the external firewall rules to allow comunication from the outside for ssh and the kubernetes API
# From k-t-h-w lab
# gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
#    --allow tcp:22,tcp:6443,icmp \
#    --network kubernetes-the-hard-way \
#    --source-ranges 0.0.0.0/0
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

# Lab continues in address.tf

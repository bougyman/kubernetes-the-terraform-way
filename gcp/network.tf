# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md

# This creates our network. var.network_name is set in vars.auto.tfvars
# From the k-t-h-w lab
# `gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom`
resource "google_compute_network" "default" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# This creates our subnetwork. var.subnetwork_name is set in vars.auto.tfvars
# From the k-t-h-w lab
# `gcloud compute networks subnets create kubernetes \
#    --network kubernetes-the-hard-way \
#    --range 10.240.0.0/24`
resource "google_compute_subnetwork" "default" {
  name          = var.subnetwork_name
  ip_cidr_range = "10.240.0.0/24"
  region        = var.region
  network       = google_compute_network.default.id
}

# Next part of the lab continues in firewall.tf

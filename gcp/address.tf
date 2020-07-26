# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md#kubernetes-public-ip-address

# The public address for the cluster
# From k-t-h-w lab
# gcloud compute addresses create kubernetes-the-hard-way \
#  --region $(gcloud config get-value compute/region)
resource "google_compute_address" "kube_api" {
  name    = var.network_name
  project = var.project
  region  = var.region
}

# Lab continues in instances.tf

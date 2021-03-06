variable "network_name" {
  description = "The name of the network"
}

variable "subnetwork_name" {
  description = "The name of the network"
}

variable "project" {
  description = "The gcloud project name"
}

variable "region" {
  description = "The gcloud region"
  default     = "us-central1"
}

variable "worker_count" {
  description = "How many workers"
  default     = 3
}

variable "controller_count" {
  description = "How many controllers"
  default     = 3
}

variable "username" {
  description = "The username to use for connections. Generally this is your local box's current username"
}

variable "credentials_path" {
  description = "Path to gcp credentials"
  default     = "account.json"
}

variable "service_account_email" {
  description = "The service account email address used for IAM authentication. Find in the IAM tab of your project"
}

provider "google" {
  credentials = file(var.credentials_path)
  project     = var.project
  region      = "us-central1"
  zone        = "us-central1-c"
}

provider "google" {
  credentials = file("account.json")
  project     = "rubyists-kube-sandbox"
  region      = "us-central1"
  zone        = "us-central1-c"
}

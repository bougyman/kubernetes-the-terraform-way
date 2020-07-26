# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md#compute-instances


# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md#kubernetes-controllers
# Creates all of the controller instances. To match k-t-h-w, var.controller count defaults to 3
resource "google_compute_instance" "controller" {
  count               = var.controller_count
  can_ip_forward      = true
  deletion_protection = false
  enable_display      = false
  guest_accelerator   = []
  labels              = {}
  machine_type        = "e2-standard-2"
  metadata            = {}
  name                = "controller-${count.index}"
  project             = var.project
  resource_policies   = []
  tags = [
    "controller",
    "kubernetes-the-hard-way",
  ]
  zone = "us-central1-c"

  boot_disk {
    auto_delete = true
    mode        = "READ_WRITE"

    initialize_params {
      image  = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20200716"
      labels = {}
      size   = 200
      type   = "pd-standard"
    }
  }

  network_interface {
    network            = google_compute_network.default.id
    subnetwork         = google_compute_subnetwork.default.id
    subnetwork_project = var.project
    network_ip         = "10.240.0.1${count.index}"

    access_config {
      network_tier = "PREMIUM"
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  service_account {
    email = "421880274612-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  timeouts {}
}

# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md#kubernetes-workers
# Creates all of the worker instances. To match k-t-h-w, var.worker_count defaults to 3
resource "google_compute_instance" "worker" {
  count               = var.worker_count
  can_ip_forward      = true
  deletion_protection = false
  enable_display      = false
  guest_accelerator   = []
  labels              = {}
  machine_type        = "e2-standard-2"
  metadata            = { "pod-cidr" = "10.200.${count.index}.0/24" }
  name                = "worker-${count.index}"
  project             = "rubyists-kube-sandbox"
  resource_policies   = []
  tags = [
    "worker",
    "kubernetes-the-hard-way",
  ]
  zone = "us-central1-c"

  boot_disk {
    auto_delete = true
    mode        = "READ_WRITE"

    initialize_params {
      image  = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20200716"
      labels = {}
      size   = 200
      type   = "pd-standard"
    }
  }

  network_interface {
    network            = google_compute_network.default.id
    subnetwork         = google_compute_subnetwork.default.id
    subnetwork_project = var.project
    network_ip         = "10.240.0.2${count.index}"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  service_account {
    email = "421880274612-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  timeouts {}
}

# Verify as per https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md#verification
# Lab continues in ssl-provisioner.tf

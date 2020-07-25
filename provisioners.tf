resource "null_resource" "ssl" {
  triggers = {
    address = google_compute_address.kube_api.address
  }
  provisioner "local-exec" {
    command = "ssl_scripts/ca.sh"
  }
  provisioner "local-exec" {
    command = "ssl_scripts/admin.sh"
  }
  provisioner "local-exec" {
    command = "ssl_scripts/service-account.sh"
  }
  provisioner "local-exec" {
    command = "ssl_scripts/controller-manager.sh"
  }
  provisioner "local-exec" {
    command = "ssl_scripts/kube-proxy.sh"
  }
  provisioner "local-exec" {
    command = "ssl_scripts/scheduler.sh"
  }
}

resource "null_resource" "api_ssl" {
  triggers = {
    address     = null_resource.ssl.triggers.address
    controllers = join(",", google_compute_instance.controller.*.network_interface.0.network_ip)
  }
  provisioner "local-exec" {
    command = "ssl_scripts/api-server.sh"
    environment = {
      KUBERNETES_PUBLIC_ADDRESS = self.triggers.address
      CONTROLLER_IPS            = self.triggers.controllers
    }
  }
}

resource "null_resource" "controllers" {
  count = var.controller_count
  triggers = {
    address = null_resource.api_ssl.triggers.address
    username    = var.username
    external_ip = google_compute_instance.controller[count.index].network_interface.0.access_config.0.nat_ip
  }
  connection {
    host = self.triggers.external_ip
    user = self.triggers.username
  }
  provisioner "file" {
    source = "ssl/ca.pem"
    destination = "~/ca.pem"
  }
  provisioner "file" {
    source = "ssl/service-account.pem"
    destination = "~/service-account.pem"
  }
  provisioner "file" {
    source = "ssl/service-account-key.pem"
    destination = "~/service-account-key.pem"
  }
  provisioner "file" {
    source = "ssl/kubernetes.pem"
    destination = "~/kubernetes.pem"
  }
  provisioner "file" {
    source = "ssl/kubernetes-key.pem"
    destination = "~/kubernetes-key.pem"
  }
}

resource "null_resource" "workers" {
  count = var.worker_count
  triggers = {
    address = null_resource.ssl.triggers.address
    name = google_compute_instance.worker[count.index].name
    internal_ip = google_compute_instance.worker[count.index].network_interface.0.network_ip
    external_ip = google_compute_instance.worker[count.index].network_interface.0.access_config.0.nat_ip
    username    = var.username
  }
  provisioner "local-exec" {
    environment = {
      EXTERNAL_IP = self.triggers.external_ip
      INTERNAL_IP = self.triggers.internal_ip
      instance    = self.triggers.name
    }
    command = "ssl_scripts/worker.sh"
  }
  connection {
    host = self.triggers.external_ip
    user = self.triggers.username
  }
  provisioner "file" {
    source = "ssl/ca.pem"
    destination = "~/ca.pem"
  }
  provisioner "file" {
    source = "ssl/${self.triggers.name}.pem"
    destination = "~/${self.triggers.name}.pem"
  }
  provisioner "file" {
    source = "ssl/${self.triggers.name}-key.pem"
    destination = "~/${self.triggers.name}-key.pem"
  }
}


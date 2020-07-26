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

resource "null_resource" "kube_configs" {
  triggers = {
    address = google_compute_address.kube_api.address
  }
  provisioner "local-exec" {
    command = "kube_scripts/kube-proxy.sh"
    environment = {
      KUBERNETES_PUBLIC_ADDRESS = self.triggers.address
    }
  }
  provisioner "local-exec" {
    command = "kube_scripts/admin.sh"
  }
  provisioner "local-exec" {
    command = "kube_scripts/scheduler.sh"
  }
  provisioner "local-exec" {
    command = "kube_scripts/kube-controller-manager.sh"
  }
  provisioner "local-exec" {
    command = "kube_scripts/encryption.sh"
  }
}

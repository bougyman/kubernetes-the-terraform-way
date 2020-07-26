resource "null_resource" "controllers" {
  count = var.controller_count
  triggers = {
    address     = null_resource.api_ssl.triggers.address
    username    = var.username
    external_ip = google_compute_instance.controller[count.index].network_interface.0.access_config.0.nat_ip
  }
  connection {
    host = self.triggers.external_ip
    user = self.triggers.username
  }
  provisioner "file" {
    source      = "ssl/ca.pem"
    destination = "~/ca.pem"
  }
  provisioner "file" {
    source      = "ssl/service-account.pem"
    destination = "~/service-account.pem"
  }
  provisioner "file" {
    source      = "ssl/service-account-key.pem"
    destination = "~/service-account-key.pem"
  }
  provisioner "file" {
    source      = "ssl/kubernetes.pem"
    destination = "~/kubernetes.pem"
  }
  provisioner "file" {
    source      = "ssl/kubernetes-key.pem"
    destination = "~/kubernetes-key.pem"
  }
  provisioner "file" {
    source      = "kube_configs/admin.kubeconfig"
    destination = "~/admin.kubeconfig"
  }
  provisioner "file" {
    source      = "kube_configs/kube-controller-manager.kubeconfig"
    destination = "~/kube-controller-manager.kubeconfig"
  }
  provisioner "file" {
    source      = "kube_configs/kube-scheduler.kubeconfig"
    destination = "~/kube-scheduler.kubeconfig"
  }
  provisioner "file" {
    source      = "kube_configs/encryption-config.yaml"
    destination = "~/encryption-config.yaml"
  }
  provisioner "remote-exec" {
    scripts = [
      "kube_scripts/etcd_bootstrap.sh",
      "kube_scripts/kubernetes_bootstrap.sh"
    ]
  }
}

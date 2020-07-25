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

resource "null_resource" "workers" {
  count = var.worker_count
  triggers = {
    address     = null_resource.ssl.triggers.address
    name        = google_compute_instance.worker[count.index].name
    internal_ip = google_compute_instance.worker[count.index].network_interface.0.network_ip
    external_ip = google_compute_instance.worker[count.index].network_interface.0.access_config.0.nat_ip
    username    = var.username
    controllers = null_resource.contollers.triggers.controllers[count.index].external_ip
  }
  provisioner "local-exec" {
    environment = {
      EXTERNAL_IP = self.triggers.external_ip
      INTERNAL_IP = self.triggers.internal_ip
      instance    = self.triggers.name
    }
    command = "ssl_scripts/worker.sh"
  }
  provisioner "local-exec" {
    environment = {
      KUBERNETES_PUBLIC_ADDRESS = self.triggers.address
      instance                  = self.triggers.name
    }
    command = "kube_scripts/worker.sh"
  }
  connection {
    host = self.triggers.external_ip
    user = self.triggers.username
  }
  provisioner "file" {
    source      = "kube_configs/${self.triggers.name}.kubeconfig"
    destination = "~/${self.triggers.name}.kubeconfig"
  }
  provisioner "file" {
    source      = "kube_configs/kube-proxy.kubeconfig"
    destination = "~/kube-proxy.kubeconfig"
  }
  provisioner "file" {
    source      = "ssl/ca.pem"
    destination = "~/ca.pem"
  }
  provisioner "file" {
    source      = "ssl/${self.triggers.name}.pem"
    destination = "~/${self.triggers.name}.pem"
  }
  provisioner "file" {
    source      = "ssl/${self.triggers.name}-key.pem"
    destination = "~/${self.triggers.name}-key.pem"
  }
  provisioner "remote-exec" {
    scripts = [
      "kube_scripts/worker_bootstrap.sh"
    ]
  }
}

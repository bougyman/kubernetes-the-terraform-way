# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md#the-kubelet-kubernetes-configuration-file
# This builds the workers individual kubeconfig files
resource "null_resource" "worker_kube_config" {
  triggers = {
    instances = join(" ", google_compute_instance.worker.*.name)
    address     = null_resource.ssl.triggers.address
    internal_ips = join(" ", google_compute_instance.worker.*.network_interface.0.network_ip)
    external_ips = join(" ", google_compute_instance.worker.*.network_interface.0.access_config.0.nat_ip)
  }
  provisioner "local-exec" {
    environment = {
      EXTERNAL_IPS = self.triggers.external_ips
      INTERNAL_IPS = self.triggers.internal_ips
      INSTANCES    = self.triggers.instances
    }
    command = "ssl_scripts/worker.sh"
  }
  provisioner "local-exec" {
    environment = {
      KUBERNETES_PUBLIC_ADDRESS = self.triggers.address
      instances                 = self.triggers.instances
    }
    command = "kube_scripts/worker.sh"
  }
}

# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/09-bootstrapping-kubernetes-workers.md
# This will bootstrap all the workers.
resource "null_resource" "workers" {
  count = var.worker_count
  triggers = {
    config_ip   = null_resource.worker_kube_config.triggers.address
    address     = null_resource.ssl.triggers.address
    name        = google_compute_instance.worker[count.index].name
    internal_ip = google_compute_instance.worker[count.index].network_interface.0.network_ip
    external_ip = google_compute_instance.worker[count.index].network_interface.0.access_config.0.nat_ip
    username    = var.username
    controllers = null_resource.controllers[count.index].triggers.external_ip
  }
  connection {
    host = self.triggers.external_ip
    user = self.triggers.username
  }

  # Copy the kubeconfigs to the workers
  provisioner "file" {
    source      = "kube_configs/${self.triggers.name}.kubeconfig"
    destination = "~/${self.triggers.name}.kubeconfig"
  }
  provisioner "file" {
    source      = "kube_configs/kube-proxy.kubeconfig"
    destination = "~/kube-proxy.kubeconfig"
  }

  # Copy the ssl certs and key to the workers
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

  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/09-bootstrapping-kubernetes-workers.md#provisioning-a-kubernetes-worker-node
  # Finally, bootstrap the workers
  provisioner "remote-exec" {
    scripts = [
      "kube_scripts/worker_bootstrap.sh"
    ]
  }
}

# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/10-configuring-kubectl.md
resource "null_resource" "kubectl_config" {
  triggers = {
    address = null_resource.ssl.triggers.address
    workers = join(" ", null_resource.workers.*.triggers.name)
  }
  provisioner "local-exec" {
    command = "kube_scripts/kubectl-config.sh"
    environment = {
      KUBERNETES_PUBLIC_ADDRESS = self.triggers.address
    }
  }
}

# Next, routes.tf creates the pod routing

# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md

# Create the kubeconfig files, which will be distributed to the workers and controllers
resource "null_resource" "kube_configs" {
  triggers = {
    address = google_compute_address.kube_api.address
    certs   = null_resource.ssl.triggers.address
  }

  # local-exec provisioners run locally
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md#the-kube-scheduler-kubernetes-configuration-file
  provisioner "local-exec" {
    command = "kube_scripts/scheduler.sh"
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md#the-kube-controller-manager-kubernetes-configuration-file
  provisioner "local-exec" {
    command = "kube_scripts/kube-controller-manager.sh"
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/06-data-encryption-keys.md 
  provisioner "local-exec" {
    command = "kube_scripts/encryption.sh"
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md#the-admin-kubernetes-configuration-file 
  provisioner "local-exec" {
    command = "kube_scripts/admin.sh"
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md#the-kube-proxy-kubernetes-configuration-file
  provisioner "local-exec" {
    command = "kube_scripts/kube-proxy.sh"
    environment = {
      KUBERNETES_PUBLIC_ADDRESS = self.triggers.address
    }
  }
}

# These files are distributed to controllers and workers in controller-provisioner.tf and worker-provisioner.tf

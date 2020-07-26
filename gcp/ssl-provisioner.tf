# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md

# The main ssl certificates are created in this resource, they only depend on external IP address
resource "null_resource" "ssl" {
  triggers = {
    address = google_compute_address.kube_api.address
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#certificate-authority
  provisioner "local-exec" {
    command = "ssl_scripts/ca.sh"
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-admin-client-certificate
  provisioner "local-exec" {
    command = "ssl_scripts/admin.sh"
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-service-account-key-pair 
  provisioner "local-exec" {
    command = "ssl_scripts/service-account.sh"
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-controller-manager-client-certificate
  provisioner "local-exec" {
    command = "ssl_scripts/controller-manager.sh"
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-kube-proxy-client-certificate
  provisioner "local-exec" {
    command = "ssl_scripts/kube-proxy.sh"
  }
  # https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-scheduler-client-certificate
  provisioner "local-exec" {
    command = "ssl_scripts/scheduler.sh"
  }
}

# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-kubernetes-api-server-certificate
# This resource cannot be created until the controllers have completed (the triggers will wait for the controller resources)
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

# Distribution of certificates to controllers is in controller-provisioner.tf
# And worker certificates are distributed in worker-provisioner.tf

# ---------------------------------------------------------------------------------------------------------------------
# KUBECONFIG MODULE
# This module generates a kubeconfig file for GKE cluster authentication
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Create the kubeconfig content
  kubeconfig_content = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [
      {
        name = var.cluster_name
        cluster = {
          server                     = "https://${var.cluster_endpoint}"
          certificate-authority-data = var.cluster_ca_certificate
        }
      }
    ]
    contexts = [
      {
        name = var.cluster_name
        context = {
          cluster = var.cluster_name
          user    = var.cluster_name
        }
      }
    ]
    current-context = var.cluster_name
    users = [
      {
        name = var.cluster_name
        user = {
          exec = {
            apiVersion         = "client.authentication.k8s.io/v1beta1"
            command            = "gke-gcloud-auth-plugin"
            installHint        = "Install gke-gcloud-auth-plugin for use with kubectl by following https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#install_plugin"
            provideClusterInfo = true
          }
        }
      }
    ]
  })
}

# Generate the kubeconfig file
resource "local_file" "kubeconfig" {
  content  = local.kubeconfig_content
  filename = var.output_path

  # Ensure the directory exists
  directory_permission = "0755"
  file_permission      = "0600"
}

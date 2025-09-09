output "name" {
  # This may seem redundant with the `name` input, but it serves an important
  # purpose. Terraform won't establish a dependency graph without this to interpolate on.
  description = "The name of the cluster master. This output is used for interpolation with node pools, other modules."

  value = google_container_cluster.cluster.name
}

output "master_version" {
  description = "The Kubernetes master version."
  value       = google_container_cluster.cluster.master_version
}

output "endpoint" {
  description = "The IP address of the cluster master."
  value       = google_container_cluster.cluster.endpoint
}
output "cluster_endpoint" {
  description = "The IP address of the cluster master."
  value       = google_container_cluster.cluster.endpoint
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  description = "Public certificate used by clients to authenticate to the cluster endpoint."
  value       = google_container_cluster.cluster.master_auth[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Private key used by clients to authenticate to the cluster endpoint."
  value       = google_container_cluster.cluster.master_auth[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster."
  value       = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_sa" {
  value = google_service_account.gke_service_account.email
}

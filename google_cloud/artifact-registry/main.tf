# main.tf

resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = var.repository_name
  description   = var.description
  format        = "DOCKER"
}
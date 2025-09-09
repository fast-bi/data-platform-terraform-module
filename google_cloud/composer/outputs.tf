output "composer_name" {
  value = local.composer_name
}

output "composer_location" {
  value = var.location
}

output "composer_project" {
  value = var.project
}

output "composer_gke_name" {
  value = google_composer_environment.composer.config.0.gke_cluster
}

output "gcs_prefix" {
  value = google_composer_environment.composer.config.0.dag_gcs_prefix
}

output "airflow_uri" {
  value = google_composer_environment.composer.config.0.airflow_uri
}

output "composer_gke_name_short" {
  value = one(regex("([^/]+$)", "${google_composer_environment.composer.config.0.gke_cluster}"))
}

output "composer_gke_zone" {
  value = split("/", one(regex("^.*zones/(.*)$", "${google_composer_environment.composer.config.0.gke_cluster}")))[0]
}


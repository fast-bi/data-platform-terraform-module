# main.tf

# Attach the Google Cloud project To Management project with shared network.
resource "google_compute_shared_vpc_service_project" "service_projects" {
  provider = google-beta
  for_each = toset(
    var.shared_vpc_service_projects != null
    ? var.shared_vpc_service_projects
    : []
  )
  host_project    = var.shared_vpc_project_id
  service_project = each.value
}

# Attach the Google Cloud Project Members To Management Subnetwrok to use shared network.
resource "google_compute_subnetwork_iam_binding" "binding" {
  project    = var.shared_vpc_project_id
  region     = var.region
  subnetwork = var.subnetwork
  role       = var.role
  members    = var.members

}

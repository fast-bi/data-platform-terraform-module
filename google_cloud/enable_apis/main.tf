
resource "google_project_service" "apis" {
  for_each = toset(var.enable_services)

  project = var.project
  service = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}
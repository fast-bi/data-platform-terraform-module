
resource "google_project_service" "project_service" {
  project = var.project
  service = "iap.googleapis.com"
}

resource "google_iap_brand" "project_brand" {
  support_email     = var.support_email
  application_title = "FAST.BI Cloud IAP protected Applications"
  project           = google_project_service.project_service.project
}

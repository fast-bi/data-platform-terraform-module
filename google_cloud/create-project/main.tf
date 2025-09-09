# main.tf

# Create the Google Cloud project
resource "google_project" "project" {
  name                = var.project
  project_id          = var.project
  folder_id           = var.parent_folder_id != "" ? var.parent_folder_id : null
  billing_account     = var.billing_account_id
  auto_create_network = false
}

# Assign project IAM roles
resource "google_project_iam_member" "project_iam" {
  project = google_project.project.project_id
  role    = var.project_role
  member  = var.project_member
}

# main.tf

# Assign project IAM roles
resource "google_project_iam_member" "project_iam" {
  project = var.common_project_id
  role    = var.project_role
  member  = var.project_member
}

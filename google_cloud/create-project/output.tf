output "project_id" {
  description = "an identifier for the resource with format"
  value       = trimprefix(google_project.project.id, "projects/")
}
output "project_number" {
  description = "The numeric identifier of the project."
  value       = google_project.project.number
}

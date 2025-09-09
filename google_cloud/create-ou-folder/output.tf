output "folder_id" {
  description = "created first folder ID (empty string if no folders created)"
  value       = length(var.customer_folder_names) > 0 && var.parent_folder != "" ? module.folders[0].id : ""
}
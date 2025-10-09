output "kubeconfig_path" {
  description = "The path to the generated kubeconfig file"
  value       = local_file.kubeconfig.filename
}

output "kubeconfig_content" {
  description = "The content of the generated kubeconfig file"
  value       = local_file.kubeconfig.content
  sensitive   = true
}

# output "key" {
#   description = "Map of service account keys."
#   value       = module.service_accounts.key
# }

output "external_ip_id" {
  description = "External Ip ID"
  value       = google_compute_address.external_ip_address.id
}

output "external_ip_address" {
  description = "External IP address"
  value       = google_compute_address.external_ip_address.address
}

output "external_ip_name" {
  description = "External IP name"
  value       = google_compute_address.external_ip_address.name
}

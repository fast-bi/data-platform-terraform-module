output "name_servers" {
  value = google_dns_managed_zone.public_zone.name_servers
}

output "dns_name" {
  value = google_dns_managed_zone.public_zone.dns_name
}

output "zone_id" {
  value = google_dns_managed_zone.public_zone.id
}

output "name_servers_list" {
  description = "List of name servers for the DNS zone"
  value = google_dns_managed_zone.public_zone.name_servers
}

output "dns_zone_info" {
  description = "Complete DNS zone information including domain and name servers"
  value = {
    domain_name = google_dns_managed_zone.public_zone.dns_name
    name_servers = google_dns_managed_zone.public_zone.name_servers
    zone_id = google_dns_managed_zone.public_zone.id
  }
}
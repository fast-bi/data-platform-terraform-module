# main.tf

# Create the Google Cloud project Cloud DNS Public Zone
resource "google_dns_managed_zone" "public_zone" {
  name        = var.zone_name
  dns_name    = var.domain_name
  description = "Public DNS zone created by Terraform"
  force_destroy = true
}

# Save DNS zone name servers to a file (just the name servers)
resource "local_file" "dns_zone_nameservers" {
  content  = join("\n", google_dns_managed_zone.public_zone.name_servers)
  filename = var.output_path != "" ? "${var.output_path}/dns_zone_nameservers.txt" : "../../../../../dns_zone_nameservers.txt"
}

# Save complete DNS zone information to a file
resource "local_file" "dns_zone_complete_info" {
  content  = <<-EOT
${google_dns_managed_zone.public_zone.dns_name}	NS	21600	
${join("\n", google_dns_managed_zone.public_zone.name_servers)}
EOT
  filename = var.output_path != "" ? "${var.output_path}/dns_zone_complete_info.txt" : "../../../../../dns_zone_complete_info.txt"
}

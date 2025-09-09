locals {
  ext_ip_name = var.overwrite_name == "" ? "${var.env}-${var.name_prefix}-ext-ip" : var.overwrite_name
}

resource "google_compute_address" "external_ip_address" {
  name         = local.ext_ip_name
  project      = var.project
  region       = var.region
  description  = var.description
  address_type = "EXTERNAL"
}

# Save external IP address to a file
resource "local_file" "external_ip_file" {
  content  = google_compute_address.external_ip_address.address
  filename = "../../../../external_ip_${var.name_prefix}.txt"
}


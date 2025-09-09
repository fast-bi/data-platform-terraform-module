module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.network_project_id
  network_name = var.network_name

  ingress_rules = [{
    name                    = var.fw_rule_name
    description             = var.description
    priority                = 1000
    destination_ranges      = null
    source_ranges           = concat(var.ip, var.extra_ips)
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["private"]  # Changed from "private-pool" to "private" to match GKE nodes
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22", "443", "80"]
    }]
    deny       = []
    log_config = null
  }]
}
module "vpc-host" {
  source                      = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-vpc?ref=v45.0.0"
  project_id                  = var.project
  name                        = var.vpc_name
  subnets                     = var.subnets
  shared_vpc_host             = var.shared_vpc_host
  shared_vpc_service_projects = var.shared_vpc_service_projects
  description                 = null
  subnets_psc                 = var.subnets_psc
  psa_configs                 = var.psa_configs
  subnets_proxy_only          = var.subnets_proxy_only
}

locals {
  external_addresses = {
    for s in var.cloud_nat : s.external_address_name => s.region

  }
}

module "addresses" {
  source             = "./net-address"
  project_id         = var.project
  external_addresses = local.external_addresses

}

module "nat" {
  for_each                  = { for index, nat in var.cloud_nat : nat.name => nat }
  source                    = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-cloudnat?ref=v45.0.0"
  name                      = each.value.name
  project_id                = var.project
  region                    = each.value.region
  addresses                 = [module.addresses.external_addresses["${each.value.external_address_name}"].self_link]
  config_port_allocation    = each.value.config_port_allocation
  config_source_subnetworks = each.value.config_source_subnetworks
  config_timeouts           = each.value.config_timeouts
  logging_filter            = each.value.logging_filter
  router_create             = each.value.router_create
  router_name               = each.value.router_name
  router_network            = module.vpc-host.self_link
}

module "firewall" {
  source               = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-vpc-firewall?ref=v45.0.0"
  project_id           = var.project
  network              = module.vpc-host.name
  default_rules_config = var.default_rules_config
  egress_rules         = var.egress_rules
  ingress_rules        = var.ingress_rules
}

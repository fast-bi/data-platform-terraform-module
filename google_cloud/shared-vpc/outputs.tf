
output "vpc_name" {
  description = "The name of the VPC being created."
  value       = module.vpc-host.name
}

output "vpc_self_link" {
  description = "The URI of the VPC being created."
  value       = module.vpc-host.self_link
}

output "subnets_psc" {
  description = "Private Service Connect subnet resources."
  value       = module.vpc-host.subnets_psc
}

output "vpc_project" {
  description = "Project where vpc is deployed"
  value       = module.vpc-host.project_id
}

output "vpc_subnet_links" {
  description = "Map of subnet self links keyed by name."
  value       = module.vpc-host.subnet_self_links
}

output "subnet_secondary_ranges" {
  description = "Map of subnet secondary ranges keyed by name."
  value       = module.vpc-host.subnet_secondary_ranges
}

output "cloud_nat_ip" {
  description = "List of external addeses of cloud nat "
  value       = module.addresses.external_addresses
}

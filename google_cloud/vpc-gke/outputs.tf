output "network" {
  value = module.vpc.network_self_link
}

output "public_subnetwork" {
  value = module.vpc.subnets_names[0]
}

output "cluster_subnetwork_secondary_range_name" {
  #dirty way !!!! need to fix this !!!!
  value = module.vpc.subnets_secondary_ranges[0][0].range_name
}
output "service_subnetwork_secondary_range_name" {
  #dirty way !!!! need to fix this !!!!
  value = module.vpc.subnets_secondary_ranges[0][1].range_name
}

output "host_project_id" {
  value = var.attached_projects != null ? google_compute_shared_vpc_host_project.host.project : null
}

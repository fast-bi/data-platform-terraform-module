output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

# output "public_route_table_ids" {
#   description = "List of IDs of public route tables"
#   value       = module.vpc.aws_route_table.public.*.id
# }

# output "private_route_table_ids" {
#   description = "List of IDs of private route tables"
#   value       = module.vpc.aws_route_table.private.*.id
# }

# output "nat_gateway_ids" {
#   description = "List of NAT Gateway IDs"
#   value       = module.vpc.aws_nat_gateway.this.*.id
# }

# output "nat_public_ips" {
#   description = "List of public Elastic IPs created for AWS NAT Gateway"
#   value       = module.vpc.aws_eip.nat.*.public_ip
# }

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.vpc.azs
}
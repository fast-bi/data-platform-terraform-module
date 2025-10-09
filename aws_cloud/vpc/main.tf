data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Get the availability zones based on az_size variable
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_size)
}


module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v5.19.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  secondary_cidr_blocks = var.secondary_cidr_blocks # can add up to 5 total CIDR blocks

  azs             = local.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway        = var.enable_nat_gateway
  single_nat_gateway        = var.single_nat_gateway
  one_nat_gateway_per_az    = var.one_nat_gateway_per_az
  enable_dns_hostnames      = var.enable_dns_hostnames
  enable_dns_support        = var.enable_dns_support
  enable_flow_log           = var.enable_flow_log
  flow_log_destination_type = var.flow_log_destination_type
  private_subnet_tags       = var.private_subnet_tags
  public_subnet_tags        = var.public_subnet_tags
  default_vpc_tags          = var.default_tags
  vpc_tags                  = var.vpc_tags
}

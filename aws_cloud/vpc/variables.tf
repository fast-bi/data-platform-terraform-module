variable "region" {
  description = "(Optional) AWS Region where the provider will operate. The Region must be set. Can also be set with either the AWS_REGION or AWS_DEFAULT_REGION environment variables, or via a shared config file parameter region if profile is used. If credentials are retrieved from the EC2 Instance Metadata Service, the Region can also be retrieved from the metadata."
  type        = string
}
variable "profile" {
  description = "(Optional) AWS profile name as set in the shared configuration and credentials files. Can also be set using either the environment variables AWS_PROFILE or AWS_DEFAULT_PROFILE."
  type        = string
  default     = "default"
}

variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "az_size" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
  validation {
    condition     = var.az_size >= 1 && var.az_size <= 3
    error_message = "The az_size must be between 1 and 3."
  }
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = []
}
variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type = list(string)
  default = []
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets outbound traffic"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Create one NAT Gateway per availability zone"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_destination_type" {
  description = "VPC Flow Logs destination type"
  type        = string
  default     = "cloud-watch-logs"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

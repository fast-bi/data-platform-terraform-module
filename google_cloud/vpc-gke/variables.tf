variable "project" {
  description = "The project ID to host the database in."
  type        = string
}

variable "attached_projects" {
  description = "The project ID to host the database in."
  type        = string
  default     = null
}

variable "region" {
  description = "The region to host the database in."
  type        = string
}

variable "env" {
  description = "Environment name where vpc is deployed"
  type        = string
}

variable "name" {
  description = "The name of the vpc"
  type        = string
}

variable "cidr_block" {
  description = "Predefined range name for VPC subnet."
  type        = string
}

variable "cluster_ipv4_cidr_block" {
  description = "Predefined range name for the cluster pod IPs."
  type        = string
}
variable "services_ipv4_cidr_block" {
  description = "Predefined range name for the cluster services IPs."
  type        = string
}

variable "private_service_connect_cidr" {
  description = "Private service connect ip range. If not defined, wouldn't be created."
  type        = string
}

variable "lb_subnet_cidr" {
  description = "Private LB subnet CIDR"
  type        = string
}

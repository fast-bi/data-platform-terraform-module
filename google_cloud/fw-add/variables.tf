# variables.tf
variable "project" {
  description = "The desired project ID for the Google Cloud project"
  type        = string
}

variable "network_project_id" {
  description = "The Network project ID for the Google Cloud project"
  type        = string
}


variable "network_name" {
  description = "The Network Name for the Google Cloud project"
  type        = string
}

variable "fw_rule_name" {
  description = "The firewall rule name"
  type        = string
}

variable "description" {
  description = "The firewall rule description"
  type        = string
}

variable "ip" {
  description = "The IP address"
  type        = list(string)
}

variable "extra_ips" {
  description = "extra IP address"
  type        = list(string)
  default     = []
}

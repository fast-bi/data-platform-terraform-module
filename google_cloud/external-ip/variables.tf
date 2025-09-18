variable "project" {
  description = "The project ID to create ExternalIP"
  type        = string
}
variable "region" {
  description = "The region to create ExternalIP"
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to external IP name."
  type        = string
  default     = ""
}

variable "env" {
  description = "Environement where resource is created."
  type        = string
}

# variable "names" {
#   description = "Names of the service accounts to create."
#   type        = list(string)
# }

variable "overwrite_name" {
  description = "overwrite name of external IP"
  type        = string
  default     = ""
}


variable "description" {
  description = "An optional description of this resource."
  type        = string
  default     = ""
}

variable "output_path" {
  description = "Path to save output files (external IP address, etc.)"
  type        = string
  default     = ""
}
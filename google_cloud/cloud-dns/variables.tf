variable "project" {
  description = "The ID of the Google Cloud project."
}

variable "zone_name" {
  description = "The name of the DNS zone."
}

variable "domain_name" {
  description = "The Domain of the DNS zone."
}

variable "output_path" {
  description = "Path to save output files (DNS zone info, nameservers, etc.)"
  type        = string
  default     = ""
}

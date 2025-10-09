# Define variables for domain configuration
variable "region" {
  description = "(Optional) AWS Region where the provider will operate. The Region must be set. Can also be set with either the AWS_REGION or AWS_DEFAULT_REGION environment variables, or via a shared config file parameter region if profile is used. If credentials are retrieved from the EC2 Instance Metadata Service, the Region can also be retrieved from the metadata."
  type        = string
}

variable "profile" {
  description = "(Optional) AWS profile name as set in the shared configuration and credentials files. Can also be set using either the environment variables AWS_PROFILE or AWS_DEFAULT_PROFILE."
  type        = string
  default     = "default"
}

variable "main_domain" {
  description = "The main domain name managed in GCP"
  type        = string
  default     = null
}

variable "subdomain" {
  description = "The subdomain to be managed in AWS"
  type        = string
  default     = null
}

variable "gcp_dns_zone_name" {
  description = "The name of the GCP DNS zone for the main domain"
  type        = string
  default     = null
}

variable "gcp_project_id" {
  description = "Google Cloud Project ID"
  type        = string
  default     = null
}

# variable "gcp_region" {
#   description = "Google Cloud region"
#   type        = string
#   default     = null
# }

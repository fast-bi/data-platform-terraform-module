variable "project" {
  description = "The project ID to host the database in."
  type        = string
}

variable "region" {
  description = "The region to create ExternalIP"
  type        = string
}
variable "enable_services" {
  description = "List of services to enable api"
  type        = list(any)
}

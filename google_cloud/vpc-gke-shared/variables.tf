variable "project" {
  description = "The ID of the Google Cloud project."
}

variable "shared_vpc_project_id" {
  description = "The name of the Main Project with Shared vpc."
}

variable "shared_vpc_service_projects" {
  description = "Shared VPC service projects to register with this host."
  type        = list(string)
  default     = []
}

variable "subnetwork" {
  description = ""
}

variable "region" {
  description = ""
}

variable "role" {
  description = ""
}

variable "members" {
  type        = list(string)
  default     = []
  description = ""
}

variable "project" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "repository_name" {
  description = "The name of the Artifact Registry Docker repository."
}

variable "description" {
  description = "The Description of the Artifact Registry Docker repository."
}

variable "region" {
  description = "The region where the repository will be created."
  default     = "europe-central2"
}

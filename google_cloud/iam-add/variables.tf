# variables.tf
variable "project" {
  description = "The desired project ID for the Google Cloud project"
  type        = string
}

variable "common_project_id" {
  description = "The Common project ID for the Google Cloud project"
  type        = string
}

variable "project_role" {
  description = "The IAM role to assign to the project member"
  type        = string
}

variable "project_member" {
  description = "The member to whom the IAM role will be assigned"
  type        = string
}

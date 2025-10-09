# variables.tf

variable "billing_account_id" {
  default     = null
  description = "The billing account ID"
}

variable "project" {
  description = "The desired project ID for the Google Cloud project"
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

variable "parent_folder_id" {
  description = "The Google Cloud Organization Folder ID (empty/null for projects under billing account)"
  type        = string
  default     = ""
}

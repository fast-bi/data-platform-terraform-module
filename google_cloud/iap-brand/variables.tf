# variables.tf
variable "project" {
  description = "The desired project ID for the Google Cloud project"
  type        = string
}


variable "org_id" {
  description = "The Google Cloud Organization ID"
  type        = string
}

variable "support_email" {
  description = "Support email displayed on the OAuth consent screen."
  type        = string
}

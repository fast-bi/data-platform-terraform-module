variable "project" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "parent_folder" {
  description = "The parent folder ID (empty for organization-level folders)"
  type        = string
  default     = ""
}



variable "customer_folder_names" {
  description = "The names of the folders"
  type        = list(string)
}

variable "set_roles" {
  description = "Flag to set roles"
  type        = bool
  default     = true
}


variable "all_folder_admins" {
  description = "List of all folder admins"
  type        = list(string)
}

variable "deployer_member" {
  description = "Terraform deployer member needed to add extra permissions to allow create new project. In form of: user:{emailid}: An email address that is associated with a specific Google account. For example, alce@gmail.com . serviceAccount:{emailid}: An email address that represents a service account. For example, my-other-app@appspot.gserviceaccount.com. group:{emailid}: An email address that represents a Google group. For example, admins@example.com. domain:{domain}: A G Suite domain (primary, instead of alias) name that represents all the users of that domain. For example, google.com or example.com."
  type        = list(string)
}

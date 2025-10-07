variable "project" {
  description = "The project ID to host the service accounts in"
  type        = string
}

variable "sa_names" {
  description = "Names of the service accounts to create"
  type        = list(string)
}

variable "generate_keys_for_sa" {
  description = "Generate keys for service accounts"
  type        = bool
  default     = false
}

variable "sa_display_name" {
  description = "Service account display name"
  type        = string
  default     = ""
}

variable "project_roles" {
  description = "Common roles to apply to ALL service accounts, format: \"project_id=>role\""
  type        = list(string)
  default     = []
}

variable "sa_description" {
  description = "Default description of the created service accounts"
  type        = string
  default     = ""
}

variable "wid_mapping_to_sa" {
  description = "List of namespaces and k8s sa to map to WID of gke"
  type = list(object({
    namespace   = string
    k8s_sa_name = string
  }))
  default = []
}

variable "handle_existing_gracefully" {
  description = "Handle existing service accounts gracefully without recreation"
  type        = bool
  default     = true
}

variable "output_path" {
  description = "Path to save output files (service account keys, names, etc.)"
  type        = string
  default     = ""
}

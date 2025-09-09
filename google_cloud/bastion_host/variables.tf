variable "project" {
  description = "The project ID"
  type        = string
}
variable "region" {
  description = "Region"
  type        = string
}

variable "name" {
  description = "Name of compute engine instance"
  type        = string
  default     = ""
}

variable "machine_type" {
  description = "Machine type to deploy"
  type        = string
  default     = "e2-micro"
}

variable "network" {
  description = "Self link for netowkr"
  type        = string
  default     = ""
}

variable "subnetwork" {
  description = "Self link for subnet"
  type        = string
  default     = ""
}


variable "sa_email" {
  description = "Default description of the created service accounts (defaults to no description)"
  type        = string
  default     = ""
}

variable "host_project" {
  description = "The network host project ID."
  type        = string
  default     = ""
}
variable "additional_ports" {
  description = "A list of additional ports/ranges to open access to on the instances from IAP."
  type        = list(string)
  default     = []
}

variable "create_firewall_rule" {
  type        = bool
  description = "If we need to create the firewall rule or not."
  default     = true
}

variable "fw_name_allow_ssh_from_iap" {
  description = "Firewall rule name for allowing SSH from IAP."
  type        = string
  default     = "allow-ssh-from-iap-to-tunnel"
}

variable "network_tags" {
  description = "Network tags associated with the instances to allow SSH from IAP. Exactly one of service_accounts or network_tags should be specified."
  type        = list(string)
  default     = []
}

variable "composer_name" {
  description = "Network tags associated with the instances to allow SSH from IAP. Exactly one of service_accounts or network_tags should be specified."
  type        = string
  default     = ""
}

variable "composer_location" {
  description = "Network tags associated with the instances to allow SSH from IAP. Exactly one of service_accounts or network_tags should be specified."
  type        = string
  default     = ""
}

variable "dbt_deploy_sa_email" {
  description = "dbt_deploy_sa_email"
  type        = string
  default     = ""
}

variable "composer_gke_name" {
  type        = string
  description = "Composer GKE name"
}

variable "composer_gke_zone" {
  description = "Composer GKE zone where it's deployed"
  type        = string
}
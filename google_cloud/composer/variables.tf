# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "shared_vpc_project" {
  description = "The project ID for Shared VPC Network"
  type        = string
}

variable "prefix" {
  description = "Prefix"
  type        = string
}

variable "location" {
  description = "The location (region or zone) to host the cluster in"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
}

variable "name" {
  description = "The name of the composer"
  type        = string
}

variable "service_account_roles" {
  description = "Roles for Composer SA"
  type        = list(any)
}

variable "shared_vpc_service_account_roles" {
  description = "Roles for Composer SA in Shared VPC Project"
  type        = list(any)
}

variable "node_count" {
  description = "The number of nodes in the Kubernetes Engine cluster of the environment."
  type        = string
}

variable "node_zone" {
  description = "The Compute Engine zone in which to deploy the VMs running the Apache Airflow software, specified as the zone name or relative resource name (e.g. 'projects/{project}/zones/{zone}'). Must belong to the enclosing environment's project and region."
  type        = string
}

variable "node_machine_type" {
  description = "The Compute Engine machine type used for cluster instances, specified as a name or relative resource name. For example: 'projects/{project}/zones/{zone}/machineTypes/{machineType}'. Must belong to the enclosing environment's project and region/zone."
  type        = string
}

variable "disk_size_gb" {
  description = "The disk size in GB used for node VMs. Minimum size is 20GB. If unspecified, defaults to 100GB. Cannot be updated."
  type        = string
}

variable "oauth_scopes" {
  description = "he set of Google API scopes to be made available on all node VMs. Cannot be updated. If empty, defaults to ['https://www.googleapis.com/auth/cloud-platform']."
  type        = list(any)
}

variable "cloudsql_machine_type" {
  description = "loud SQL machine type used by Airflow database. It has to be one of: db-n1-standard-2, db-n1-standard-4, db-n1-standard-8 or db-n1-standard-16."
  type        = string
}

variable "composer_machine_type" {
  description = "Machine type on which Airflow web server is running. It has to be one of: composer-n1-webserver-2, composer-n1-webserver-4 or composer-n1-webserver-8. Value custom is returned only in response, if Airflow web server parameters were manually changed to a non-standard values."
  type        = string
}

variable "maintenance_start" {
  description = "Start time of the first recurrence of the maintenance window."
  type        = string
}

variable "maintenance_stop" {
  description = "Maintenance window end time. It is used only to calculate the duration of the maintenance window. The value for end-time must be in the future, relative to 'start_time'"
  type        = string
}

variable "tags" {
  description = "he list of instance tags applied to all node VMs. Tags are used to identify valid sources or targets for network firewalls. Each tag within the list must comply with RFC1035. Cannot be updated."
  type        = list(any)
}
variable "recurrence" {
  description = "Maintenance window recurrence. Format is a subset of RFC-5545 (https://tools.ietf.org/html/rfc5545) 'RRULE'. The only allowed values for 'FREQ' field are 'FREQ=DAILY' and 'FREQ=WEEKLY;BYDAY=…'. Example values: 'FREQ=WEEKLY;BYDAY=TU,WE', 'FREQ=DAILY'"
  type        = string
}

variable "allowed_web_server_access" {
  description = "The set of Google API scopes to be made available on all node VMs. Cannot be updated. If empty, defaults to ['https://www.googleapis.com/auth/cloud-platform']."
  type        = list(any)
}

variable "image_version" {
  description = "Composer image version"
  type        = string
}

variable "scheduler_count" {
  description = "scheduler_count field in the software_config block specifies the number of schedulers in your environment"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "he IP range in CIDR notation to use for the hosted master network. This range is used for assigning internal IP addresses to the cluster master or set of masters and to the internal load balancer virtual IP. This range must not overlap with any other ranges in use within the cluster's network. If left blank, the default value of is used."
  type        = string
}


variable "web_server_ipv4_cidr_block" {
  description = "The CIDR block from which IP range for web server will be reserved. Needs to be disjoint from master_ipv4_cidr_block and cloud_sql_ipv4_cidr_block"
  type        = string
}


variable "cloud_sql_ipv4_cidr_block" {
  description = "The CIDR block from which IP range in tenant project will be reserved for Cloud SQL. Needs to be disjoint from web_server_ipv4_cidr_block"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "The name of the cluster's secondary range used to allocate IP addresses to pods."
  type        = string
}

variable "services_secondary_range_name" {
  description = "The name of the services' secondary range used to allocate IP addresses to the cluster."
  type        = string
}

variable "composer_user_admin" {
  description = "Composer Admin user in email"
  type        = string
  default     = null
}

variable "network_name" {
  description = "The Compute Engine network to be used for machine communications, specified as a self-link, relative resource name"
  type        = string
}

variable "subnetwork_name" {
  description = "The Compute Engine sub-network to be used for machine communications, specified as a self-link, relative resource name"
  type        = string
}

variable "subnetwork_ip_cidr_range" {
  description = "Dedicated Composer primary IP range of the subnetwork"
  type        = string
}

variable "composer_cluster_secondary_ip_cidr_range" {
  description = "The name of the cluster' secondary range used to allocate IP addresses to the cluster."
  type        = string
}

variable "composer_services_secondary_ip_cidr_range" {
  description = "The name of the services' secondary range used to allocate IP addresses to the cluster."
  type        = string
}

variable "master_authorized_networks_config" {
  description = <<EOF
  The desired configuration options for master authorized networks. Omit the nested cidr_blocks attribute to disallow external access (except the cluster node IPs, which GKE automatically whitelists)
  ### example format ###
  master_authorized_networks_config = [{
    cidr_blocks = [{
      cidr_block   = "10.0.0.0/8"
      display_name = "example_network"
    }],
  }]
EOF
  type        = list(any)
  default     = []
}

variable "cloud_nat" {
  description = "Cloud NAT management, with optional router creation"
  type        = list(any)
  default     = []
}

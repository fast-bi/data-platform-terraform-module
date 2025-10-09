# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to host the vpc in"
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

variable "vpc_name" {
  description = "The name of shared VPC to create"
  type        = string
}

variable "subnets" {
  description = "A reference (self link) to the VPC network to host the cluster in"
  type = list(object({
    name                  = string
    ip_cidr_range         = string
    region                = string
    description           = optional(string)
    enable_private_access = optional(bool, true)
    flow_logs_config = optional(object({
      aggregation_interval = optional(string)
      filter_expression    = optional(string)
      flow_sampling        = optional(number)
      metadata             = optional(string)
      metadata_fields      = optional(list(string))
    }))
    ipv6 = optional(object({
      access_type           = optional(string)
      enable_private_access = optional(bool, true)
    }))
    secondary_ip_ranges = optional(map(object({
      ip_cidr_range = string
    })))
  }))
  default = []
}

variable "shared_vpc_host" {
  description = "Enable shared VPC for this project."
  type        = bool
  default     = true
}

variable "subnet_iam" {
  description = "Subnet IAM bindings in {REGION/NAME => {ROLE => [MEMBERS]}} format."
  type        = map(map(list(string)))
  default     = {}
}

variable "shared_vpc_service_projects" {
  description = "Shared VPC service projects to register with this host."
  type        = list(string)
  default     = []
}

variable "subnets_proxy_only" {
  description = "List of proxy-only subnets for Regional HTTPS or Internal HTTPS load balancers. Note: Only one proxy-only subnet for each VPC network in each region can be active."
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    description   = optional(string)
    active        = optional(bool, true)
    global        = optional(bool, false)

    iam = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      role    = string
      members = list(string)
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    iam_bindings_additive = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
  }))
  default  = []
  nullable = false
}

variable "subnets_psc" {
  description = "List of subnets for Private Service Connect service producers."
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    description   = optional(string)
  }))
  default = []
}

variable "psa_configs" {
  type = list(object({
    ranges        = optional(map(string))
    export_routes = optional(bool)
    import_routes = optional(bool)
    # add other fields that the module expects in v45...
  }))
  description = "List of PSA configs (new shape expected by net-vpc)."
  default     = []
}

variable "cloud_nat" {
  description = "Cloud NATs to create for networks"
  type = list(object({
    name                                = string
    region                              = string
    addresses                           = optional(list(string))
    external_address_name               = string
    enable_endpoint_independent_mapping = optional(bool)
    config_min_ports_per_vm             = optional(number, 64)

    config_source_subnetworks = optional(object({
      all                 = optional(bool)
      primary_ranges_only = optional(bool)
      subnets = optional(list(object({
        self_link            = string
        config_source_ranges = list(string)
        secondary_ranges     = optional(list(string))
      })))
    }))

    config_timeouts = optional(object({
      icmp            = number
      tcp_established = number
      tcp_transitory  = number
      udp             = number
      }), {
      icmp            = 30
      tcp_established = 1200
      tcp_transitory  = 30
      udp             = 30
    })

    logging_filter = optional(string)
    router_asn     = optional(number)
    router_create  = optional(bool)
    config_port_allocation = optional(object({
      enable_endpoint_independent_mapping = optional(bool, false)
      enable_dynamic_port_allocation      = optional(bool, true)
      min_ports_per_vm                    = optional(number, 512)
      max_ports_per_vm                    = optional(number, 65536)
    }))

    router_name    = optional(string)
    router_network = optional(string)
  }))
  default = []
}

variable "default_rules_config" {
  description = "Optionally created convenience rules. Set the 'disabled' attribute to true, or individual rule attributes to empty lists to disable."
  type = object({
    admin_ranges = optional(list(string))
    disabled     = optional(bool, false)
    http_ranges = optional(list(string), [
      "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
    )
    http_tags = optional(list(string), ["http-server"])
    https_ranges = optional(list(string), [
      "35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
    )
    https_tags = optional(list(string), ["https-server"])
    ssh_ranges = optional(list(string), ["35.235.240.0/20"])
    ssh_tags   = optional(list(string), ["ssh"])
  })
  default  = {}
  nullable = false
}

variable "egress_rules" {
  description = "List of egress rule definitions, default to deny action. Null destination ranges will be replaced with 0/0."
  type = map(object({
    deny               = optional(bool, true)
    description        = optional(string)
    destination_ranges = optional(list(string))
    disabled           = optional(bool, false)
    enable_logging = optional(object({
      include_metadata = optional(bool)
    }))
    priority             = optional(number, 1000)
    targets              = optional(list(string))
    use_service_accounts = optional(bool, false)
    rules = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [{ protocol = "all" }])
  }))
  default  = {}
  nullable = false
}

variable "ingress_rules" {
  description = "List of ingress rule definitions, default to allow action. Null source ranges will be replaced with 0/0."
  type = map(object({
    deny        = optional(bool, false)
    description = optional(string)
    disabled    = optional(bool, false)
    enable_logging = optional(object({
      include_metadata = optional(bool)
    }))
    priority             = optional(number, 1000)
    source_ranges        = optional(list(string))
    sources              = optional(list(string))
    targets              = optional(list(string))
    use_service_accounts = optional(bool, false)
    rules = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [{ protocol = "all" }])
  }))
  default  = {}
  nullable = false
}

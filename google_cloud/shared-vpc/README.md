
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_addresses"></a> [addresses](#module\_addresses) | git@github.com:spotos/terraform-modules.git//net-address | n/a |
| <a name="module_nat"></a> [nat](#module\_nat) | git@github.com:spotos/terraform-modules.git//net-cloudnat | n/a |
| <a name="module_vpc-host"></a> [vpc-host](#module\_vpc-host) | github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [google_client_config.provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_nat"></a> [cloud\_nat](#input\_cloud\_natpsa_configs) | Cloud Nat's to create for networks | <pre>list(object({<br>    name                                = string<br>    region                              = string<br>    addresses                           = optional(list(string))<br>    external_address_name               = string<br>    enable_endpoint_independent_mapping = optional(bool)<br>    config_min_ports_per_vm             = optional(number, 64)<br>    config_source_subnets               = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")<br>    config_timeouts = optional(object({<br>      icmp            = number<br>      tcp_established = number<br>      tcp_transitory  = number<br>      udp             = number<br>      }), {<br>      icmp            = 30<br>      tcp_established = 1200<br>      tcp_transitory  = 30<br>      udp             = 30<br>    })<br>    logging_filter = optional(string)<br>    router_asn     = optional(number)<br>    router_create  = optional(bool)<br><br>    router_name    = optional(string)<br>    router_network = optional(string)<br>    subnetworks = optional(list(object({<br>      self_link            = string,<br>      config_source_ranges = list(string)<br>      secondary_ranges     = list(string)<br>    })))<br><br>  }))</pre> | `[]` | no |
| <a name="input_external_addresses"></a> [external\_addresses](#input\_external\_addresses) | Map of external address regions, keyed by name. | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The location (region or zone) to host the cluster in | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project ID to host the cluster in | `string` | n/a | yes |
| <a name="input_psa_configs"></a> [psa\_config](#input\_psa\_config) | The Private Service Access configuration for Service Networking. | <pre>object({<br>    ranges        = map(string)<br>    export_routes = optional(bool, false)<br>    import_routes = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to host the cluster in | `string` | n/a | yes |
| <a name="input_shared_vpc_host"></a> [shared\_vpc\_host](#input\_shared\_vpc\_host) | Enable shared VPC for this project. | `bool` | `true` | no |
| <a name="input_shared_vpc_service_projects"></a> [shared\_vpc\_service\_projects](#input\_shared\_vpc\_service\_projects) | Shared VPC service projects to register with this host. | `list(string)` | `[]` | no |
| <a name="input_subnet_iam"></a> [subnet\_iam](#input\_subnet\_iam) | Subnet IAM bindings in {REGION/NAME => {ROLE => [MEMBERS]} format. | `map(map(list(string)))` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A reference (self link) to the VPC network to host the cluster in | <pre>list(object({<br>    name                  = string<br>    ip_cidr_range         = string<br>    region                = string<br>    description           = optional(string)<br>    enable_private_access = optional(bool, true)<br>    flow_logs_config = optional(object({<br>      aggregation_interval = optional(string)<br>      filter_expression    = optional(string)<br>      flow_sampling        = optional(number)<br>      metadata             = optional(string)<br>      metadata_fields      = optional(list(string))<br>    }))<br>    ipv6 = optional(object({<br>      access_type           = optional(string)<br>      enable_private_access = optional(bool, true)<br>    }))<br>    secondary_ip_ranges = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_subnets_psc"></a> [subnets\_psc](#input\_subnets\_psc) | List of subnets for Private Service Connect service producers. | <pre>list(object({<br>    name          = string<br>    ip_cidr_range = string<br>    region        = string<br>    description   = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of shared VPC to create | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

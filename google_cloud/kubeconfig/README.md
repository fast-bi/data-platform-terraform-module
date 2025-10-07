# Kubeconfig Module

This Terraform module generates a kubeconfig file for authenticating with a GKE cluster.

## Usage

```hcl
module "kubeconfig" {
  source = "git::https://oauth2:glpat-FyjDMsexz1pNytpQQyw1@gitlab.fast.bi/infrastructure/infra-iaas/terraform-modules.git//kubeconfig?ref=v2.0.3"

  cluster_name           = "my-gke-cluster"
  cluster_endpoint       = "https://cluster-endpoint"
  cluster_ca_certificate = "cluster-ca-cert"
  client_certificate     = "client-cert"
  client_key            = "client-key"
  output_path           = "./kubeconfig"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | The name of the GKE cluster | `string` | n/a | yes |
| cluster_endpoint | The endpoint URL of the GKE cluster | `string` | n/a | yes |
| cluster_ca_certificate | The CA certificate for the GKE cluster | `string` | n/a | yes |
| client_certificate | The client certificate for cluster authentication | `string` | n/a | yes |
| client_key | The client key for cluster authentication | `string` | n/a | yes |
| output_path | The path where the kubeconfig file should be saved | `string` | `"./kubeconfig"` | no |

## Outputs

| Name | Description |
|------|-------------|
| kubeconfig_path | The path to the generated kubeconfig file |
| kubeconfig_content | The content of the generated kubeconfig file (sensitive) |

## Example

This module is typically used after creating a GKE cluster to generate the kubeconfig file needed for deploying applications to the cluster.

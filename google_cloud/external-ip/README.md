# External IP Module

This module creates Google Cloud external IP addresses and saves the IP address to a local file for easy access.

## Features

- **External IP Creation**: Creates external IP addresses in Google Cloud
- **File Output**: Automatically saves the IP address to a local file
- **Flexible Naming**: Supports custom naming and environment-based naming
- **Multiple Outputs**: Provides IP address, ID, and name as outputs

## Usage

```hcl
module "external_ip" {
  source = "path/to/external-ip"
  
  project     = "my-project-id"
  region      = "us-central1"
  name_prefix = "traefik"
  env         = "prod"
  description = "External IP for Traefik ingress"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | The project ID to create ExternalIP | `string` | n/a | yes |
| region | The region to create ExternalIP | `string` | n/a | yes |
| name_prefix | Prefix applied to external IP name | `string` | `""` | no |
| env | Environment where resource is created | `string` | n/a | yes |
| overwrite_name | Overwrite name of external IP | `string` | `""` | no |
| description | An optional description of this resource | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| external_ip_id | External IP ID |
| external_ip_address | External IP address |
| external_ip_name | External IP name |

## File Output

The module automatically creates a local file with the external IP address:

- **File Location**: `../../../../external_ip_{name_prefix}.txt`
- **Content**: The external IP address (e.g., `34.16.149.79`)
- **Example**: For `name_prefix = "traefik"`, creates `external_ip_traefik.txt`

## Examples

### Basic External IP
```hcl
module "traefik_ip" {
  source = "path/to/external-ip"
  
  project     = "my-project"
  region      = "us-central1"
  name_prefix = "traefik"
  env         = "prod"
}
```

### Custom Named External IP
```hcl
module "custom_ip" {
  source = "path/to/external-ip"
  
  project       = "my-project"
  region        = "us-central1"
  overwrite_name = "my-custom-external-ip"
  description   = "Custom external IP for my application"
}
```

## File Structure

After deployment, you'll find the IP address in:
```
project-root/
├── google_cloud/
│   └── terragrunt/
│       └── bi-platform/
│           └── 04-external-ip-traefik/
│               └── external_ip_traefik.txt  # Contains the IP address
```

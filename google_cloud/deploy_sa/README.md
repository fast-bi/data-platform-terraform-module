# Deploy Service Account Module

This module creates Google Cloud service accounts with optional key generation, IAM role assignments, and workload identity mappings.

## Features

- **Simple and Reliable**: Creates service accounts directly without complex data source logic
- **Flexible Key Generation**: Generate keys for service accounts when requested
- **IAM Role Assignment**: Assign project-level IAM roles to ALL service accounts (not just the first one)
- **Workload Identity**: Map Kubernetes service accounts to Google service accounts
- **Proper Key Encoding**: Service account keys are saved with correct base64 encoding
- **Stability Controls**: Includes lifecycle rules and timing controls to prevent race conditions

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project | The project ID to host the service accounts in | `string` | n/a | yes |
| sa_names | Names of the service accounts to create | `list(string)` | `[]` | no |
| generate_keys_for_sa | Generate keys for service accounts | `bool` | `false` | no |
| sa_display_name | Service account display name | `string` | `""` | no |
| project_roles | Common roles to apply to ALL service accounts, format: "project_id=>role" | `list(string)` | `[]` | no |
| sa_description | Default description of the created service accounts | `string` | `""` | no |
| wid_mapping_to_sa | Workload identity mappings | `list(object)` | `[]` | no |
| handle_existing_gracefully | Handle existing service accounts gracefully without recreation | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| sa_email | Email of the first service account |
| all_sa_emails | Map of all service account names to their emails |
| service_accounts | Map of all created service accounts |

## Usage

### Basic Service Account Creation

```hcl
module "deploy_sa" {
  source = "../../terraform-modules/deploy_sa"

  project  = "my-project-id"
  sa_names = ["service-account-1", "service-account-2"]
}
```

### With IAM Role Assignment

```hcl
module "deploy_sa" {
  source = "../../terraform-modules/deploy_sa"

  project  = "my-project-id"
  sa_names = ["service-account-1", "service-account-2"]

  project_roles = [
    "my-project=>roles/storage.objectViewer",
    "my-project=>roles/logging.logWriter"
  ]
}
```

### With Key Generation

```hcl
module "deploy_sa" {
  source = "../../terraform-modules/deploy_sa"

  project  = "my-project-id"
  sa_names = ["service-account-1"]

  generate_keys_for_sa = true
}
```

### With Workload Identity

```hcl
module "deploy_sa" {
  source = "../../terraform-modules/deploy_sa"

  project  = "my-project-id"
  sa_names = ["gke-sa"]

  wid_mapping_to_sa = [
    {
      namespace = "kube-system"
      k8s_sa_name = "default"
    }
  ]
}
```

## How It Works

1. **Service Account Creation**: Creates all specified service accounts
2. **IAM Role Assignment**: Applies ALL specified roles to ALL service accounts using `setproduct()`
3. **Key Generation**: Generates keys if requested and saves them as JSON files
4. **Workload Identity**: Sets up Kubernetes service account mappings
5. **Timing Control**: Uses `time_sleep` to prevent race conditions
6. **Graceful Handling**: Prevents recreation of existing resources using lifecycle rules

## Existing Service Account Handling

The module now includes enhanced lifecycle rules to handle existing service accounts gracefully:

- **No Recreation**: Existing service accounts are never recreated
- **State Preservation**: All existing IAM roles, keys, and bindings are preserved
- **Safe Updates**: Only applies changes when configuration actually differs
- **Production Ready**: Won't disrupt existing services on subsequent runs

### How It Prevents Recreation:

- **Service Accounts**: `ignore_changes` on critical fields prevents recreation
- **IAM Roles**: Existing role assignments are preserved
- **Keys**: Generated keys are never regenerated unless explicitly requested
- **Workload Identity**: Existing bindings are maintained

### Benefits:

- ✅ **First deployment**: Creates everything normally
- ✅ **Subsequent deployments**: Does nothing, preserves everything
- ✅ **No disruption**: Existing services continue working
- ✅ **Safe for production**: Can run `terraform apply --all` without concerns

## Bug Fixes in Latest Version

- **Fixed IAM Role Assignment**: Now applies roles to ALL service accounts, not just the first one
- **Removed Problematic Data Sources**: No more failures when service accounts don't exist
- **Simplified Architecture**: Clean, reliable approach that always works
- **Proper Error Handling**: Uses Terraform's built-in resource management

## Troubleshooting

### Service Account Already Exists
If you encounter "Service account already exists" errors:

1. **Manual Import** (Recommended):
   ```bash
   terraform import 'google_service_account.service_accounts["service-account-name"]' 'projects/project-id/serviceAccounts/service-account-name@project-id.iam.gserviceaccount.com'
   ```

2. **Import the service account key** (if keys were generated):
   ```bash
   terraform import 'google_service_account_key.service_account_keys["service-account-name"]' 'projects/project-id/serviceAccounts/service-account-name@project-id.iam.gserviceaccount.com/keys/key-id'
   ```

3. **Delete existing service account** (if safe to do so):
   ```bash
   gcloud iam service-accounts delete service-account-name@project-id.iam.gserviceaccount.com --project=project-id
   ```

### IAM Role Assignment Issues
- Ensure the project ID in `project_roles` matches your actual project
- Check that the roles exist and are properly formatted
- Verify you have sufficient permissions to assign the roles

## Migration

### From v2.0.4 and earlier:
- **No breaking changes** - the module maintains the same interface
- **Enhanced reliability** - better error handling and longer timeouts
- **Improved stability** - reduced race conditions and timing issues
- **Bug fixes** - IAM roles now apply to all service accounts
- **Simplified architecture** - removed problematic data source logic

## Best Practices

1. **Use descriptive names**: Choose meaningful service account names
2. **Limit permissions**: Only assign necessary IAM roles
3. **Monitor deployments**: Watch for timing-related issues
4. **Use version pinning**: Pin to specific module versions in production
5. **Test in staging**: Always test changes in a staging environment first
6. **Verify role assignments**: Ensure all service accounts receive the intended permissions

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| google | >= 5.0 |
| local | >= 2.0 |
| time | >= 0.9 |

## License

This module is licensed under the MIT License.

# Fast.BI Terraform Modules - Examples

This document provides practical examples of using the Fast.BI Terraform modules for various deployment scenarios.

## 📚 Table of Contents

- [Basic GCP Deployment](#basic-gcp-deployment)
- [Production GCP Setup](#production-gcp-setup)
- [AWS EKS Deployment](#aws-eks-deployment)
- [Multi-Environment Setup](#multi-environment-setup)
- [Cross-Cloud Configuration](#cross-cloud-configuration)
- [Security-Focused Deployment](#security-focused-deployment)
- [Cost-Optimized Setup](#cost-optimized-setup)

## Basic GCP Deployment

### Simple Single-Project Setup

This example creates a basic Fast.BI infrastructure in a single GCP project.

```hcl
# terragrunt.hcl
remote_state {
  backend = "gcs"
  config = {
    bucket = "fastbi-terraform-state"
    prefix = "${path_relative_to_include()}"
    project = "fastbi-demo"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "fastbi-demo"
  region  = "us-central1"
}
EOF
}
```

**Project Setup** (`project/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/create-project"
}

inputs = {
  project_id = "fastbi-demo"
  name       = "Fast.BI Demo"
}
```

**VPC Configuration** (`vpc/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/vpc-gke"
}

inputs = {
  project = "fastbi-demo"
  region  = "us-central1"
  name    = "fastbi-vpc"
}
```

**GKE Cluster** (`gke/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/gke-cluster"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  project     = "fastbi-demo"
  location    = "us-central1"
  region      = "us-central1"
  name        = "fastbi-cluster"
  network     = dependency.vpc.outputs.network
  subnetwork  = dependency.vpc.outputs.subnet
  
  min_node_count = "1"
  max_node_count = "5"
  
  cluster_secondary_range_name = "pods"
  service_secondary_range_name = "services"
}
```

## Production GCP Setup

### Enterprise-Grade Configuration

This example shows a production-ready setup with security, monitoring, and high availability.

```hcl
# terragrunt.hcl
remote_state {
  backend = "gcs"
  config = {
    bucket = "fastbi-prod-terraform-state"
    prefix = "${path_relative_to_include()}"
    project = "fastbi-production"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "fastbi-production"
  region  = "us-central1"
}
EOF
}
```

**Project with Organization** (`project/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/create-project"
}

inputs = {
  project_id = "fastbi-production"
  name       = "Fast.BI Production"
  org_id     = "123456789012"  # Your organization ID
  folder_id  = "folders/987654321098"  # Your folder ID
  
  labels = {
    environment = "production"
    team        = "data-platform"
    cost-center = "engineering"
  }
}
```

**Shared VPC** (`shared-vpc/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/shared-vpc"
}

inputs = {
  project = "fastbi-production"
  region  = "us-central1"
  vpc_name = "fastbi-shared-vpc"
  
  subnets = [
    {
      name                  = "fastbi-subnet-1"
      ip_cidr_range         = "10.0.1.0/24"
      region                = "us-central1"
      description           = "Fast.BI subnet in us-central1"
      enable_private_access = true
      secondary_ip_ranges = {
        pods     = "10.1.0.0/16"
        services = "10.2.0.0/16"
      }
    },
    {
      name                  = "fastbi-subnet-2"
      ip_cidr_range         = "10.0.2.0/24"
      region                = "us-central1"
      description           = "Fast.BI subnet in us-central1"
      enable_private_access = true
      secondary_ip_ranges = {
        pods     = "10.3.0.0/16"
        services = "10.4.0.0/16"
      }
    }
  ]
  
  cloud_nat = [
    {
      name     = "fastbi-nat"
      region   = "us-central1"
      external_address_name = "fastbi-nat-ip"
    }
  ]
}
```

**Production GKE Cluster** (`gke/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/gke-cluster"
}

dependencies {
  paths = ["../shared-vpc"]
}

inputs = {
  project     = "fastbi-production"
  location    = "us-central1"
  region      = "us-central1"
  name        = "fastbi-prod-cluster"
  network     = dependency.shared_vpc.outputs.network
  subnetwork  = dependency.shared_vpc.outputs.subnets["fastbi-subnet-1"]
  
  # Node configuration
  min_node_count = "3"
  max_node_count = "20"
  node_count     = "5"
  
  # Secondary ranges
  cluster_secondary_range_name = "pods"
  service_secondary_range_name = "services"
  
  # Security settings
  enable_private_nodes = true
  disable_public_endpoint = true
  enable_workload_identity = true
  enable_secrets_database_encryption = true
  
  # Master authorized networks
  master_authorized_networks_config = [{
    cidr_blocks = [{
      cidr_block   = "10.0.0.0/8"
      display_name = "corporate_network"
    }]
  }]
  
  # Monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Autoscaling
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling = true
  
  # Node pool configuration
  machine_type = "e2-standard-4"
  preemptible  = false
  spot         = false
  
  # Maintenance
  maintenance_start_time = "02:00"
  
  # Labels
  resource_labels = {
    environment = "production"
    team        = "data-platform"
    cost-center = "engineering"
  }
}
```

**Service Accounts** (`service-accounts/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/deploy_sa"
}

inputs = {
  project  = "fastbi-production"
  sa_names = [
    "fastbi-deploy",
    "fastbi-monitor", 
    "fastbi-data",
    "fastbi-airflow",
    "fastbi-dbt"
  ]
  
  project_roles = [
    "fastbi-production=>roles/storage.admin",
    "fastbi-production=>roles/logging.logWriter",
    "fastbi-production=>roles/monitoring.metricWriter",
    "fastbi-production=>roles/container.developer",
    "fastbi-production=>roles/bigquery.dataEditor",
    "fastbi-production=>roles/bigquery.jobUser"
  ]
  
  wid_mapping_to_sa = [
    {
      namespace   = "fastbi"
      k8s_sa_name = "fastbi-deploy"
      gcp_sa_name = "fastbi-deploy"
    },
    {
      namespace   = "airflow"
      k8s_sa_name = "airflow-worker"
      gcp_sa_name = "fastbi-airflow"
    }
  ]
}
```

**DNS Configuration** (`dns/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/cloud-dns"
}

inputs = {
  project = "fastbi-production"
  name    = "fastbi-production"
  domain  = "fastbi.company.com"
}
```

## AWS EKS Deployment

### Complete AWS Setup

This example shows how to deploy Fast.BI on AWS using EKS.

```hcl
# terragrunt.hcl
remote_state {
  backend = "s3"
  config = {
    bucket = "fastbi-aws-terraform-state"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-west-2"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
EOF
}
```

**VPC Configuration** (`vpc/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//aws_cloud/vpc"
}

inputs = {
  region = "us-west-2"
  name   = "fastbi-vpc"
  
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  cidr_block        = "10.0.0.0/16"
  
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
```

**EKS Cluster** (`eks/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//aws_cloud/eks"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  region         = "us-west-2"
  cluster_name   = "fastbi-cluster"
  cluster_version = "1.28"
  vpc_id         = dependency.vpc.outputs.vpc_id
  subnet_ids     = dependency.vpc.outputs.private_subnet_ids
  
  # Cluster endpoint configuration
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_endpoint_public_access_cidrs = ["10.0.0.0/8"]
  
  # Managed node groups
  eks_managed_node_groups = {
    main = {
      min_size     = 1
      max_size     = 10
      desired_size = 3
      instance_types = ["t3.medium"]
      
      labels = {
        Environment = "production"
        Team        = "data-platform"
      }
      
      taints = []
    }
    
    spot = {
      min_size     = 0
      max_size     = 5
      desired_size = 2
      instance_types = ["t3.medium", "t3.large"]
      
      labels = {
        Environment = "production"
        Team        = "data-platform"
        NodeType    = "spot"
      }
      
      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }
  
  # Add-ons
  vpc_cni_version = "v1.14.1-eksbuild.1"
  ebs_csi_version = "v1.24.1-eksbuild.1"
  coredns_version = "v1.10.1-eksbuild.1"
  kube_proxy_version = "v1.28.1-eksbuild.1"
}
```

## Multi-Environment Setup

### Development, Staging, and Production

This example shows how to set up multiple environments with different configurations.

**Directory Structure:**
```
environments/
├── dev/
│   ├── terragrunt.hcl
│   ├── gke/
│   └── service-accounts/
├── staging/
│   ├── terragrunt.hcl
│   ├── gke/
│   └── service-accounts/
└── production/
    ├── terragrunt.hcl
    ├── gke/
    └── service-accounts/
```

**Common Configuration** (`common.yaml`):
```yaml
# common.yaml
project_prefix: "fastbi"
region: "us-central1"
kubernetes_version: "1.28"

# Environment-specific overrides
environments:
  dev:
    min_node_count: 1
    max_node_count: 3
    machine_type: "e2-small"
    preemptible: true
    
  staging:
    min_node_count: 2
    max_node_count: 5
    machine_type: "e2-standard-2"
    preemptible: true
    
  production:
    min_node_count: 3
    max_node_count: 20
    machine_type: "e2-standard-4"
    preemptible: false
```

**Environment Configuration** (`dev/terragrunt.hcl`):
```hcl
# dev/terragrunt.hcl
locals {
  common_vars = yamldecode(file("${find_in_parent_folders("common.yaml")}"))
  environment = "dev"
}

remote_state {
  backend = "gcs"
  config = {
    bucket = "fastbi-terraform-state"
    prefix = "dev/${path_relative_to_include()}"
    project = "fastbi-dev"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "fastbi-dev"
  region  = "${local.common_vars.region}"
}
EOF
}

inputs = merge(
  local.common_vars.environments[local.environment],
  {
    project = "fastbi-dev"
    region  = local.common_vars.region
    name    = "fastbi-dev-cluster"
  }
)
```

**GKE Configuration** (`dev/gke/terragrunt.hcl`):
```hcl
# dev/gke/terragrunt.hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/gke-cluster"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  project     = "fastbi-dev"
  location    = "us-central1"
  region      = "us-central1"
  name        = "fastbi-dev-cluster"
  network     = dependency.vpc.outputs.network
  subnetwork  = dependency.vpc.outputs.subnet
  
  min_node_count = 1
  max_node_count = 3
  machine_type   = "e2-small"
  preemptible    = true
  
  cluster_secondary_range_name = "pods"
  service_secondary_range_name = "services"
}
```

## Cross-Cloud Configuration

### GCP + AWS Hybrid Setup

This example shows how to deploy components across multiple cloud providers.

**GCP Configuration** (`gcp/terragrunt.hcl`):
```hcl
# gcp/terragrunt.hcl
remote_state {
  backend = "gcs"
  config = {
    bucket = "fastbi-gcp-terraform-state"
    prefix = "${path_relative_to_include()}"
    project = "fastbi-gcp"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "fastbi-gcp"
  region  = "us-central1"
}
EOF
}
```

**AWS Configuration** (`aws/terragrunt.hcl`):
```hcl
# aws/terragrunt.hcl
remote_state {
  backend = "s3"
  config = {
    bucket = "fastbi-aws-terraform-state"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-west-2"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
EOF
}
```

**Cross-Cloud Zone** (`cross-cloud/terragrunt.hcl`):
```hcl
# cross-cloud/terragrunt.hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//aws_cloud/gcp_aws_zone"
}

dependencies {
  paths = ["../gcp", "../aws"]
}

inputs = {
  gcp_project = dependency.gcp.outputs.project_id
  aws_region  = dependency.aws.outputs.region
  
  # Cross-cloud connectivity configuration
  peering_config = {
    gcp_network = dependency.gcp.outputs.network
    aws_vpc_id  = dependency.aws.outputs.vpc_id
  }
}
```

## Security-Focused Deployment

### High-Security Configuration

This example shows a security-hardened deployment with private clusters, encryption, and strict access controls.

```hcl
# security/terragrunt.hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/gke-cluster"
}

inputs = {
  project     = "fastbi-secure"
  location    = "us-central1"
  region      = "us-central1"
  name        = "fastbi-secure-cluster"
  
  # Network security
  enable_private_nodes = true
  disable_public_endpoint = true
  master_ipv4_cidr_block = "172.16.0.0/28"
  
  # Access control
  master_authorized_networks_config = [{
    cidr_blocks = [{
      cidr_block   = "10.0.0.0/8"
      display_name = "corporate_network"
    }]
  }]
  
  # Encryption
  enable_secrets_database_encryption = true
  # secrets_encryption_kms_key = "projects/fastbi-secure/locations/global/keyRings/fastbi-ring/cryptoKeys/fastbi-key"
  
  # Identity and access
  enable_workload_identity = true
  enable_legacy_abac = false
  enable_client_certificate_authentication = false
  
  # Security features
  enable_dataplane_v2 = true
  enable_vertical_pod_autoscaling = true
  
  # Monitoring and logging
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Node security
  oauth_scopes = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]
  
  # Labels for security
  resource_labels = {
    environment = "secure"
    security-level = "high"
    compliance = "required"
  }
}
```

## Cost-Optimized Setup

### Budget-Conscious Configuration

This example shows how to optimize costs while maintaining functionality.

```hcl
# cost-optimized/terragrunt.hcl
terraform {
  source = "git::https://github.com/fast-bi/terraform-modules.git//google_cloud/gke-cluster"
}

inputs = {
  project     = "fastbi-budget"
  location    = "us-central1"
  region      = "us-central1"
  name        = "fastbi-budget-cluster"
  
  # Cost optimization
  min_node_count = 1
  max_node_count = 5
  machine_type   = "e2-small"
  preemptible    = true
  
  # Autoscaling
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling = true
  
  # Maintenance
  management_auto_repair  = true
  management_auto_upgrade = true
  
  # Labels for cost tracking
  resource_labels = {
    environment = "budget"
    cost-center = "engineering"
    budget-tier = "low"
  }
}
```

## Deployment Commands

### Deploy All Environments

```bash
# Deploy development
cd environments/dev
terragrunt run-all apply

# Deploy staging
cd ../staging
terragrunt run-all apply

# Deploy production
cd ../production
terragrunt run-all apply
```

### Deploy Specific Components

```bash
# Deploy only GKE cluster
cd environments/production/gke
terragrunt apply

# Deploy with specific target
terragrunt apply -target=google_container_cluster.primary
```

### Destroy Resources

```bash
# Destroy specific environment
cd environments/dev
terragrunt run-all destroy

# Destroy with confirmation
terragrunt destroy --terragrunt-non-interactive
```

## Best Practices

1. **Use Terragrunt for DRY Configuration**: Avoid repeating common configurations
2. **Implement Proper State Management**: Use remote state backends
3. **Use Dependencies**: Ensure proper resource ordering
4. **Implement Security**: Follow security best practices
5. **Monitor Costs**: Use labels and monitoring for cost tracking
6. **Version Control**: Keep all configurations in version control
7. **Test Changes**: Always test in development before production

For more information, visit the [Fast.BI Documentation](https://wiki.fast.bi).

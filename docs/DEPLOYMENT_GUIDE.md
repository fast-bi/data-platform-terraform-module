# Fast.BI Terraform Modules - Deployment Guide

This guide provides step-by-step instructions for deploying Fast.BI infrastructure using the Terraform modules in this repository.

## 📋 Prerequisites

### Required Tools

1. **Terraform** (>= 1.0)
   ```bash
   # Install via package manager
   brew install terraform  # macOS
   apt-get install terraform  # Ubuntu

   # Or download from https://www.terraform.io/downloads.html
   ```

2. **Terragrunt** (Recommended)
   ```bash
   # Install via package manager
   brew install terragrunt  # macOS

   # Or download from https://terragrunt.gruntwork.io/docs/getting-started/install/
   ```

3. **Cloud Provider CLI Tools**

   **Google Cloud SDK** (for GCP):
   ```bash
   # Install gcloud CLI
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL

   # Authenticate
   gcloud auth login
   gcloud auth application-default login
   ```

   **AWS CLI** (for AWS):
   ```bash
   # Install AWS CLI
   pip install awscli

   # Configure
   aws configure
   ```

### Required Permissions

#### GCP Permissions
- Project Owner or Editor role
- Service Account Admin
- Kubernetes Engine Admin
- Compute Network Admin
- IAM Admin (for service account creation)

#### AWS Permissions
- IAM permissions for EKS, EC2, VPC
- Route53 permissions (if using DNS modules)
- S3 permissions (for Terraform state)

## 🚀 Deployment Options

### Option 1: Complete GCP Deployment (Recommended) ✅ **100% Ready**

This option deploys a complete Fast.BI infrastructure on Google Cloud Platform.

#### Step 1: Project Setup

```bash
# Create a new GCP project
gcloud projects create fastbi-production --name="Fast.BI Production"

# Set the project
gcloud config set project fastbi-production

# Enable billing (required for GCP services)
# Go to: https://console.cloud.google.com/billing
```

#### Step 2: Create Terragrunt Configuration

Create a directory structure for your deployment:

```bash
mkdir -p fastbi-deployment/{gcp,aws}
cd fastbi-deployment/gcp
```

Create `terragrunt.hcl`:

```hcl
# terragrunt.hcl
remote_state {
  backend = "gcs"
  config = {
    bucket = "fastbi-terraform-state"
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

#### Step 3: Deploy Infrastructure

Create the following directory structure and files:

```
gcp/
├── terragrunt.hcl
├── project/
│   └── terragrunt.hcl
├── vpc/
│   └── terragrunt.hcl
├── gke/
│   └── terragrunt.hcl
└── service-accounts/
    └── terragrunt.hcl
```

**Project Configuration** (`project/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/create-project"
}

inputs = {
  project_id = "fastbi-production"
  name       = "Fast.BI Production"
  org_id     = "your-org-id"  # Optional
  folder_id  = "your-folder-id"  # Optional
}
```

**VPC Configuration** (`vpc/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/vpc-gke"
}

inputs = {
  project = "fastbi-production"
  region  = "us-central1"
  name    = "fastbi-vpc"
}
```

**GKE Configuration** (`gke/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/gke-cluster"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  project     = "fastbi-production"
  location    = "us-central1"
  region      = "us-central1"
  name        = "fastbi-cluster"
  network     = dependency.vpc.outputs.network
  subnetwork  = dependency.vpc.outputs.subnet

  min_node_count = "3"
  max_node_count = "10"

  cluster_secondary_range_name = "pods"
  service_secondary_range_name = "services"

  enable_private_nodes = true
  enable_workload_identity = true
}
```

**Service Accounts** (`service-accounts/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/deploy_sa"
}

inputs = {
  project  = "fastbi-production"
  sa_names = ["fastbi-deploy", "fastbi-monitor", "fastbi-data"]

  project_roles = [
    "fastbi-production=>roles/storage.admin",
    "fastbi-production=>roles/logging.logWriter",
    "fastbi-production=>roles/monitoring.metricWriter",
    "fastbi-production=>roles/container.developer"
  ]
}
```

#### Step 4: Deploy

```bash
# Deploy all infrastructure
terragrunt run-all apply

# Or deploy step by step
cd project && terragrunt apply
cd ../vpc && terragrunt apply
cd ../gke && terragrunt apply
cd ../service-accounts && terragrunt apply
```

### Option 2: AWS EKS Deployment 🚧 **80% Ready**

This option deploys Fast.BI infrastructure on Amazon Web Services. Core modules are available with additional features coming soon.

#### Step 1: AWS Setup

```bash
# Configure AWS CLI
aws configure

# Create S3 bucket for Terraform state
aws s3 mb s3://fastbi-terraform-state
```

#### Step 2: Create Terragrunt Configuration

Create `terragrunt.hcl`:

```hcl
# terragrunt.hcl
remote_state {
  backend = "s3"
  config = {
    bucket = "fastbi-terraform-state"
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

#### Step 3: Deploy Infrastructure

**VPC Configuration** (`vpc/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//aws_cloud/vpc"
}

inputs = {
  region = "us-west-2"
  name   = "fastbi-vpc"
}
```

**EKS Configuration** (`eks/terragrunt.hcl`):
```hcl
terraform {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//aws_cloud/eks"
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

  eks_managed_node_groups = {
    main = {
      min_size     = 1
      max_size     = 10
      desired_size = 3
      instance_types = ["t3.medium"]
    }
  }
}
```

### Option 3: Hybrid Deployment 🚧 **Partial Support**

For organizations using multiple cloud providers, you can deploy components across clouds. Currently supports GCP + AWS integration:

```bash
# Deploy networking in GCP
cd gcp/vpc && terragrunt apply

# Deploy compute in AWS
cd aws/eks && terragrunt apply

# Configure cross-cloud connectivity
cd gcp/gcp_aws_zone && terragrunt apply
```

## 🔧 Configuration Options

### Environment-Specific Configurations

Create different configurations for different environments:

```
environments/
├── dev/
│   ├── terragrunt.hcl
│   └── gke/
├── staging/
│   ├── terragrunt.hcl
│   └── gke/
└── production/
    ├── terragrunt.hcl
    └── gke/
```

### Custom Variables

Use `terragrunt.hcl` to define common variables:

```hcl
locals {
  common_vars = yamldecode(file("${find_in_parent_folders("common.yaml")}"))
}

inputs = merge(
  local.common_vars,
  {
    # Environment-specific overrides
    min_node_count = 1  # Smaller for dev
  }
)
```

## 🛡️ Security Considerations

### Network Security

- Use private clusters when possible
- Implement proper firewall rules
- Enable VPC Flow Logs for monitoring
- Use Cloud NAT for outbound internet access

### Identity and Access Management

- Create dedicated service accounts for each component
- Use Workload Identity (GCP) or IRSA (AWS)
- Implement least privilege access
- Enable audit logging

### Data Protection

- Enable encryption at rest and in transit
- Use customer-managed encryption keys
- Implement backup and disaster recovery
- Regular security scanning

## 📊 Monitoring and Observability

### Enable Monitoring

```hcl
# In your GKE configuration
inputs = {
  # ... other configuration

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Enable monitoring addons
  enable_vertical_pod_autoscaling = true
}
```

### Set Up Alerts

1. **Cluster Health**: Monitor cluster and node health
2. **Resource Usage**: Track CPU, memory, and storage usage
3. **Security Events**: Monitor for security-related events
4. **Cost Optimization**: Track resource costs and usage

## 🔄 Maintenance and Updates

### Regular Maintenance

1. **Update Kubernetes versions** regularly
2. **Rotate service account keys** periodically
3. **Review and update IAM permissions**
4. **Monitor and optimize costs**

### Backup Strategy

1. **Terraform state**: Store in versioned, encrypted backends
2. **Cluster backups**: Enable automated backups
3. **Configuration**: Version control all configurations
4. **Documentation**: Keep deployment documentation updated

## 🆘 Troubleshooting

### Common Issues

1. **Permission Errors**
   - Verify IAM roles and permissions
   - Check service account configurations
   - Ensure proper authentication

2. **Network Issues**
   - Verify VPC and subnet configurations
   - Check firewall rules
   - Validate DNS settings

3. **Resource Limits**
   - Check cloud provider quotas
   - Verify resource availability in regions
   - Monitor resource usage

### Getting Help

- Check module-specific documentation
- Review Terraform and Terragrunt logs
- Consult cloud provider documentation
- Join the Fast.BI community for support

## 📅 Roadmap

### Current Status
- **Google Cloud Platform**: ✅ 100% Complete - Production ready
- **Amazon Web Services**: 🚧 80% Complete - Core modules available
- **Microsoft Azure**: 📅 Q4 2025 - Planning phase
- **Oracle Cloud**: 📅 Q2 2026 - Early planning phase

### Upcoming Features
- **Azure Support**: Complete AKS, VNet, and security modules
- **Oracle Cloud Support**: OKE, VCN, and compartment management
- **Enhanced AWS Modules**: Additional services and integrations
- **Cross-Cloud Connectivity**: Advanced multi-cloud networking

## 📚 Next Steps

After deploying the infrastructure:

1. **Deploy Fast.BI Platform**: Use the Fast.BI CLI to deploy the platform
2. **Configure Data Sources**: Set up your data connections
3. **Create Data Pipelines**: Build your first data transformations
4. **Set Up Monitoring**: Configure alerts and dashboards
5. **Train Your Team**: Get your team familiar with the platform

For more information, visit the [Fast.BI Documentation](https://wiki.fast.bi).

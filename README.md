# Fast.BI Terraform Modules

<p align="center">
  <a href="https://fast.bi">
    <img src="https://fast.bi/logo.png" alt="Fast.BI Logo" width="200">
  </a>
</p>

<p align="center">
  <strong>Infrastructure as Code for Fast.BI Data Platform</strong>
</p>

This repository contains production-ready Terraform modules for deploying the Fast.BI data development platform infrastructure across multiple cloud providers. These modules are designed to be used with Terragrunt or directly from Terraform configurations.

**Repository**: `fast-bi/data-platform-terraform-module`

## 🚀 What is Fast.BI?

Fast.BI is an end-to-end data development platform that consolidates the entire modern data stack into a unified experience. It provides a wrapper on top of popular data services, connecting everything seamlessly with intelligent automation and enterprise-ready features.

## 📦 Available Modules

### Google Cloud Platform (GCP) Modules ✅ **100% Complete**

#### Core Infrastructure
- **[`gke-cluster`](google_cloud/gke-cluster/)** - Google Kubernetes Engine cluster with secondary subnets for pods and services
- **[`vpc-gke`](google_cloud/vpc-gke/)** - VPC with secondary subnets for GKE pod and service networks
- **[`shared-vpc`](google_cloud/shared-vpc/)** - Shared VPC for multi-project architectures
- **[`vpc-gke-shared`](google_cloud/vpc-gke-shared/)** - VPC configuration for shared GKE clusters

#### Security & Access
- **[`deploy_sa`](google_cloud/deploy_sa/)** - Service account creation with IAM roles and workload identity
- **[`iam-add`](google_cloud/iam-add/)** - IAM role and policy management
- **[`iap-brand`](google_cloud/iap-brand/)** - Identity-Aware Proxy brand configuration
- **[`bastion_host`](google_cloud/bastion_host/)** - Secure bastion host for private cluster access

#### Networking & DNS
- **[`cloud-dns`](google_cloud/cloud-dns/)** - Cloud DNS zone management
- **[`cloud-dns-recordset`](google_cloud/cloud-dns-recordset/)** - DNS record management
- **[`external-ip`](google_cloud/external-ip/)** - External IP address allocation
- **[`fw-add`](google_cloud/fw-add/)** - Firewall rule management

#### Development & Operations
- **[`artifact-registry`](google_cloud/artifact-registry/)** - Container registry for Docker images
- **[`composer`](google_cloud/composer/)** - Managed Apache Airflow environment
- **[`workspace_user`](google_cloud/workspace_user/)** - Google Workspace user management
- **[`kubeconfig`](google_cloud/kubeconfig/)** - Kubernetes configuration generation

#### Project Management
- **[`create-project`](google_cloud/create-project/)** - GCP project creation and configuration
- **[`create-ou-folder`](google_cloud/create-ou-folder/)** - Organization unit and folder structure
- **[`enable_apis`](google_cloud/enable_apis/)** - Google Cloud API enablement

### Amazon Web Services (AWS) Modules 🚧 **80% Complete**

#### Core Infrastructure
- **[`eks`](aws_cloud/eks/)** - Amazon Elastic Kubernetes Service cluster with managed and self-managed node groups
- **[`vpc`](aws_cloud/vpc/)** - VPC with public and private subnets for EKS deployment
- **[`gcp_aws_zone`](aws_cloud/gcp_aws_zone/)** - Cross-cloud zone configuration for GCP-AWS integration

### Microsoft Azure Modules 📅 **Coming Q4 2025**

Azure modules are planned for Q4 2025. Planned modules include:
- **AKS** - Azure Kubernetes Service cluster
- **VNet** - Virtual Network with subnets
- **Resource Groups** - Resource group management
- **Storage Accounts** - Azure Storage configuration
- **Key Vault** - Secrets management
- **Service Principals** - Identity management

### Oracle Cloud Infrastructure (OCI) Modules 📅 **Coming Q2 2026**

Oracle Cloud modules are planned for Q2 2026. Planned modules include:
- **OKE** - Oracle Kubernetes Engine cluster
- **VCN** - Virtual Cloud Network
- **Compartments** - Compartment management
- **Object Storage** - OCI Object Storage
- **Vault** - Secrets management
- **IAM** - Identity and Access Management

## 🏗️ Architecture Overview

The modules are designed to support the Fast.BI platform architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    Fast.BI Platform                        │
├─────────────────────────────────────────────────────────────┤
│  Data Services: Airbyte, dbt, Airflow, DataHub, etc.      │
├─────────────────────────────────────────────────────────────┤
│  Kubernetes Cluster (GKE/EKS)                              │
├─────────────────────────────────────────────────────────────┤
│  Cloud Infrastructure (VPC, IAM, DNS, Storage)             │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) (recommended)
- Cloud provider CLI tools configured:
  - [gcloud](https://cloud.google.com/sdk/docs/install) for GCP
  - [aws-cli](https://aws.amazon.com/cli/) for AWS

### Basic Usage

#### Using with Terragrunt (Recommended)

```hcl
# terragrunt.hcl
terraform {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/gke-cluster"
}

inputs = {
  project     = "my-fastbi-project"
  location    = "us-central1"
  region      = "us-central1"
  name        = "fastbi-cluster"
  network     = "projects/my-project/global/networks/fastbi-vpc"
  subnetwork  = "projects/my-project/regions/us-central1/subnetworks/fastbi-subnet"
  
  min_node_count = "1"
  max_node_count = "10"
  
  cluster_secondary_range_name = "pods"
  service_secondary_range_name = "services"
}
```

#### Using with Terraform

```hcl
module "gke_cluster" {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/gke-cluster"
  
  project     = "my-fastbi-project"
  location    = "us-central1"
  region      = "us-central1"
  name        = "fastbi-cluster"
  network     = "projects/my-project/global/networks/fastbi-vpc"
  subnetwork  = "projects/my-project/regions/us-central1/subnetworks/fastbi-subnet"
  
  min_node_count = "1"
  max_node_count = "10"
  
  cluster_secondary_range_name = "pods"
  service_secondary_range_name = "services"
}
```

## 📚 Module Documentation

Each module includes comprehensive documentation:

- **Input variables** - All configurable parameters with descriptions
- **Output values** - Resources and values exposed by the module
- **Usage examples** - Common configuration patterns
- **Requirements** - Provider and Terraform version requirements

### Key Features

- **Production Ready**: Battle-tested modules used in production environments
- **Security First**: Built-in security best practices and hardening
- **Multi-Cloud**: Support for GCP and AWS with consistent interfaces
- **Modular Design**: Mix and match modules for custom architectures
- **Comprehensive**: Covers networking, security, compute, and data services

## 🔧 Configuration Examples

### Complete GCP Deployment

```hcl
# 1. Create project and enable APIs
module "project" {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/create-project"
  
  project_id = "fastbi-production"
  name       = "Fast.BI Production"
}

module "apis" {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/enable_apis"
  
  project = module.project.project_id
  apis    = ["container.googleapis.com", "compute.googleapis.com"]
}

# 2. Create VPC and networking
module "vpc" {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/vpc-gke"
  
  project = module.project.project_id
  region  = "us-central1"
  name    = "fastbi-vpc"
}

# 3. Create GKE cluster
module "gke" {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/gke-cluster"
  
  project     = module.project.project_id
  location    = "us-central1"
  region      = "us-central1"
  name        = "fastbi-cluster"
  network     = module.vpc.network
  subnetwork  = module.vpc.subnet
  
  min_node_count = "3"
  max_node_count = "10"
  
  cluster_secondary_range_name = "pods"
  service_secondary_range_name = "services"
}

# 4. Create service accounts
module "service_accounts" {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/deploy_sa"
  
  project  = module.project.project_id
  sa_names = ["fastbi-deploy", "fastbi-monitor"]
  
  project_roles = [
    "fastbi-production=>roles/storage.admin",
    "fastbi-production=>roles/logging.logWriter"
  ]
}
```

### AWS EKS Deployment

```hcl
# 1. Create VPC
module "vpc" {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//aws_cloud/vpc"
  
  region = "us-west-2"
  name   = "fastbi-vpc"
}

# 2. Create EKS cluster
module "eks" {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//aws_cloud/eks"
  
  region         = "us-west-2"
  cluster_name   = "fastbi-cluster"
  cluster_version = "1.28"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  
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

## 🛡️ Security Features

All modules include security best practices:

- **Network Security**: Private clusters, VPC isolation, firewall rules
- **Identity & Access**: IAM roles, service accounts, workload identity
- **Encryption**: Secrets encryption, disk encryption, network encryption
- **Compliance**: CIS benchmarks, security scanning, audit logging

## 🔄 Versioning

Modules follow semantic versioning:

- **Major versions**: Breaking changes requiring migration
- **Minor versions**: New features, backward compatible
- **Patch versions**: Bug fixes, backward compatible

### Using Specific Versions

```hcl
module "gke_cluster" {
  source = "git::https://github.com/fast-bi/data-platform-terraform-module.git//google_cloud/gke-cluster?ref=v1.2.0"
  # ... configuration
}
```

## 🤝 Contributing

We welcome contributions to improve these modules:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**: Follow our coding standards
4. **Add tests**: Ensure your changes work correctly
5. **Submit a pull request**: Describe your changes clearly

### Development Guidelines

- Follow [Terraform best practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- Use consistent naming conventions
- Include comprehensive documentation
- Add examples for new features
- Test with multiple cloud provider versions

## 📋 Requirements

### Terraform
- **Terraform**: >= 1.0
- **Google Provider**: >= 5.0 (for GCP modules)
- **AWS Provider**: >= 5.0 (for AWS modules)

### Cloud Provider Permissions

#### GCP
- Project Owner or Editor role
- Service Account Admin
- Kubernetes Engine Admin
- Compute Network Admin

#### AWS
- IAM permissions for EKS, EC2, VPC
- Route53 permissions (if using DNS modules)

## 🆘 Support

- **Documentation**: Check module-specific README files
- **Issues**: [GitHub Issues](https://github.com/fast-bi/data-platform-terraform-module/issues)
- **Discussions**: [GitHub Discussions](https://github.com/fast-bi/data-platform-terraform-module/discussions)
- **Community**: [Fast.BI Community](https://fast.bi/community)

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

## 🙏 Acknowledgments

These modules are built on top of:
- [Google Cloud Foundation Fabric](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric)
- [AWS EKS Blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints)
- [Terraform AWS EKS Module](https://github.com/terraform-aws-modules/terraform-aws-eks)

---

<p align="center">
  <strong>Ready to deploy Fast.BI infrastructure?</strong><br>
  <a href="https://fast.bi">Get Started with Fast.BI</a> • 
  <a href="https://wiki.fast.bi">Documentation</a> • 
  <a href="https://github.com/fast-bi/data-platform-terraform-module/issues">Report Issues</a>
</p>
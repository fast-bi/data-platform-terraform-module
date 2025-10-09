variable "region" {
  description = "(Optional) AWS Region where the provider will operate. The Region must be set. Can also be set with either the AWS_REGION or AWS_DEFAULT_REGION environment variables, or via a shared config file parameter region if profile is used. If credentials are retrieved from the EC2 Instance Metadata Service, the Region can also be retrieved from the metadata."
  type        = string
}
variable "profile" {
  description = "(Optional) AWS profile name as set in the shared configuration and credentials files. Can also be set using either the environment variables AWS_PROFILE or AWS_DEFAULT_PROFILE."
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version for the cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If control_plane_subnet_ids is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
}

variable "enable_irsa" {
  description = "	Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "self_managed_node_groups" {
  description = "Map of self-managed node group definitions to create"
  type        = any
  default     = {}
}

variable "eks_managed_node_groups" {
  description = "Map of managed node group definitions to create"
  type        = any
  default     = {}
}

variable "vpc_cni_version" {
  description = "Version of the VPC CNI add-on"
  type        = string
  default     = null # null means latest version
}

variable "ebs_csi_version" {
  description = "Version of the EBS CSI Driver add-on"
  type        = string
  default     = null # null means latest version
}

variable "cluster_endpoint_private_access" {
  description = "(Optional) Whether the Amazon EKS private API server endpoint is enabled. Default is false."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = " (Optional) Whether the Amazon EKS public API server endpoint is enabled. Default is true."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = " (Optional) List of security group IDs for the cross-account elastic network interfaces that Amazon EKS creates to use to allow communication between your worker nodes and the Kubernetes control plane."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "coredns_version" {
  description = "CoreDNS add-on version"
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "Kube Proxy add-on version"
  type        = string
  default     = null
}

variable "pod_identity_agent_version" {
  description = "Pod Identity Agent add-on version"
  type        = string
  default     = null
}

variable "node_monitoring_agent_version" {
  description = "EKS Node Monitoring Agent add-on version"
  type        = string
  default     = null # Use the latest version available
}

variable "metrics_server_version" {
  description = "Metrics Server add-on version"
  type        = string
  default     = null # Use appropriate version for K8s 1.32
}

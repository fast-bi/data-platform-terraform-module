# Security Groups
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  # Add rules for cluster communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-sg"
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # Node to node communication
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Allow cluster to communicate with nodes
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}


##TODO: update to fixed version of bottlerocket


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # VPC and subnet config
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  # Enable OIDC provider for IRSA
  cluster_security_group_id             = aws_security_group.eks_cluster.id
  cluster_additional_security_group_ids = [aws_security_group.eks_nodes.id]
  # Use private endpoints for enhanced security
  enable_cluster_creator_admin_permissions = true
  cluster_upgrade_policy = {
    support_type = "STANDARD"
  }
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access # Can be false for strict security
  eks_managed_node_group_defaults = {
    vpc_security_group_ids = [aws_security_group.eks_nodes.id]
  }
  enable_irsa                          = var.enable_irsa
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  self_managed_node_groups             = var.self_managed_node_groups
  eks_managed_node_groups              = var.eks_managed_node_groups
}


# Install VPC CNI add-on with custom role
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"

  # Specify the custom service account configuration
  service_account_role_arn = module.vpc_cni_irsa.iam_role_arn

  # Optional configuration
  addon_version               = var.vpc_cni_version
  resolve_conflicts_on_create = "OVERWRITE"
  configuration_values = jsonencode({
    env = {
      # Increase pods per node (custom networking)
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"

      # Enable security groups for pods if needed
      ENABLE_POD_ENI = "true"
    }
  })
  depends_on = [
    module.eks,
    module.vpc_cni_irsa
  ]
}


# Install EBS CSI Driver add-on with custom role
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = module.eks.cluster_name
  addon_name   = "aws-ebs-csi-driver"

  # Specify the custom service account configuration
  service_account_role_arn = module.ebs_csi_irsa.iam_role_arn

  # Optional configuration
  addon_version               = var.ebs_csi_version
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    module.eks,
    module.ebs_csi_irsa
  ]
}

# CoreDNS Add-on
resource "aws_eks_addon" "coredns" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  addon_version               = var.coredns_version
  service_account_role_arn    = module.coredns_irsa.iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    module.eks,
    module.coredns_irsa
  ]

}

# Kube Proxy Add-on
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = var.kube_proxy_version
  service_account_role_arn    = module.kube_proxy_irsa.iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    module.eks,
    module.kube_proxy_irsa
  ]
}

# Install AWS Load Balancer Controller with Helm and custom role
resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.load_balancer_controller_irsa.iam_role_arn
  }

  depends_on = [
    module.eks,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy
  ]
}

# Pod Identity Agent Add-on
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = var.pod_identity_agent_version
  service_account_role_arn    = module.pod_identity_agent_irsa.iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# AWS Node Monitoring Agent Add-on
resource "aws_eks_addon" "eks_node_monitoring_agent" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "eks-node-monitoring-agent"
  addon_version               = var.node_monitoring_agent_version
  service_account_role_arn    = module.node_monitoring_agent_irsa.iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# Metrics Server Add-on
resource "aws_eks_addon" "metrics_server" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "metrics-server"
  addon_version               = var.metrics_server_version
  service_account_role_arn    = module.metrics_server_irsa.iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

# GP3 Storage Class
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "gp3"
    # You can also specify iops and throughput for gp3
    # iops      = "3000"
    # throughput = "125"
  }

  # Make this the default storage class
  # To do this, we need to also remove the default flag from the existing default storage class
  depends_on = [
    kubernetes_annotations.remove_default_storage_class
  ]
}

# Remove the default flag from the existing gp2 storage class
resource "kubernetes_annotations" "remove_default_storage_class" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  force = true

  # Only apply this after the EBS CSI driver is installed
  depends_on = [
    aws_eks_addon.ebs_csi
  ]
}

# Install Cluster Autoscaler using Helm
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler_irsa.iam_role_arn
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "extraArgs.scale-down-enabled"
    value = "true"
  }
  set {
    name  = "extraArgs.min-replica-count"
    value = "0"
  }
}

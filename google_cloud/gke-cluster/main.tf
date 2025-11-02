# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A GKE CLUSTER
# This module deploys a GKE cluster, a managed, production-ready environment for deploying containerized applications.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.13"
}

locals {
  workload_identity_config = !var.enable_workload_identity ? [] : var.identity_namespace == null ? [{
    identity_namespace = "${var.project}.svc.id.goog" }] : [{ identity_namespace = var.identity_namespace
  }]
}

locals {
  cluster_name = var.name
}
data "google_project" "project" {
  project_id = var.project
}


resource "google_project_iam_member" "service_account-roles" {
  count   = var.enable_secrets_database_encryption != false ? 1 : 0
  project = var.project
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}
# ---------------------------------------------------------------------------------------------------------------------
# Create secret key for Cluster database encryption
# ---------------------------------------------------------------------------------------------------------------------
resource "google_kms_key_ring" "keyring" {
  count    = var.enable_secrets_database_encryption ? 1 : 0
  name     = "${var.env}-gke-cluster-keyring-cluster"
  location = var.region
  project  = var.project

}

resource "google_kms_crypto_key" "cluster-encryption-key" {
  count = var.enable_secrets_database_encryption ? 1 : 0
  name  = "cluster-encryption-key"

  key_ring = google_kms_key_ring.keyring[0].id
  depends_on = [
    google_kms_key_ring.keyring
  ]
}


# ---------------------------------------------------------------------------------------------------------------------
# Create the GKE Cluster
# We want to make a cluster with no node pools, and manage them all with the fine-grained google_container_node_pool resource
# ---------------------------------------------------------------------------------------------------------------------


resource "google_container_cluster" "cluster" {
  provider       = google
  name           = local.cluster_name
  description    = var.description
  node_locations = var.node_locations
  project        = var.project
  location       = var.location
  network        = var.network
  subnetwork     = var.subnetwork

  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service
  min_master_version = local.kubernetes_version


  # Whether to enable legacy Attribute-Based Access Control (ABAC). RBAC has significant security advantages over ABAC.
  enable_legacy_abac = var.enable_legacy_abac

  # The API requires a node pool or an initial count to be defined; that initial count creates the
  # "default node pool" with that # of nodes.
  # So, we need to set an initial_node_count of 1. This will make a default node
  # pool with server-defined defaults that Terraform will immediately delete as
  # part of Create. This leaves us in our desired state- with a cluster master
  # with no node pools.
  remove_default_node_pool = true

  initial_node_count    = 1
  
  # Configure the initial default node pool to use the specified machine type
  # This prevents GKE from using default e2-medium instances that may not be available
  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50
    disk_type = "pd-standard"
    image_type = "COS_CONTAINERD"
  }
  enable_shielded_nodes = false
  # If we have an alternative default service account to use, set on the node_config so that the default node pool can
  # be created successfully.
  dynamic "node_config" {
    # Ideally we can do `for_each = var.alternative_default_service_account != null ? [object] : []`, but due to a
    # terraform bug, this doesn't work. See https://github.com/hashicorp/terraform/issues/21465. So we simulate it using
    # a for expression.
    for_each = [
      for x in [var.alternative_default_service_account] : x if var.alternative_default_service_account != null
    ]

    content {
      service_account = node_config.value
    }
  }

  # ip_allocation_policy.use_ip_aliases defaults to true, since we define the block `ip_allocation_policy`
  ip_allocation_policy {
    // Choose the range, but let GCP pick the IPs within the range
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.service_secondary_range_name
    #cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    #services_ipv4_cidr_block = var.services_ipv4_cidr_block

  }

  # We can optionally control access to the cluster
  # See https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters
  private_cluster_config {
    enable_private_endpoint = var.disable_public_endpoint
    enable_private_nodes    = var.enable_private_nodes

    master_ipv4_cidr_block = var.master_ipv4_cidr_block
  }
  release_channel {
    channel = "REGULAR"
  }
  addons_config {
    http_load_balancing {
      disabled = !var.http_load_balancing
    }

    horizontal_pod_autoscaling {
      disabled = !var.horizontal_pod_autoscaling
    }

    # network_policy_config {
    #   disabled = ! var.enable_dataplane_v2
    # }
  }

  # network_policy {
  #   enabled = var.enable_dataplane_v2

  #   # Tigera (Calico Felix) is the only provider
  #   provider = var.enable_dataplane_v2 ? "PROVIDER_UNSPECIFIED" : "CALICO"
  # }
  datapath_provider = var.enable_dataplane_v2 ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"
  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }

  #master_auth {
  #username = var.basic_auth_username
  #password = var.basic_auth_password
  #}

  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", [])
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = lookup(cidr_blocks.value, "display_name", null)
        }
      }
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }

  lifecycle {
    ignore_changes = [
      # Since we provide `remove_default_node_pool = true`, the `node_config` is only relevant for a valid construction of
      # the GKE cluster in the initial creation. As such, any changes to the `node_config` should be ignored.
      node_config,
    ]
  }

  # If var.gsuite_domain_name is non-empty, initialize the cluster with a G Suite security group
  dynamic "authenticator_groups_config" {
    for_each = [
      for x in [var.gsuite_domain_name] : x if var.gsuite_domain_name != null
    ]

    content {
      security_group = "gke-security-groups@${authenticator_groups_config.value}"
    }
  }

  # If var.secrets_encryption_kms_key is non-empty, create ´database_encryption´ -block to encrypt secrets at rest in etcd
  dynamic "database_encryption" {
    for_each = [
      for x in [var.enable_secrets_database_encryption] : x if var.enable_secrets_database_encryption != false
    ]

    content {
      state    = "ENCRYPTED"
      key_name = google_kms_crypto_key.cluster-encryption-key[0].id
    }
  }

  dynamic "workload_identity_config" {
    for_each = local.workload_identity_config

    content {
      workload_pool = "${var.project}.svc.id.goog"
    }
  }

  resource_labels = var.resource_labels
  deletion_protection = var.deletion_protection
  depends_on = [
    google_kms_crypto_key.cluster-encryption-key,
    time_sleep.wait_for_gke_service_account,
    module.iam_user
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Prepare locals to keep the code cleaner
# ---------------------------------------------------------------------------------------------------------------------

locals {
  latest_version     = data.google_container_engine_versions.location.latest_master_version
  kubernetes_version = var.kubernetes_version != "latest" ? var.kubernetes_version : local.latest_version
  network_project    = var.network_project != "" ? var.network_project : var.project
}

# ---------------------------------------------------------------------------------------------------------------------
# Pull in data
# ---------------------------------------------------------------------------------------------------------------------

// Get available master versions in our location to determine the latest version
data "google_container_engine_versions" "location" {
  location = var.location
  project  = var.project
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_container_cluster.cluster]

  create_duration = "30s"
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE A NODE POOL
# ---------------------------------------------------------------------------------------------------------------------

resource "google_container_node_pool" "node_pool" {
  provider = google-beta
  name     = "private-pool"
  project  = var.project
  location = var.location
  cluster  = local.cluster_name
  version  = var.kubernetes_nodes_version

  initial_node_count = "1"
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }



  management {
    auto_repair  = var.management_auto_repair
    auto_upgrade = var.management_auto_upgrade
  }

  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = var.machine_type

    labels = {
      private-pools = "true"
    }

    # Add a private tag to the instances. See the network access tier table for full details:
    # https://github.com/gruntwork-io/terraform-google-network/tree/master/modules/vpc-network#access-tier
    tags = [
      var.private_tag,
      "private-pool",
    ]

    disk_size_gb    = "50"
    disk_type       = "pd-standard"
    preemptible     = var.preemptible
    spot            = var.spot
    service_account = google_service_account.gke_service_account.email

    oauth_scopes = var.oauth_scopes
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
  depends_on = [time_sleep.wait_30_seconds]
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD IAM ROLES FOR SERVICE ACCOUNT AT SHARED VPC PROJECT
# ---------------------------------------------------------------------------------------------------------------------

# Data source to ensure service account exists before assigning IAM roles
data "google_service_account" "gke_service_account" {
  account_id = var.cluster_service_account_name
  project    = var.project

  depends_on = [time_sleep.wait_for_gke_service_account]
}

# Wait for service account to be fully propagated
resource "time_sleep" "wait_for_service_account" {
  depends_on      = [data.google_service_account.gke_service_account]
  create_duration = "30s"
}

# Only create IAM bindings if we're using a shared VPC (network_project != project)
module "iam_user" {
  source                       = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/iam-service-account?ref=v45.0.0"
  project_id                   = var.network_project
  name                         = data.google_service_account.gke_service_account.account_id
  create_ignore_already_exists = true

  # Non-authoritative roles granted *to* the service account on the shared VPC project
  iam_project_roles = {
    "${var.network_project}" = [
      "roles/compute.networkAdmin",
      "roles/container.hostServiceAgentUser",
      "roles/container.serviceAgent",
      "roles/compute.orgFirewallPolicyAdmin"
    ]
  }

  depends_on = [time_sleep.wait_for_service_account]
}


# 55477447349@cloudservices.gserviceaccount.com
# ---------------------------------------------------------------------------------------------------------------------
# CREATE A PROJECT SERVICE ACCOUNT TO USE WITH THE SHARED NETWORK
# -


# ---------------------------------------------------------------------------------------------------------------------
# CREATE A CUSTOM SERVICE ACCOUNT TO USE WITH THE GKE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

# Create the GKE service account locally for better control
resource "google_service_account" "gke_service_account" {
  account_id   = var.cluster_service_account_name
  project      = var.project
  display_name = var.cluster_service_account_name
  description  = var.cluster_service_account_description
}

# Assign roles to the service account
resource "google_project_iam_member" "gke_service_account_roles" {
  for_each = toset(var.service_account_roles)

  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"

  depends_on = []
}

# Wait for service account and roles to be fully created
resource "time_sleep" "wait_for_gke_service_account" {
  depends_on = [
    google_service_account.gke_service_account,
    google_project_iam_member.gke_service_account_roles
  ]
  create_duration = "30s"
}


data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
  status  = "UP"
}

resource "kubernetes_storage_class" "regionalpd-storageclass" {
  depends_on = [null_resource.k8s_sc_patcher]
  metadata {
    name = "regionalpd-storageclass"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "pd.csi.storage.gke.io"
  reclaim_policy      = "Retain"
  parameters = {
    type             = "pd-balanced",
    replication-type = "regional-pd"
  }
  volume_binding_mode = "WaitForFirstConsumer"
  allowed_topologies {
    match_label_expressions {
      key    = "topology.gke.io/zone"
      values = data.google_compute_zones.available.names
    }
  }
}

resource "local_file" "ca" {
  depends_on = [google_container_cluster.cluster]
  content    = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
  filename   = "ca.pem"
}

resource "null_resource" "k8s_sc_patcher" {
  depends_on = [local_file.ca]

  provisioner "local-exec" {
    command = <<EOH
kubectl \
  --server="${format("https://%s", google_container_cluster.cluster.endpoint)}" \
  --certificate-authority="ca.pem"\
  --token="${data.google_client_config.provider.access_token}" \
  patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
  EOH
  }
}

data "google_project" "project" {
}

output "project_number" {
  value = data.google_project.project.number
}

locals {
  sa_name       = "${var.name}-sa"
  composer_name = "${var.prefix}-${var.name}-global"
}

resource "google_service_account" "service_account" {
  project      = var.project
  account_id   = local.sa_name #bi-platform-sa
  display_name = local.sa_name
}

locals {
  all_service_account_roles = concat(var.service_account_roles)
}

locals {
  netowrk_service_account_roles = concat(var.shared_vpc_service_account_roles)
}

resource "google_project_iam_member" "composer_service_account_roles" {
  for_each = toset(local.all_service_account_roles)

  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "netowrk_service_account_role" {
  for_each = toset(local.netowrk_service_account_roles)

  project = var.shared_vpc_project
  role    = each.value
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "composer_shared_vpc_service_account_role" {
  project = var.shared_vpc_project
  role    = "roles/composer.sharedVpcAgent"
  member  = "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "composer_shared_vpc_google_api_service_account_role" {
  project = var.shared_vpc_project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${data.google_project.project.number}@cloudservices.gserviceaccount.com"
}

resource "google_compute_subnetwork" "composer_subnetwork" {
  name                     = var.subnetwork_name
  ip_cidr_range            = var.subnetwork_ip_cidr_range
  project                  = var.shared_vpc_project
  private_ip_google_access = "true"
  region                   = var.region
  network                  = var.network_name
  secondary_ip_range {
    range_name    = var.cluster_secondary_range_name
    ip_cidr_range = var.composer_cluster_secondary_ip_cidr_range
  }
  secondary_ip_range {
    range_name    = var.services_secondary_range_name
    ip_cidr_range = var.composer_services_secondary_ip_cidr_range
  }
}

resource "google_compute_subnetwork_iam_binding" "binding" {
  project    = var.shared_vpc_project
  region     = var.region
  subnetwork = var.subnetwork_name
  role       = "roles/compute.networkUser"
  members = [
    "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com",
    "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com",
    "serviceAccount:${data.google_project.project.number}@cloudservices.gserviceaccount.com",
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

locals {
  external_addresses = {
    for s in var.cloud_nat : s.external_address_name => s.region
  }
}

module "addresses" {
  source             = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-address?ref=v45.0.0"
  project_id         = var.shared_vpc_project
  external_addresses = local.external_addresses

}

module "nat" {
  for_each                  = { for index, nat in var.cloud_nat : nat.name => nat }
  source                    = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-cloudnat?ref=v45.0.0"
  name                      = each.value.name
  project_id                = var.shared_vpc_project
  region                    = each.value.region
  addresses                 = [module.addresses.external_addresses["${each.value.external_address_name}"].self_link]
  config_source_subnetworks = "LIST_OF_SUBNETWORKS"
  router_create             = each.value.router_create
  router_name               = each.value.router_name
  router_network            = var.network_name
  subnetworks = [{
    self_link            = google_compute_subnetwork.composer_subnetwork.self_link
    config_source_ranges = ["ALL_IP_RANGES"]
    secondary_ranges     = []
  }]
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [google_project_iam_member.composer_shared_vpc_google_api_service_account_role, google_project_iam_member.composer_shared_vpc_service_account_role]
  create_duration = "60s"
}

resource "google_composer_environment" "composer" {
  name       = local.composer_name
  region     = var.region
  depends_on = [time_sleep.wait_60_seconds]
  config {

    private_environment_config {
      enable_private_endpoint    = true
      master_ipv4_cidr_block     = var.master_ipv4_cidr_block
      web_server_ipv4_cidr_block = var.web_server_ipv4_cidr_block
      cloud_sql_ipv4_cidr_block  = var.cloud_sql_ipv4_cidr_block
    }

    software_config {
      image_version   = var.image_version
      scheduler_count = var.scheduler_count
      airflow_config_overrides = {
        webserver-default_ui_timezone             = "Europe/Vilnius"
        webserver-reload_on_plugin_change         = "True"
        webserver-rbac_user_registration_role     = "User"
        core-compress_serialized_dags             = "False"
        core-max_active_runs_per_dag              = "150"
        core-dagbag_import_timeout                = "3000"
        core-killed_task_cleanup_time             = "604800"
        core-parallelism                          = "128"
        core-max_active_tasks_per_dag             = "300"
        scheduler-parsing_processes               = "1"
        scheduler-scheduler_zombie_task_threshold = "128"
        api-auth_backends                         = "airflow.composer.api.backend.composer_auth"
        api-composer_auth_user_registration_role  = "User"
      }
    }
    node_count = var.node_count

    node_config {
      zone            = var.node_zone
      machine_type    = var.node_machine_type
      network         = "projects/${var.shared_vpc_project}/global/networks/${var.network_name}"
      subnetwork      = "projects/${var.shared_vpc_project}/regions/${var.region}/subnetworks/${var.subnetwork_name}"
      disk_size_gb    = var.disk_size_gb
      oauth_scopes    = var.oauth_scopes
      service_account = google_service_account.service_account.name
      tags            = var.tags
      ip_allocation_policy {
        use_ip_aliases                = "true"
        cluster_secondary_range_name  = var.cluster_secondary_range_name
        services_secondary_range_name = var.services_secondary_range_name
      }
    }

    database_config {
      machine_type = var.cloudsql_machine_type
    }

    web_server_config {
      machine_type = var.composer_machine_type
    }

    maintenance_window {
      start_time = var.maintenance_start
      end_time   = var.maintenance_stop
      recurrence = var.recurrence
    }
    dynamic "master_authorized_networks_config" {
      for_each = var.master_authorized_networks_config
      content {
        enabled = true
        dynamic "cidr_blocks" {
          for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", [])
          content {
            cidr_block   = cidr_blocks.value.cidr_block
            display_name = lookup(cidr_blocks.value, "display_name", null)
          }
        }
      }
    }
    web_server_network_access_control {
      dynamic "allowed_ip_range" {
        for_each = var.allowed_web_server_access
        content {
          value       = allowed_ip_range.value.value
          description = allowed_ip_range.value.description
        }
      }
    }
  }
}

resource "local_file" "outputs" {
  content  = "composer_environment_name=${local.composer_name}\nlocation=${var.location}\nproject_id=${var.project}\ncomposer_gke_name=${google_composer_environment.composer.config.0.gke_cluster}\ngcs_prefix=${google_composer_environment.composer.config.0.dag_gcs_prefix}\nairflow_url=${google_composer_environment.composer.config.0.airflow_uri}"
  filename = "../../../../outputs.txt"
}

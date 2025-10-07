module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 12.0.0"

  project_id              = var.project
  network_name            = "${var.env}-${var.name}-network"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
  subnets = [
    {
      subnet_name           = "${var.env}-${var.name}-subnetwork"
      subnet_ip             = var.cidr_block
      subnet_private_access = "true"
      subnet_region         = var.region
      subnet_flow_logs      = "false"
    },
  ]
  secondary_ranges = {
    "${var.env}-${var.name}-subnetwork" = [
      {
        range_name    = "${var.env}-${var.name}-cluster-secondary-subnetwork"
        ip_cidr_range = var.cluster_ipv4_cidr_block
      },
      {
        range_name    = "${var.env}-${var.name}-services-secondary-subnetwork"
        ip_cidr_range = var.services_ipv4_cidr_block
      },
    ]

  }
}
## this needed because, after vpc creation, there should be some kind of pause, before VPC resource is "visible"
resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.vpc]

  create_duration = "30s"
}

data "google_compute_subnetwork" "subnetwork" {
  name       = module.vpc.network_name
  region     = var.region
  depends_on = [time_sleep.wait_30_seconds]
}

resource "google_compute_firewall" "private_allow_all_network_inbound" {
  name = "${var.env}-${var.name}-allow-ingress"

  project = var.project
  network = "${var.env}-${var.name}-network"

  target_tags = ["private"]
  direction   = "INGRESS"

  ### TODO: change hardcoded values down there by normal formating

  source_ranges = [
    var.cidr_block,
    var.cidr_block,
    var.cluster_ipv4_cidr_block,
    var.services_ipv4_cidr_block

  ]

  priority = "1000"

  allow {
    protocol = "all"
  }
  depends_on = [time_sleep.wait_30_seconds]
}


resource "google_compute_router" "vpc_router" {
  name = "${var.env}-${var.name}-router"

  project = var.project
  region  = var.region
  network = module.vpc.network_self_link
}

resource "google_compute_router_nat" "vpc_nat" {
  name = "${var.env}-${var.name}-nat"

  project = var.project
  region  = var.region
  router  = google_compute_router.vpc_router.name

  nat_ip_allocate_option = "AUTO_ONLY"

  # "Manually" define the subnetworks for which the NAT is used, so that we can exclude the public subnetwork
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = "${var.env}-${var.name}-subnetwork"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  depends_on = [time_sleep.wait_30_seconds]
}

resource "google_compute_subnetwork" "network-for-lb" {
  count         = var.lb_subnet_cidr == null ? 0 : 1
  provider      = google-beta
  project       = var.project
  name          = "${var.env}-${var.name}-lb-subnet"
  ip_cidr_range = var.lb_subnet_cidr
  region        = var.region
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = module.vpc.network_id
}

# A host project provides network resources to associated service projects.
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.project
}

# A service project gains access to network resources provided by its
# associated host project.
resource "google_compute_shared_vpc_service_project" "service1" {
  count           = var.attached_projects != null ? 1 : 0
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.attached_projects
}

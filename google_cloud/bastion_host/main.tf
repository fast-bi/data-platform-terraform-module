resource "google_compute_instance" "default" {
  name         = var.name
  project      = var.project
  zone         = "${var.region}-a"
  machine_type = var.machine_type
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

  }

  metadata_startup_script = templatefile("${path.module}/template/startup.sh", {
    composer_name      = var.composer_name
    location           = var.composer_location
    dbt_deploy_sa_user = var.dbt_deploy_sa_email
    composer_gke_name  = var.composer_gke_name
    zone               = var.composer_gke_zone
    project            = var.project
  })

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.sa_email
    scopes = ["cloud-platform"]
  }
  scheduling {
    preemptible                 = true
    provisioning_model          = "SPOT"
    automatic_restart           = false
    instance_termination_action = "TERMINATE"
  }

}

resource "google_compute_firewall" "allow_from_iap_to_instances" {
  count   = var.create_firewall_rule ? 1 : 0
  project = var.host_project != "" ? var.host_project : var.project
  name    = var.fw_name_allow_ssh_from_iap
  network = var.network

  allow {
    protocol = "tcp"
    ports    = toset(concat(["22"], var.additional_ports))
  }

  # https://cloud.google.com/iap/docs/using-tcp-forwarding#before_you_begin
  # This is the netblock needed to forward to the instances
  source_ranges = ["35.235.240.0/20"]

  # target_service_accounts = length(var.service_accounts) > 0 ? var.service_accounts : null
  target_tags = length(var.network_tags) > 0 ? var.network_tags : null
}

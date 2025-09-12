# Create service accounts with robust error handling
# This module creates service accounts and assigns IAM roles to ALL of them
# Enhanced with lifecycle rules to handle existing resources gracefully

# Create service accounts
resource "google_service_account" "service_accounts" {
  for_each = toset(var.sa_names)
  
  account_id   = each.value
  project      = var.project
  display_name = var.sa_display_name != "" ? var.sa_display_name : each.value
  description  = var.sa_description

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      display_name,
      description,
      # Prevent recreation of existing service accounts
      account_id,
      project
    ]
  }
}

# Wait for service accounts to be fully created before proceeding
resource "time_sleep" "wait_for_sa_creation" {
  depends_on = [google_service_account.service_accounts]
  
  create_duration = "30s"
}

# Assign project roles to ALL service accounts (not just the first one)
resource "google_project_iam_member" "project_roles" {
  for_each = {
    for pair in setproduct(var.sa_names, var.project_roles) : 
    "${pair[0]}-${split("=>", pair[1])[1]}" => {
      sa_name = pair[0]
      role    = split("=>", pair[1])[1]
    }
  }
  
  project = var.project
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.service_accounts[each.value.sa_name].email}"

  depends_on = [time_sleep.wait_for_sa_creation]

  lifecycle {
    create_before_destroy = true
    # Prevent recreation of existing IAM bindings
    ignore_changes = [
      project,
      role,
      member
    ]
  }
}

# Generate keys for service accounts if requested
resource "google_service_account_key" "service_account_keys" {
  for_each = var.generate_keys_for_sa ? toset(var.sa_names) : []

  service_account_id = google_service_account.service_accounts[each.value].name
  key_algorithm     = "KEY_ALG_RSA_2048"
  private_key_type  = "TYPE_GOOGLE_CREDENTIALS_FILE"
  
  depends_on = [time_sleep.wait_for_sa_creation]

  lifecycle {
    create_before_destroy = true
    # Allow key regeneration when needed
    ignore_changes = [
      service_account_id
    ]
  }
}



# Save service account key to file (base64 encoded)
resource "local_file" "sa_key" {
  count    = var.generate_keys_for_sa ? 1 : 0
  content  = google_service_account_key.service_account_keys[var.sa_names[0]].private_key
  filename = "../../../../../sa_key.txt"

  depends_on = [google_service_account_key.service_account_keys]

  lifecycle {
    create_before_destroy = true
    # Allow key file updates when keys change
    ignore_changes = [
      filename
    ]
  }
}

# Create workload identity mappings if provided
resource "google_service_account_iam_member" "workload_identity_binding" {
  for_each = {
    for idx, mapping in var.wid_mapping_to_sa : 
    "${mapping.k8s_sa_name}-${mapping.namespace}" => mapping
  }

  service_account_id = google_service_account.service_accounts[var.sa_names[0]].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[${each.value.namespace}/${each.value.k8s_sa_name}]"

  depends_on = [time_sleep.wait_for_sa_creation]

  lifecycle {
    create_before_destroy = true
    # Allow updates to members but prevent recreation of service account and role
    ignore_changes = [
      service_account_id
    ]
  }
}

# Save service account email to file for external use
resource "local_file" "sa_name" {
  content  = "service_account_email=${google_service_account.service_accounts[var.sa_names[0]].email}"
  filename = "../../../../../sa_name.txt"

  depends_on = [time_sleep.wait_for_sa_creation]

  lifecycle {
    create_before_destroy = true
    # Prevent recreation of existing output files
    ignore_changes = [
      content,
      filename
    ]
  }
}
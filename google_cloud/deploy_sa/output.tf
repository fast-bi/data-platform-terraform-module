output "sa_email" {
  description = "Email of the first service account"
  value = google_service_account.service_accounts[var.sa_names[0]].email
}

output "all_sa_emails" {
  description = "Map of all service account names to their emails"
  value = {
    for sa_name in var.sa_names : sa_name => google_service_account.service_accounts[sa_name].email
  }
}

output "service_accounts" {
  description = "Map of all created service accounts"
  value = google_service_account.service_accounts
}


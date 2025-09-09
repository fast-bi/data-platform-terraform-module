provider "google" {
  project = var.project
  region  = "global"
  batching {
    enable_batching = "false"
  }
}

provider "googleworkspace" {
  credentials = var.path
  customer_id = var.customer_id
  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.userschema",
    # include scopes as needed
  ]
}
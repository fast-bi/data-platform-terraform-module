provider "google" {
  project = var.project
  region  = var.region
  batching {
    enable_batching = "false"
  }
}

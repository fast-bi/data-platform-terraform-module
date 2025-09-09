provider "google" {
  project = var.project
  batching {
    enable_batching = "false"
  }
}
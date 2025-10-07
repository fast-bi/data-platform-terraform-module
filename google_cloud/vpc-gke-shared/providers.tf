provider "google" {
  project = var.project
  region  = "global"
  batching {
    enable_batching = "false"
  }
}

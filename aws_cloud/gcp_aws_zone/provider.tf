provider "aws" {
  # The AWS region to deploy resources into
  region = var.region # Uncomment and specify a default region if needed

  # Optionally specify profile
  profile = var.profile # Uncomment to use a specific AWS profile

  # Default tags to apply to all resources
  # default_tags {
  #   tags = var.default_tags
  # }
}

# GCP provider configuration
provider "google" {
  project = var.gcp_project_id
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.28.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 1.0"
}

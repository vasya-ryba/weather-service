terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.20.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

  backend "gcs" {
    bucket  = "tf-state-wttr"
    prefix  = "terraform/state"
  }

  required_version = ">= 0.14"
}


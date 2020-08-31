terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    acme = {
      source = "terraform-providers/acme"
    }
    dnsimple = {
      source = "terraform-providers/dnsimple"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }

  backend "gcs" {
    bucket = "chronograph-tf-state-staging"
    prefix = "terraform/state"
  }
}

provider "google" {
  version = "3.5.0"

  project = "chronograph"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-b"
}

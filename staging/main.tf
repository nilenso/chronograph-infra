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

provider "google-beta" {
  version = "3.5.0"

  project = "chronograph"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-b"
}

resource "google_compute_network" "internal" {
  name = "chronograph-internal"
}

resource "google_compute_global_address" "db_internal" {
  name          = "chronograph-db"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.internal.id
}

resource "google_service_networking_connection" "vpc_connection" {
  network                 = google_compute_network.internal.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_internal.name]
}

resource "google_sql_database_instance" "db_instance" {
  name   = "chronograph"
  database_version = "POSTGRES_12"

  depends_on = [google_service_networking_connection.vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.internal.id
    }
  }
}

resource "google_compute_address" "web_server" {
  name = "chronograph-staging-web"
}

resource "google_compute_instance" "web_server" {
  name         = "chronograph-web"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.internal.id
    access_config {
      nat_ip = google_compute_address.web_server.address
    }
  }

  metadata = {
    enable-oslogin = "true"
  }
}


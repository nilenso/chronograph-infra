resource "google_compute_global_address" "db_internal" {
  name          = "chronograph-db"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.internal.id
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

resource "random_password" "db_password" {
  length = 32
  special = true
  override_special = "_%@"
}

resource "google_sql_user" "chronograph_web" {
  name     = "chronograph-web"
  instance = google_sql_database_instance.db_instance.name
  password = random_password.db_password.result
}


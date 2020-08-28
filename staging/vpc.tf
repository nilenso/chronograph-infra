resource "google_compute_network" "internal" {
  name = "chronograph-internal"
}

resource "google_service_networking_connection" "vpc_connection" {
  network                 = google_compute_network.internal.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_internal.name]
}

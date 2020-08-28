resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.internal.name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_address" "web_server" {
  name = "chronograph-staging-web"
}

resource "google_compute_instance" "web_server" {
  name         = "chronograph-web"
  machine_type = "g1-small"

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
    enable-oslogin = "TRUE"
  }
}

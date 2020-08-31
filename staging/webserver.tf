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

resource "google_compute_firewall" "allow_customhttp" {
  name    = "allow-customhttp"
  network = google_compute_network.internal.name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }
}

resource "google_compute_instance_template" "web_server_template" {
  name_prefix         = "chronograph-web-"
  machine_type = "g1-small"

  disk {
    source_image = "debian-cloud/debian-10"
    boot = "true"
  }

  network_interface {
    network = google_compute_network.internal.self_link
    access_config {}
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_target_pool" "web_servers" {
  name = "web-servers"

  instances = []

  health_checks = [
    google_compute_http_health_check.web_server.name,
  ]
}

resource "google_compute_http_health_check" "web_server" {
  name               = "web-http-health"
  request_path       = "/"
  check_interval_sec = 2
  timeout_sec        = 1
}

resource "google_compute_instance_group_manager" "web_servers" {
  name = "web-servers"

  base_instance_name = "web"

  version {
    instance_template  = google_compute_instance_template.web_server_template.id
  }

  target_pools = [google_compute_target_pool.web_servers.id]
  target_size  = 2

  named_port {
    name = var.service_port_name
    port = var.service_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.web_server.id
    initial_delay_sec = 300
  }
}

resource "google_compute_health_check" "web_server" {
  name                = "web-health"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/index.html"
    port         = var.service_port
  }
}

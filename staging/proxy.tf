resource "google_compute_global_address" "public_proxy" {
  name         = "public-proxy"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "public-https"
  target     = google_compute_target_https_proxy.web_server.self_link
  ip_address = google_compute_global_address.public_proxy.address
  port_range = "443"
  depends_on = [google_compute_global_address.public_proxy]
}

resource "google_compute_target_https_proxy" "web_server" {
  name    = "chronograph-https-proxy"
  url_map = google_compute_url_map.public_proxy_routes.id

  ssl_certificates = [google_compute_ssl_certificate.letsencrypt.self_link]
}

resource "google_compute_ssl_certificate" "letsencrypt" {
  name        = "chronograph-letsencrypt-certificate"
  private_key = acme_certificate.certificate.private_key_pem
  certificate = acme_certificate.certificate.certificate_pem
}

resource "google_compute_url_map" "public_proxy_routes" {
  name            = "chronograph-public-routes"
  description     = "Public proxy routes"
  default_service = google_compute_backend_service.web.id

  host_rule {
    hosts        = ["${var.subdomain}.${var.domain}"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.web.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.web.id
    }
  }
}

resource "google_compute_backend_service" "web" {
  name        = "backend"
  port_name   = var.service_port_name
  protocol    = "HTTP"
  timeout_sec = 1

  health_checks = [google_compute_health_check.web_server.id]

  backend {
    group = google_compute_instance_group_manager.web_servers.instance_group
  }
}

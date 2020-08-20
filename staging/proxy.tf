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

  ssl_certificates = [google_compute_region_ssl_certificate.letsencrypt.self_link]
}

resource "google_compute_region_ssl_certificate" "letsencrypt" {
  provider    = google-beta

  name        = "chronograph-letsencrypt-certificate"
  private_key = acme_certificate.certificate.private_key_pem
  certificate = acme_certificate.certificate.certificate_pem
}

resource "google_compute_url_map" "public_proxy_routes" {
  name            = "chronograph-public-routes"
  description     = "Public proxy routes"
  default_service = google_compute_backend_service.web.id

  host_rule {
    hosts        = ["time.amongdragons.com"]
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
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 1

  health_checks = [google_compute_http_health_check.web.id]
}

resource "google_compute_http_health_check" "web" {
  name               = "web-server-root"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}


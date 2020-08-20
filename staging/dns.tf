provider "dnsimple" {
  token = var.dnsimple_token
  account = var.dnsimple_account
}

# Create a record
resource "dnsimple_record" "www" {
  domain = var.domain
  name   = var.subdomain
  value  = google_compute_instance.web_server.network_interface.0.access_config.0.nat_ip
  type   = "A"
  ttl    = 3600
}

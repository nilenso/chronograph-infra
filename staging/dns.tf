provider "dnsimple" {
  token = var.dnsimple_token
  account = var.dnsimple_account
}

# Create a record
resource "dnsimple_record" "www" {
  domain = var.domain
  name   = var.subdomain
  value  = google_compute_global_address.public_proxy.address
  type   = "A"
  ttl    = 3600
}

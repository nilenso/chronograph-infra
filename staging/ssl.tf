provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.acme_registration_email
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "${var.subdomain}.${var.domain}"

  dns_challenge {
    provider = "dnsimple"
    config = {
      DNSIMPLE_OAUTH_TOKEN = var.dnsimple_token
    }
  }
}


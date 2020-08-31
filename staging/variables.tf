variable "acme_server_url"          {
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
variable "acme_registration_email"  { }

variable "domain"              { }
variable "subdomain"           { }

variable "gcp_region"          { }
 
variable "dnsimple_account" {}
variable "dnsimple_token" {}

variable "service_port_name" {
  default = "customhttp"
}

variable "service_port" {
  default = 8000
}

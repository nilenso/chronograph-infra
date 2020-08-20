variable "acme_server_url"          { default = "https://acme-staging.api.letsencrypt.org/directory"}
variable "acme_registration_email"  { }

variable "domain"              { }
variable "subdomain"           { }

variable "gcp_region"          { }
 
variable "dnsimple_account" {}
variable "dnsimple_token" {}

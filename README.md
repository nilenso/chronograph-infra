# Chronograph Infra

This repository has:

- The infrastructure for the staging environment defined in `staging/`

### Prerequisites

__Terraform >= 0.13__

You'll have to install & run terraform manually. Note that running nix-shell gives you a shell with terraform available. However, this is currently older than what we need.

__Configuration & Secrets__

You will need a couple of files:

1. A terraform.tfvars in `staging/` that defines vars
2. GCP service account credentials JSON (set GOOGLE_CREDENTIALS to the path to this file is your shell)

Currently, these are transferred out of band. Once you have them, you should be able to run `terraform plan` & `apply` in the `staging/` directory.

### Running it

1. cd into the appropriate directory. eg. `staging/`
2. Ensure you have all the prerequisites.
     - A terraform.tfvars file in the `staging/` directory
     - GCP credentials JSON whose path is exported as GOOGLE_CREDENTIALS on your shell
     - Terraform >= 0.13 installed
4. Run `terraform init` if this is the first time you're using this.
5. Run `terraform plan` & `terraform apply` as necessary

### Extra

To see the database credentials:

```
terraform show  -json | jq '.values.root_module.resources | .[] | select(.address == "google_sql_user.chronograph_web") | .values'
```

# Static Site Storage Pattern Module

This pattern module creates Azure Blob Storage configured for static website hosting. It's designed for hosting simple HTML sites without the need for Application Insights or complex monitoring.

## Features

- ✅ Resource Group with consistent naming
- ✅ Storage Account (Standard tier, configurable replication)
- ✅ Static website hosting enabled
- ✅ HTTPS enforcement with TLS 1.2 minimum
- ✅ Configurable index and 404 error documents

## Usage

```hcl
module "static_site" {
  source = "../../../shared-modules/pattern-modules/static-site-storage"

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  environment     = "dev"
  location        = "eastus2"
  naming_suffix   = ["portals", "admin", "dev"]
  purpose         = "Admin Portal Static Site"

  storage_account_tier     = "Standard"
  storage_replication_type = "LRS"

  index_document     = "index.html"
  error_404_document = "404.html"

  tags = {
    Project = "Admin Portal"
  }
}
```

## Outputs

- `primary_web_endpoint` - The static website endpoint
- `static_website_url` - The HTTPS URL for the site
- `storage_account_name` - Name of the storage account

## Deployment

Files are uploaded to the `$web` container that is automatically created when static website hosting is enabled.

## Requirements

- Terraform >= 1.12.0
- Azure provider ~> 4.0

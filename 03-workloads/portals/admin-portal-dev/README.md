# Admin Portal Dev Workload - Static Website Storage

This workload deploys a static HTML site using Azure Blob Storage with static website hosting enabled for the admin portal in the development environment.

## Resources Deployed

- Resource Group
- Storage Account (Standard LRS, static website enabled)
- Automatic `$web` container for static content

## Pattern Module

Uses the `static-site-storage` pattern module which provides:
- Consistent naming conventions
- HTTPS enforcement with TLS 1.2
- Static website hosting configuration
- No Application Insights (lightweight for static HTML sites)

## Prerequisites

- Admin portal dev landing zone deployed (`02-landing-zones/workloads/portals-admin-dev`)
- Azure subscription: acme-portals-admin-dev

## Deployment

```powershell
# Initialize Terraform with backend configuration
terraform init -backend-config="backend.tfbackend"

# Review planned changes
terraform plan -var-file="terraform.tfvars"

# Apply changes
terraform apply -var-file="terraform.tfvars"
```

## Uploading Content

After deployment, upload your HTML files to the `$web` container using Azure CLI:

```powershell
az storage blob upload-batch \
  --account-name <storage-account-name> \
  --source ./html-files \
  --destination '$web' \
  --auth-mode login
```

## Outputs

- `primary_web_endpoint` - The static website endpoint URL
- `static_website_url` - The HTTPS URL for accessing your site
- `storage_account_name` - Name of the storage account


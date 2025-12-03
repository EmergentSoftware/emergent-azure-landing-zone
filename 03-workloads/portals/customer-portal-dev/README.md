# Admin Portal Dev Workload - Blob Storage

This workload deploys blob storage for the admin portal in the development environment.

## Resources Deployed

- Resource Group
- Storage Account (Standard LRS, StorageV2)
- Blob Container (private access)
- Application Insights (optional monitoring)

## Prerequisites

- Admin portal dev landing zone deployed (`02-landing-zones/workloads/portals-admin-dev`)
- Log Analytics workspace available from landing zone
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

## Configuration

Key configuration in `terraform.tfvars`:
- Storage account tier and replication
- Blob container name and access type
- Application Insights integration with landing zone Log Analytics

## Outputs

- Storage account details (ID, name, endpoints)
- Blob container information
- Application Insights connection details (sensitive)

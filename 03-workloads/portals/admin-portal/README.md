# Portal Workload using Azure Verified Modules

This workload demonstrates deploying a production-ready customer portal using Azure Verified Modules (AVM) that complies with Azure Landing Zone policies.

## Multi-Environment Support

This workload supports multiple environments (dev, prod) using:
- **Separate tfvars files**: `dev.tfvars`, `prod.tfvars`
- **Environment-specific state files**: Different state keys per environment
- **Different subscriptions**: Each environment deploys to its own subscription
- **Environment-aware configuration**: Auto-adjusts SKUs, settings based on environment

## Architecture

Resources created per environment:

```
Resource Group (acme-rg-portal-{env}-{region}-{unique})
├── App Service Plan (acme-asp-portal-{env}-{region}-{unique})
│   └── SKU: B1 (dev) | P1v3 (prod)
├── Web App (acme-app-portal-{env}-{region}-{unique})
│   ├── System-assigned Managed Identity
│   ├── HTTPS enforced, TLS 1.2+
│   └── Diagnostic Settings → Log Analytics
└── Application Insights (acme-appi-portal-{env}-{region}-{unique})
```

## Prerequisites

1. **Landing Zone**: `02-landing-zones/workloads/portals-dev` deployed
2. **Log Analytics**: Created by landing zone
3. **Terraform**: >= 1.12.0
4. **Subscription**: portals-dev (9a877ddf-9796-43a8-a557-f6af1df195bf)

## Quick Start - Development

### 1. Get Log Analytics Workspace ID

```bash
cd ../../02-landing-zones/workloads/portals-dev
terraform output -raw log_analytics_workspace_resource_id
```

Copy the output and update `dev.tfvars`:
```hcl
log_analytics_workspace_id = "/subscriptions/.../workspaces/acme-log-portals-dev-eus-xxxx"
```

### 2. Initialize Terraform

```bash
cd ../../../03-workloads/portals
terraform init \
  -backend-config="resource_group_name=acme-rg-prod-eus-vw01" \
  -backend-config="storage_account_name=acmestprodeusvw01" \
  -backend-config="container_name=tfstate-workloads" \
  -backend-config="key=portals-dev.tfstate"
```

### 3. Deploy

```bash
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### 4. Verify Deployment

```bash
# Get the web app URL
terraform output web_app_default_hostname

# Test the endpoint
curl https://$(terraform output -raw web_app_default_hostname)
```

## Production Deployment

### 1. Create Production Landing Zone

First, create a production landing zone (requires production subscription):

```bash
# Copy dev landing zone as template
cp -r ../../02-landing-zones/workloads/portals-dev ../../02-landing-zones/workloads/portals-prod

cd ../../02-landing-zones/workloads/portals-prod

# Update configuration
# - Edit variables.tf: Change default environment to "prod"
# - Edit terraform.tfvars: Set production subscription ID
# - Edit main.tf: Change suffix to ["portals", "prod"]

# Deploy landing zone
terraform init -backend-config="..." # Configure for portals-prod
terraform apply
```

### 2. Deploy Production Workload

```bash
cd ../../../03-workloads/portals

# Get production Log Analytics workspace ID
cd ../../02-landing-zones/workloads/portals-prod
terraform output -raw log_analytics_workspace_resource_id

# Update prod.tfvars with workspace ID and subscription ID

# Initialize with production state
cd ../../03-workloads/portals
terraform init \
  -backend-config="resource_group_name=acme-rg-prod-eus-vw01" \
  -backend-config="storage_account_name=acmestprodeusvw01" \
  -backend-config="container_name=tfstate-workloads" \
  -backend-config="key=portals-prod.tfstate"

# Deploy
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

## Environment Differences

| Feature | Dev (B1) | Prod (P1v3) |
|---------|----------|-------------|
| **SKU** | Basic B1 | Premium P1v3 |
| **Always On** | No | Yes |
| **CORS** | Enabled (localhost) | Disabled |
| **Monitoring** | Basic | Full |
| **Cost** | ~$13/month | ~$214/month |

## Key Outputs

```bash
# Web App URL
terraform output web_app_default_hostname

# Managed Identity Principal ID
terraform output web_app_principal_id

# Application Insights Key
terraform output application_insights_instrumentation_key
```

## Post-Deployment

### Configure Deployment Slots (Production Only)

```bash
# Add staging slot for blue/green deployments
az webapp deployment slot create \
  --name $(terraform output -raw web_app_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --slot staging
```

### Configure Custom Domain

```bash
# Add custom domain
az webapp config hostname add \
  --webapp-name $(terraform output -raw web_app_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --hostname portal.acme.com
```

### Grant Managed Identity Access

```bash
# Example: Grant Key Vault access
PRINCIPAL_ID=$(terraform output -raw web_app_principal_id)
az keyvault set-policy \
  --name acme-kv-prod-eus \
  --object-id $PRINCIPAL_ID \
  --secret-permissions get list
```

## Compliance & Monitoring

- **Policies Applied**: Inherits from acme-portals management group
- **Diagnostics**: Sent to landing zone Log Analytics workspace
- **Application Insights**: Connected to Log Analytics workspace
- **Alerts**: Configure in Azure Monitor based on App Insights metrics

## Troubleshooting

### State Lock Issues

```bash
terraform force-unlock <lock-id>
```

### Re-initialize for Different Environment

```bash
# Switch from dev to prod
rm -rf .terraform
terraform init -backend-config="..." -backend-config="key=portals-prod.tfstate"
```

### View Current Workspace

```bash
az webapp show \
  --name $(terraform output -raw web_app_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --query "{name:name, state:state, hostNames:defaultHostName}"
```

## Clean Up

```bash
# Destroy workload (dev environment example)
terraform destroy -var-file="dev.tfvars"

# Destroy landing zone (optional, removes networking and monitoring)
cd ../../02-landing-zones/workloads/portals-dev
terraform destroy
```

## Additional Resources

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [Application Insights](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)

# Admin Portal Workload - Azure Static Web App

This workload deploys the admin-facing portal as an Azure Static Web App with network isolation and private endpoint support.

## Multi-Environment Support

This workload supports multiple environments (dev, prod) using:
- **Separate tfvars files**: `dev.tfvars`, `prod.tfvars`
- **Environment-specific state files**: Different state keys per environment
- **Different subscriptions**: Each environment deploys to its own subscription
- **Network isolation**: Dedicated VNet per environment

## Architecture

Resources created per environment:

```
Resource Group (acme-rg-portals-admin-app-{env}-{region}-{unique})
├── Static Web App (acme-swa-admin-{env}-{region}-{unique})
│   ├── SKU: Free (dev) | Standard (prod with private endpoint)
│   ├── System-assigned Managed Identity
│   └── Tags: Environment, Purpose, Workload
│
└── (Optional) Private Endpoint
    ├── Connects to: Admin Dev VNet (10.100.0.0/16)
    ├── Subnet: Private Endpoints (10.100.2.0/24)
    └── Private DNS: privatelink.azurestaticapps.net (in connectivity)
```

## Prerequisites

### Infrastructure Dependencies

1. **Landing Zone Network**: `02-landing-zones/workloads/portals-admin-dev` deployed
   - Admin Dev VNet: 10.100.0.0/16
   - Private Endpoints Subnet: 10.100.2.0/24
   - VNet Integration Subnet: 10.100.3.0/24

2. **Connectivity Hub**: `02-landing-zones/connectivity` deployed
   - Hub VNet: 10.0.0.0/16
   - Private DNS Zone: `privatelink.azurestaticapps.net`
   - VNet Peering: hub ↔ admin-dev spoke (required for private DNS resolution)

3. **Terraform**: >= 1.12.0
4. **Subscription**: portals-admin-dev (588aa873-b13e-40bc-a96f-89805c56d7d0)

### Network Configuration

Before deploying, ensure VNet peering is configured between hub and admin-dev spoke:

```powershell
# Verify peering
az network vnet peering list --resource-group <hub-rg> --vnet-name vnet-hub-prod-eus2 -o table
```

## Quick Start - Development

### 1. Get Network Information (if using private endpoint)

### 1. Get Network Information (if using private endpoint)

```powershell
# Get VNet and subnet IDs from landing zone
cd ../../02-landing-zones/workloads/portals-admin-dev
terraform output vnet_id
terraform output subnet_ids

# Get private DNS zone ID from connectivity
cd ../../connectivity
terraform output private_dns_zones
```

Update `dev.tfvars` with the subnet ID for private endpoints:
```hcl
private_endpoint_subnet_id = "/subscriptions/588aa873-b13e-40bc-a96f-89805c56d7d0/resourceGroups/.../subnets/acme-snet-admin-privateendpoints-dev-eus2"
```

### 2. Initialize Terraform

```powershell
cd ../../../03-workloads/portals/admin-portal
terraform init -backend-config="key=tfstate-admin-portal-dev"
```

### 3. Deploy Development Environment

```powershell
terraform apply -var-file="dev.tfvars" -auto-approve
```

### 4. Get Static Web App Details

```powershell
# Get deployment token for GitHub Actions
terraform output -raw static_web_app_api_key

# Get default hostname
terraform output -raw static_web_app_default_hostname
```

## Network Integration

### Private Endpoint (Production Only)

For production deployments with Standard SKU Static Web App:

1. **Enable Private Endpoint** in `prod.tfvars`:
   ```hcl
   enable_private_endpoint = true
   private_endpoint_subnet_id = "<subnet-id-from-landing-zone>"
   ```

2. **Verify Private DNS Resolution**:
   ```powershell
   # From a VM in the admin VNet
   nslookup <your-swa-name>.azurestaticapps.net
   # Should resolve to private IP 10.100.2.x
   ```

### VNet Integration (Optional)

If the Static Web App needs to call backend APIs in the admin VNet:

1. Add VNet integration subnet ID to `tfvars`
2. Configure managed VNet integration in Static Web App configuration
3. Update NSG rules to allow outbound traffic from VNet Integration subnet

## Security Considerations

### Network Isolation

- **Admin Dev**: Uses dedicated VNet (10.100.0.0/16) isolated from customer portal
- **Private Endpoints**: Keeps traffic within Azure backbone (production only)
- **No Public Access**: When private endpoint enabled, public access should be disabled

### Identity and Access

- **Managed Identity**: System-assigned identity for Azure resource access
- **RBAC**: Grant minimal permissions to managed identity for backend resources
- **API Key Rotation**: Rotate Static Web App deployment tokens regularly

### Compliance

- **Tags**: All resources tagged with Environment, Purpose, Workload for governance
- **ALZ Policies**: Complies with Azure Landing Zone security and compliance policies
- **Encryption**: Data encrypted in transit (HTTPS) and at rest (Azure Storage)

## Deployment to Production

### 1. Update prod.tfvars

```hcl
environment         = "prod"
subscription_id     = "95d02110-3796-4dc6-af3b-f4759cda0d2f"  # Admin-prod subscription
static_web_app_sku  = "Standard"
enable_private_endpoint = true
private_endpoint_subnet_id = "<subnet-from-portals-admin-prod-landing-zone>"
```

### 2. Deploy to Production Subscription

```powershell
# Initialize with production state key
terraform init -backend-config="key=tfstate-admin-portal-prod" -reconfigure

# Deploy to production
terraform apply -var-file="prod.tfvars"
```

## Verification

### Check Deployment

```powershell
# List Static Web Apps
az staticwebapp list --query "[?contains(name, 'admin')].{Name:name, ResourceGroup:resourceGroup, Hostname:defaultHostname, SKU:sku.name}" -o table

# Check private endpoint (if enabled)
az network private-endpoint list --query "[?contains(name, 'admin')].{Name:name, ResourceGroup:resourceGroup, PrivateIP:customDnsConfigs[0].ipAddresses[0]}" -o table

# Check private DNS records
az network private-dns record-set a list --zone-name privatelink.azurestaticapps.net --resource-group <connectivity-privatedns-rg> -o table
```

### Test Application

```powershell
# Get the Static Web App URL
$hostname = terraform output -raw static_web_app_default_hostname
Write-Host "Admin Portal: https://$hostname"

# Test from Azure (if private endpoint enabled)
# curl https://$hostname from a VM in the admin VNet
```

## Next Steps

1. **Configure CI/CD**: Use the deployment token with GitHub Actions or Azure DevOps
2. **Deploy Application**: Push your admin portal frontend code to trigger deployment
3. **Backend Integration**: Configure managed identity for backend API access
4. **Custom Domain**: Add custom domain and SSL certificate
5. **Monitoring**: Configure Application Insights for performance monitoring

## Troubleshooting

### Private Endpoint Not Resolving

```powershell
# Verify VNet peering
az network vnet peering show --resource-group <hub-rg> --vnet-name vnet-hub-prod-eus2 --name hub-to-admin-dev

# Verify private DNS zone VNet link
az network private-dns link vnet list --zone-name privatelink.azurestaticapps.net --resource-group <connectivity-privatedns-rg> -o table
```

### Deployment Fails

```powershell
# Check Terraform state
terraform state list

# Validate configuration
terraform validate

# Check Azure activity log
az monitor activity-log list --resource-group <rg-name> --offset 1h
```

## Related Documentation

- [02-landing-zones/workloads/portals-admin-dev/README.md](../../02-landing-zones/workloads/portals-admin-dev/README.md) - Network landing zone
- [02-landing-zones/connectivity/README.md](../../02-landing-zones/connectivity/README.md) - Hub VNet and private DNS
- [Azure Static Web Apps Documentation](https://learn.microsoft.com/azure/static-web-apps/)
- [Private Endpoints Documentation](https://learn.microsoft.com/azure/private-link/private-endpoint-overview)

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

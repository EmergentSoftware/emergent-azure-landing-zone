# Azure Landing Zone - Deployment Order

This guide explains the correct sequence for deploying the Azure Landing Zone infrastructure and workloads.

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Step 0: Bootstrap (One-Time Setup)                         │
│ • Create Storage Account for Terraform state               │
│ • Create blob containers for each layer                    │
│ • Configure remote backend                                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 1: ALZ Foundation                                      │
│ • Management Groups                                         │
│ • Policy Definitions                                        │
│ • Policy Assignments                                        │
│ • Role Assignments                                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 2A: Landing Zone - Connectivity (Hub VNet)            │
│ • Hub VNet (10.0.0.0/16)                                   │
│ • Private DNS Zones (11 zones)                             │
│ • Bastion, Firewall, Gateway subnets                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 2B: Landing Zones - Workload Networks (Spoke VNets)   │
│ • Admin Dev VNet (10.100.0.0/16)                           │
│ • Customer Dev VNet (10.110.0.0/16)                        │
│ • Deploy in parallel for efficiency                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 2C: VNet Peering Configuration                        │
│ • Hub ↔ Admin Dev peering                                  │
│ • Hub ↔ Customer Dev peering                               │
│ • Enable private DNS resolution                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 3: Workload Deployment                                │
│ • Admin Portal Static Web App                              │
│ • Customer Portal Static Web App                           │
│ • Optional: Private endpoints for production               │
└─────────────────────────────────────────────────────────────┘
```

## Step 0: Bootstrap Terraform State Storage (One-Time Setup)

**Directory**: `00-bootstrap/`

**Purpose**: Creates Azure Storage Account and containers for storing Terraform state files.

**Creates**:
- Resource group for state storage
- Storage account with versioning and soft delete
- Blob containers for foundation, landing zones, and workloads

**Commands**:
```bash
cd 00-bootstrap
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your subscription ID
terraform init
terraform plan
terraform apply
```

**Duration**: ~2-3 minutes

**Verify**:
```bash
# Save the storage account name for backend configuration
terraform output storage_account_name

# View backend configuration instructions
terraform output -raw instructions
```

**Next Steps**:
- Copy the backend configuration from output
- Add backend blocks to 01-foundation, 02-landing-zones, and 03-workloads
- See `00-bootstrap/README.md` for detailed backend setup

**Wait Time**: Complete backend configuration before Step 1

---

## Step 1: Deploy ALZ Foundation

**Directory**: `01-foundation/`

**Purpose**: Creates the management group hierarchy and applies governance policies.

**Creates**:
- Management group structure (Platform, Landing Zones, etc.)
- Policy definitions and assignments
- Role-based access control (RBAC)

**Commands**:
```bash
cd 01-foundation
terraform init
terraform plan
terraform apply
```

**Duration**: ~5-10 minutes (540 resources)

**Verify**:
```bash
# Check management groups created
terraform output management_group_ids

# View in Azure Portal
# Azure Portal → Management Groups → acme
```

**Wait Time**: None - proceed immediately to Step 2

---

## Step 2A: Deploy Connectivity Landing Zone (Hub VNet)

**Directory**: `02-landing-zones/connectivity/`

**Purpose**: Creates the hub VNet with centralized networking services and private DNS zones.

**Prerequisites**:
- Step 1 (ALZ Foundation) completed

**Creates**:
- Hub VNet (10.0.0.0/16) with 6 subnets:
  - GatewaySubnet (10.0.0.0/27)
  - AzureFirewallSubnet (10.0.1.0/26)
  - AzureBastionSubnet (10.0.2.0/26)
  - Shared Services (10.0.10.0/24)
  - NVA (10.0.11.0/24)
  - Management (10.0.12.0/24)
- 11 Private DNS zones for Azure services (Static Web Apps, Storage, SQL, Cosmos DB, Key Vault, etc.)
- Resource groups for network and private DNS

**Commands**:
```powershell
cd 02-landing-zones/connectivity
terraform init -backend-config="key=tfstate-connectivity"
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
```

**Duration**: ~5-10 minutes (azapi provider can be slow)

**Verify**:
```powershell
# Check hub VNet created
terraform output vnet_id
terraform output vnet_name

# Check private DNS zones
terraform output private_dns_zones

# View in Azure Portal
az network vnet show --name vnet-hub-prod-eus2 --resource-group acme-rg-connectivity-network-prod-eus2-{unique}
az network private-dns zone list --resource-group acme-rg-connectivity-privatedns-prod-eus2-{unique} -o table
```

**Save These Values**:
```powershell
# You'll need these for VNet peering configuration
terraform output -raw vnet_id
terraform output -raw private_dns_resource_group_name
```

**Wait Time**: None - proceed immediately to Step 2B

---

## Step 2B: Deploy Workload Landing Zones (Spoke VNets)

**Directories**: 
- `02-landing-zones/workloads/portals-admin-dev/`
- `02-landing-zones/workloads/portals-customer-dev/`

**Purpose**: Creates spoke VNets for admin and customer portals with network isolation.

**Prerequisites**:
- Step 2A (Connectivity) completed

**Creates**:

**Admin Dev Spoke** (10.100.0.0/16):
- Apps subnet (10.100.1.0/24)
- Private Endpoints subnet (10.100.2.0/24)
- VNet Integration subnet (10.100.3.0/24)
- Data subnet (10.100.4.0/24)

**Customer Dev Spoke** (10.110.0.0/16):
- Apps subnet (10.110.1.0/24)
- Private Endpoints subnet (10.110.2.0/24)
- VNet Integration subnet (10.110.3.0/24)
- Data subnet (10.110.4.0/24)

**Commands** (Deploy in Parallel):
```powershell
# Terminal 1 - Admin Portal Network
cd 02-landing-zones/workloads/portals-admin-dev
terraform init -backend-config="key=tfstate-portals-admin-dev"
Start-Job -Name "admin-network" -ScriptBlock {
    Set-Location "c:\Code\ACME\emergent-azure-landing-zone\02-landing-zones\workloads\portals-admin-dev"
    terraform apply -var-file="terraform.tfvars" -auto-approve
}

# Terminal 2 - Customer Portal Network
cd ../portals-customer-dev
terraform init -backend-config="key=tfstate-portals-customer-dev"
Start-Job -Name "customer-network" -ScriptBlock {
    Set-Location "c:\Code\ACME\emergent-azure-landing-zone\02-landing-zones\workloads\portals-customer-dev"
    terraform apply -var-file="terraform.tfvars" -auto-approve
}

# Wait for both deployments to complete
Get-Job | Wait-Job
Get-Job | Receive-Job
```

**Duration**: ~5-10 minutes per VNet (run in parallel to save time)

**Verify**:
```powershell
# Check admin VNet
cd portals-admin-dev
terraform output vnet_id
terraform output subnet_ids

# Check customer VNet
cd ../portals-customer-dev
terraform output vnet_id
terraform output subnet_ids

# View in Azure Portal
az network vnet list --query "[?contains(name, 'portals')].{Name:name, ResourceGroup:resourceGroup, AddressSpace:addressSpace.addressPrefixes[0]}" -o table
```

**Wait Time**: None - proceed immediately to Step 2C

---

## Step 2C: Configure VNet Peering

**Purpose**: Establish hub-and-spoke connectivity and enable private DNS resolution.

**Prerequisites**:
- Step 2A (Hub VNet) completed
- Step 2B (Spoke VNets) completed

**Peering Relationships Required**:
1. Hub ↔ Admin Dev
2. Hub ↔ Customer Dev

**Option 1: Manual Configuration via Azure Portal**

1. Navigate to Hub VNet → Peerings → Add
2. Configure peering:
   - Name: `hub-to-admin-dev`
   - Remote VNet: Select admin dev VNet
   - Enable: "Allow gateway transit" (from hub)
   - Enable: "Allow forwarded traffic"
3. Repeat for customer dev VNet

**Option 2: Azure CLI**

```powershell
# Get VNet resource IDs
$hubVNetId = (cd 02-landing-zones/connectivity; terraform output -raw vnet_id)
$adminVNetId = (cd 02-landing-zones/workloads/portals-admin-dev; terraform output -raw vnet_id)
$customerVNetId = (cd 02-landing-zones/workloads/portals-customer-dev; terraform output -raw vnet_id)

# Get resource group names
$hubRg = (cd 02-landing-zones/connectivity; terraform output -raw resource_group_name)
$adminRg = (cd 02-landing-zones/workloads/portals-admin-dev; terraform output -raw resource_group_name)
$customerRg = (cd 02-landing-zones/workloads/portals-customer-dev; terraform output -raw resource_group_name)

# Create peering: Hub → Admin Dev
az network vnet peering create `
  --name hub-to-admin-dev `
  --resource-group $hubRg `
  --vnet-name vnet-hub-prod-eus2 `
  --remote-vnet $adminVNetId `
  --allow-forwarded-traffic `
  --allow-gateway-transit

# Create peering: Admin Dev → Hub
az network vnet peering create `
  --name admin-dev-to-hub `
  --resource-group $adminRg `
  --vnet-name vnet-portals-admin-dev-eus2 `
  --remote-vnet $hubVNetId `
  --allow-forwarded-traffic `
  --use-remote-gateways false

# Create peering: Hub → Customer Dev
az network vnet peering create `
  --name hub-to-customer-dev `
  --resource-group $hubRg `
  --vnet-name vnet-hub-prod-eus2 `
  --remote-vnet $customerVNetId `
  --allow-forwarded-traffic `
  --allow-gateway-transit

# Create peering: Customer Dev → Hub
az network vnet peering create `
  --name customer-dev-to-hub `
  --resource-group $customerRg `
  --vnet-name vnet-portals-customer-dev-eus2 `
  --remote-vnet $hubVNetId `
  --allow-forwarded-traffic `
  --use-remote-gateways false
```

**Duration**: ~2-3 minutes

**Verify**:
```powershell
# Check peering status (should be "Connected")
az network vnet peering list --resource-group $hubRg --vnet-name vnet-hub-prod-eus2 -o table
az network vnet peering list --resource-group $adminRg --vnet-name vnet-portals-admin-dev-eus2 -o table
az network vnet peering list --resource-group $customerRg --vnet-name vnet-portals-customer-dev-eus2 -o table

# Test private DNS resolution from a VM in spoke VNet
# nslookup privatelink.azurestaticapps.net
# Should resolve via hub's private DNS zone
```

**Wait Time**: 2-5 minutes for peering to establish connectivity

---

## Step 3: Deploy Workloads

**Directories**: 
- `03-workloads/portals/admin-portal/`
- `03-workloads/portals/customer-portal/`

**Purpose**: Deploys Azure Static Web Apps for admin and customer portals.

**Prerequisites**:
- Step 2A, 2B, 2C completed
- VNet peering established (for private DNS resolution)

**Subscriptions**:
- Admin Portal Dev: 588aa873-b13e-40bc-a96f-89805c56d7d0
- Customer Portal Dev: 9a877ddf-9796-43a8-a557-f6af1df195bf

**Configuration**:

Admin portal `dev.tfvars`:
```hcl
environment     = "dev"
subscription_id = "588aa873-b13e-40bc-a96f-89805c56d7d0"
location        = "eastus2"

# For production with private endpoint:
# enable_private_endpoint = true
# private_endpoint_subnet_id = "<from-landing-zone-output>"
```

Customer portal `dev.tfvars`:
```hcl
environment     = "dev"
subscription_id = "9a877ddf-9796-43a8-a557-f6af1df195bf"
location        = "eastus2"

# For production with private endpoint:
# enable_private_endpoint = true
# private_endpoint_subnet_id = "<from-landing-zone-output>"
```

**Commands**:
```powershell
# Deploy admin portal
cd 03-workloads/portals/admin-portal
terraform init -backend-config="key=tfstate-admin-portal-dev"
terraform apply -var-file="dev.tfvars" -auto-approve

# Deploy customer portal
cd ../customer-portal
terraform init -backend-config="key=tfstate-customer-portal-dev"
terraform apply -var-file="dev.tfvars" -auto-approve
```

**Duration**: ~3-5 minutes per Static Web App

**Verify**:
```powershell
# Check Static Web Apps created
az staticwebapp list --query "[].{Name:name, ResourceGroup:resourceGroup, Hostname:defaultHostname, SKU:sku.name}" -o table

# Get deployment tokens (for CI/CD)
cd admin-portal
terraform output -raw static_web_app_api_key

cd ../customer-portal
terraform output -raw static_web_app_api_key

# Test URLs
$adminUrl = (cd admin-portal; terraform output -raw static_web_app_default_hostname)
$customerUrl = (cd customer-portal; terraform output -raw static_web_app_default_hostname)
Write-Host "Admin Portal: https://$adminUrl"
Write-Host "Customer Portal: https://$customerUrl"
```

**Wait Time**: None - workloads are deployed

---

## Post-Deployment Steps

### 1. Configure CI/CD Pipelines

Use the Static Web App deployment tokens for GitHub Actions or Azure DevOps:

```yaml
# .github/workflows/deploy-admin-portal.yml
name: Deploy Admin Portal
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.ADMIN_PORTAL_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/admin-portal"
```

### 2. Add Private Endpoints (Production)

For production deployments:

1. Update `prod.tfvars`:
   ```hcl
   static_web_app_sku = "Standard"
   enable_private_endpoint = true
   private_endpoint_subnet_id = "<from-landing-zone>"
   ```

2. Deploy production:
   ```powershell
   terraform init -backend-config="key=tfstate-admin-portal-prod" -reconfigure
   terraform apply -var-file="prod.tfvars"
   ```

### 3. Monitor Resources

```powershell
# View activity logs
az monitor activity-log list --resource-group <rg-name> --offset 1h

# Check policy compliance
az policy state list --resource <resource-id>

# Monitor network traffic (if Firewall deployed)
az monitor diagnostic-settings list --resource <firewall-id>
```

---

## Troubleshooting

### VNet Peering Not Connected

```powershell
# Check peering status
az network vnet peering show --name hub-to-admin-dev --resource-group <hub-rg> --vnet-name vnet-hub-prod-eus2

# Common issues:
# - Overlapping address spaces (check IPAM)
# - Insufficient permissions
# - VNet in failed state
```

### Private DNS Not Resolving

```powershell
# Check VNet link to private DNS zone
az network private-dns link vnet list --zone-name privatelink.azurestaticapps.net --resource-group <connectivity-privatedns-rg> -o table

# Verify peering allows DNS forwarding
az network vnet peering list --resource-group <hub-rg> --vnet-name vnet-hub-prod-eus2 --query "[].{Name:name, AllowForwardedTraffic:allowForwardedTraffic}"
```

### Deployment Timeouts

```powershell
# azapi provider can be slow for VNet creation (3-10 minutes)
# Check deployment status
terraform show

# If stuck, check Azure activity log
az monitor activity-log list --resource-group <rg-name> --offset 30m
```

### Policy Violations

```powershell
# Check policy compliance
az policy state list --resource-group <rg-name>

# Common issues:
# - Missing required tags
# - Disallowed location
# - Public IP not allowed

# Remediate or request policy exemption
```

---

## Summary

**Total Deployment Time**: ~20-30 minutes

1. **Bootstrap** (one-time): ~3 minutes
2. **ALZ Foundation**: ~10 minutes
3. **Connectivity Hub**: ~10 minutes
4. **Spoke VNets** (parallel): ~10 minutes
5. **VNet Peering**: ~3 minutes
6. **Workloads**: ~5 minutes per app

**Network Architecture Deployed**:
- Hub VNet (10.0.0.0/16) with 6 subnets
- 11 Private DNS zones
- Admin Dev Spoke (10.100.0.0/16) with 4 subnets
- Customer Dev Spoke (10.110.0.0/16) with 4 subnets
- Hub-and-spoke peering relationships

**Next Steps**:
- Deploy frontend code to Static Web Apps
- Configure custom domains
- Add private endpoints for production
- Deploy production networks (portals-admin-prod, portals-customer-prod)
- Add monitoring and alerting
echo "3. Check Azure Portal → Policy to see compliance status"
```

Make executable: `chmod +x deploy-all.sh`

---

## Manual Deployment Checklist

Use this checklist for manual deployments:

- [ ] **1. Review Prerequisites**
  - [ ] Azure CLI installed and logged in
  - [ ] Terraform >= 1.3.0 installed
  - [ ] Owner or Contributor role on subscription
  - [ ] User Access Administrator role for RBAC

- [ ] **2. Deploy ALZ Foundation**
  - [ ] `cd 01-foundation`
  - [ ] Review `terraform.tfvars` settings
  - [ ] `terraform init`
  - [ ] `terraform plan` (review 540 resources)
  - [ ] `terraform apply`
  - [ ] Verify management groups in Azure Portal

- [ ] **3. Deploy Landing Zone**
  - [ ] `cd ../02-landing-zones`
  - [ ] `cp terraform.tfvars.example terraform.tfvars`
  - [ ] Edit `terraform.tfvars` with correct management group name
  - [ ] `terraform init`
  - [ ] `terraform plan`
  - [ ] `terraform apply`
  - [ ] Save Log Analytics workspace ID: `terraform output -raw log_analytics_workspace_resource_id`
  - [ ] Wait 2-5 minutes for policy propagation

- [ ] **4. Deploy Workload**
  - [ ] `cd ../03-workloads/web-app`
  - [ ] `cp terraform.tfvars.example terraform.tfvars`
  - [ ] Edit `terraform.tfvars` with Log Analytics ID from Step 3
  - [ ] `terraform init`
  - [ ] `terraform plan`
  - [ ] `terraform apply`
  - [ ] Test web app: `curl https://$(terraform output -raw web_app_default_hostname)`

- [ ] **5. Verify Deployment**
  - [ ] Check management group hierarchy in Portal
  - [ ] Review policy compliance status
  - [ ] Verify web app is running
  - [ ] Check Application Insights for telemetry
  - [ ] Review Log Analytics for diagnostic logs

---

## Troubleshooting

### Step 1 Fails: ALZ Foundation

**Error**: Policy library not found
```
Solution: Verify ALZ provider configuration in 01-foundation/main.tf
Check that library_references uses platform/alz@2025.09.0
```

**Error**: Insufficient permissions
```
Solution: Verify you have Owner role on subscription
Run: az role assignment create --assignee <your-user-id> --role Owner --scope /subscriptions/<sub-id>
```

### Step 2 Fails: Landing Zone

**Error**: Management group not found
```
Solution: Wait for ALZ foundation to complete, then retry
Check: terraform output -raw management_group_ids (in 01-foundation/)
```

**Error**: Cannot move subscription
```
Solution: Verify permissions on subscription
Run: az account show --subscription <sub-id> --query "{name:name, state:state}"
```

### Step 3 Fails: Workload

**Error**: Policy violation (e.g., location not allowed)
```
Solution: Check policy assignments in Azure Portal → Policy
Verify workload location matches allowed locations in policy
```

**Error**: Cannot write to Log Analytics
```
Solution: Verify workspace ID is correct
Check: terraform output -raw log_analytics_workspace_resource_id (in 02-landing-zones/)
Ensure workspace exists and managed identity has access
```

---

## Teardown Order

To remove everything (reverse order):

```bash
# Step 1: Destroy workloads
cd 03-workloads/web-app
terraform destroy -auto-approve

# Step 2: Destroy landing zone
cd ../../02-landing-zones
terraform destroy -auto-approve

# Step 3: Destroy ALZ foundation
cd ../01-foundation
terraform destroy -auto-approve
```

**Duration**: ~10-15 minutes total

---

## Summary

| Step | Directory | Duration | Resources | Prerequisites |
|------|-----------|----------|-----------|---------------|
| 1 | `alz-foundation/` | 5-10 min | ~540 | Azure subscription |
| 2 | `02-landing-zones/` | 2-3 min | ~3 | Step 1 complete |
| 3 | `workloads/web-app/` | 3-5 min | ~5 | Step 2 complete + 2-5 min wait |

**Total Time**: ~15-20 minutes for complete deployment

**Key Outputs**:
- Step 1: Management group IDs
- Step 2: Log Analytics workspace ID
- Step 3: Web app URL

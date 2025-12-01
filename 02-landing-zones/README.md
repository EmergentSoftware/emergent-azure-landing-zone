# Landing Zone Subscription Placement and Network Infrastructure

This directory contains configurations for placing Azure subscriptions into their respective management groups and deploying landing zone network infrastructure.

## Structure

```
landing-zones/
├── connectivity/              Platform - Connectivity subscription & hub networking
│   ├── main.tf
│   ├── network.tf            Hub VNet (10.0.0.0/16)
│   ├── private-dns.tf        Private DNS zones for Azure services
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── README.md
│
├── workloads/                 Workload landing zones with spoke networks
│   ├── portals-admin-dev/    Admin portal dev (10.100.0.0/16)
│   │   ├── main.tf
│   │   ├── network.tf        Spoke VNet for admin portal
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   └── portals-customer-dev/ Customer portal dev (10.110.0.0/16)
│       ├── main.tf
│       ├── network.tf        Spoke VNet for customer portal
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
├── ipam.yaml                  IP Address Management manifest
└── README.md                  This file
```

## Network Architecture

### Hub-and-Spoke Topology

```
Connectivity (Hub)
├── Hub VNet: 10.0.0.0/16
│   ├── GatewaySubnet: 10.0.0.0/27
│   ├── AzureFirewallSubnet: 10.0.1.0/26
│   ├── AzureBastionSubnet: 10.0.2.0/26
│   ├── Shared Services: 10.0.10.0/24
│   ├── NVA: 10.0.11.0/24
│   └── Management: 10.0.12.0/24
│
└── Private DNS Zones
    ├── privatelink.azurestaticapps.net
    ├── privatelink.blob.core.windows.net
    ├── privatelink.database.windows.net
    └── ... (see connectivity/README.md for full list)

Portals Admin Dev (Spoke)
└── Spoke VNet: 10.100.0.0/16
    ├── Apps: 10.100.1.0/24
    ├── Private Endpoints: 10.100.2.0/24
    ├── VNet Integration: 10.100.3.0/24
    └── Data: 10.100.4.0/24

Portals Customer Dev (Spoke)
└── Spoke VNet: 10.110.0.0/16
    ├── Apps: 10.110.1.0/24
    ├── Private Endpoints: 10.110.2.0/24
    ├── VNet Integration: 10.110.3.0/24
    └── Data: 10.110.4.0/24
```

## Platform Landing Zones

### Connectivity
- **Management Group**: `acme-connectivity`
- **Subscription ID**: `c82e0943-3765-49ff-97ff-92855167f3ea`
- **Purpose**: Hub networking, private DNS zones, VPN/ExpressRoute, firewalls
- **Network**: Hub VNet (10.0.0.0/16)
- **Deployment**: `cd connectivity && terraform apply -var-file="terraform.tfvars"`

## Workload Landing Zones

### Portals Admin Dev
- **Management Group**: `acme-portals`
- **Subscription ID**: `588aa873-b13e-40bc-a96f-89805c56d7d0`
- **Purpose**: Admin portal development environment with isolated network
- **Network**: Spoke VNet (10.100.0.0/16)
- **Deployment**: `cd workloads/portals-admin-dev && terraform apply`

### Portals Customer Dev
- **Management Group**: `acme-portals`
- **Subscription ID**: `9a877ddf-9796-43a8-a557-f6af1df195bf`
- **Purpose**: Customer portal development environment with isolated network
- **Network**: Spoke VNet (10.110.0.0/16)
- **Deployment**: `cd workloads/portals-customer-dev && terraform apply`

## Quick Start

### 1. Deploy Connectivity (Hub Network + Private DNS)

```powershell
cd connectivity

# Initialize backend
terraform init -reconfigure `
  -backend-config="resource_group_name=acme-rg-prod-eus-vw01" `
  -backend-config="storage_account_name=acmestprodeusvw01" `
  -backend-config="container_name=tfstate-connectivity" `
  -backend-config="key=connectivity.tfstate"

# Deploy hub VNet and private DNS zones
terraform apply -var-file="terraform.tfvars"
```

This creates:
- Hub VNet (10.0.0.0/16) with 6 subnets
- Private DNS zones for Azure services
- VNet links from private DNS zones to hub VNet

### 2. Deploy Workload Landing Zones (Spoke Networks)

Deploy both portals in parallel for faster completion:

```powershell
# Admin portal network (10.100.0.0/16)
cd workloads/portals-admin-dev
terraform init -reconfigure `
  -backend-config="resource_group_name=acme-rg-prod-eus-vw01" `
  -backend-config="storage_account_name=acmestprodeusvw01" `
  -backend-config="container_name=tfstate-portal-dev" `
  -backend-config="key=portals-admin-dev.tfstate"
terraform apply

# Customer portal network (10.110.0.0/16)
cd ../portals-customer-dev
terraform init -reconfigure `
  -backend-config="resource_group_name=acme-rg-prod-eus-vw01" `
  -backend-config="storage_account_name=acmestprodeusvw01" `
  -backend-config="container_name=tfstate-portal-dev" `
  -backend-config="key=portals-customer-dev.tfstate"
terraform apply
```

Each creates:
- Spoke VNet with 4 subnets (apps, private endpoints, integration, data)
- Log Analytics workspace
- Network resource group
- Monitoring resource group
- Subscription association to acme-portals management group

## IPAM - IP Address Management

All network IP allocations are defined in `ipam.yaml`:

```yaml
connectivity:
  hub:
    vnet: 10.0.0.0/16
    
portals-admin-dev:
  vnet: 10.100.0.0/16
  
portals-customer-dev:
  vnet: 10.110.0.0/16
```

The Terraform configurations read from this file to ensure consistent IP allocation across all landing zones.

## Private DNS Integration

Private DNS zones are centralized in the connectivity subscription:

- **Static Web Apps**: `privatelink.azurestaticapps.net`
- **Storage**: blob, file, table, queue endpoints
- **SQL Database**: `privatelink.database.windows.net`
- **Cosmos DB**: `privatelink.documents.azure.com`
- **Key Vault**: `privatelink.vaultcore.azure.net`
- **App Service**: `privatelink.azurewebsites.net`
- **Container Registry**: `privatelink.azurecr.io`
- **Service Bus / Event Hub**: `privatelink.servicebus.windows.net`

Once VNet peering is configured, spoke VNets automatically resolve private endpoints using these zones.

## Network Isolation Strategy

Each portal workload has its own dedicated VNet in its own subscription:

- **Admin Portal**: Isolated network in subscription `588aa873-b13e-40bc-a96f-89805c56d7d0`
- **Customer Portal**: Isolated network in subscription `9a877ddf-9796-43a8-a557-f6af1df195bf`

This provides:
- Security boundary separation
- Independent network policies and NSGs
- Separate blast radius
- Compliance with workload-per-subscription model

## Deployment Order

```
Step 1: 01-foundation/          → Creates management groups & policies
         ↓
Step 2: 02-landing-zones/       → Places subscriptions into management groups (THIS)
         ↓  
Step 3: 03-workloads/           → Deploys application resources
```

## Backend Configuration

Each landing zone uses a separate Terraform state in the `tfstate-portal-dev` container (shared by portal landing zones) or dedicated containers:

- **connectivity**: `tfstate-connectivity` container → `connectivity.tfstate`
- **portals-admin-dev**: `tfstate-portal-dev` container → `portals-admin-dev.tfstate`
- **portals-customer-dev**: `tfstate-portal-dev` container → `portals-customer-dev.tfstate`

All state files are stored in:
- **Resource Group**: `acme-rg-prod-eus-vw01`
- **Storage Account**: `acmestprodeusvw01`

## Next Steps

After deploying landing zones:

1. **Configure VNet Peering** (hub ↔ spokes)
   - Peer hub VNet to portals-admin-dev VNet
   - Peer hub VNet to portals-customer-dev VNet

2. **Deploy Workloads**
   - `03-workloads/portals/admin-portal` - Admin portal Static Web App
   - `03-workloads/portals/customer-portal` - Customer portal Static Web App

3. **Add Private Endpoints**
   - Configure Static Web Apps to use private endpoints
   - Endpoints will use centralized private DNS zones

## Verification

Verify network deployment:

```powershell
# Check connectivity hub VNet
az network vnet show --name vnet-hub-prod-eus2 `
  --resource-group acme-rg-connectivity-network-prod-eus2-{unique}

# Check admin portal spoke VNet
az network vnet show --name vnet-portals-admin-dev-eus2 `
  --resource-group acme-rg-portals-admin-network-dev-eus2

# Check customer portal spoke VNet
az network vnet show --name vnet-portals-customer-dev-eus2 `
  --resource-group acme-rg-portals-customer-network-dev-eus2

# List private DNS zones
az network private-dns zone list `
  --resource-group acme-rg-connectivity-privatedns-prod-eus2-{unique} `
  --output table
```

# Check management subscription
az account management-group show --name acme-management

# Check portals dev subscription
az account management-group show --name acme-portals
```

## Notes

- Platform subscriptions (connectivity, identity, management) only create subscription associations
- Workload subscriptions (portals-dev) also create Log Analytics workspace for monitoring
- All subscription IDs are set as defaults in `variables.tf` files
- Only `tenant_id` needs to be provided in `terraform.tfvars`

## Creating Additional Landing Zones

To create a new workload landing zone:

1. **Copy an existing landing zone** as a template:
   ```bash
   cp -r workloads/portals-dev workloads/my-new-app
   ```

2. **Update the configuration** in `terraform.tfvars`:
   ```hcl
   landing_zone_name = "my-new-app"
   environment       = "dev"  # or "prod"
   subscription_id   = "your-subscription-id"
   ```

3. **Update naming suffix** in `main.tf`:
   ```hcl
   module "naming" {
     source   = "../../../shared-modules/naming"
     location = var.location
     suffix   = ["myapp", var.environment]  # Change "myapp" to your identifier
   }
   ```

4. **Deploy**:
   ```bash
   cd workloads/my-new-app
   terraform init -backend-config=../../../00-bootstrap/backend-config-my-new-app.txt
   terraform apply
   ```

## Outputs

Each landing zone provides outputs for connecting workloads:

```bash
# Networking outputs
terraform output networking_resource_group_name
terraform output virtual_network_name
terraform output virtual_network_id
terraform output subnets

# Monitoring outputs
terraform output monitoring_resource_group_name
terraform output log_analytics_workspace_id
terraform output log_analytics_workspace_name
```

## Using Landing Zone Resources in Workloads

Reference the landing zone's networking and monitoring resources in your workload deployments:

```hcl
# Get the VNet for peering or subnet references
data "azurerm_virtual_network" "landing_zone" {
  name                = "acme-vnet-portals-dev-eus-xxxx"
  resource_group_name = "acme-rg-portals-dev-eus-net"
}

# Get the Log Analytics workspace for diagnostics
data "azurerm_log_analytics_workspace" "landing_zone" {
  name                = "acme-log-portals-dev-eus-xxxx"
  resource_group_name = "acme-rg-portals-dev-eus-mon"
}
```

## Policy Compliance

After placing a subscription into a landing zone:
- It inherits policies from the management group
- Some policies may require specific configurations (e.g., allowed locations)
- Review policy assignments in the Azure Portal

## Naming Convention

All resources follow a consistent naming pattern:

```
Pattern: acme-{resource-type}-{landing-zone}-{environment}-{region-abbr}-{role}

Examples:
- acme-rg-mgmt-prod-eus-net         (Management networking RG)
- acme-rg-portals-dev-eus-mon       (Portals monitoring RG)
- acme-vnet-mgmt-prod-eus-jdqy      (Management VNet with unique suffix)
- acme-log-portals-dev-eus-zwtx     (Portals Log Analytics)
```

**Components:**
- `acme` - Organization prefix
- `{resource-type}` - Azure resource type (rg, vnet, log, etc.)
- `{landing-zone}` - Landing zone identifier (mgmt, portals, etc.)
- `{environment}` - Environment (prod, dev, test)
- `{region-abbr}` - Abbreviated region (eus = East US)
- `{role}` - Resource purpose (net = networking, mon = monitoring)
- `{unique}` - Auto-generated 4-character suffix for globally unique names

## Troubleshooting

### Subscription Not Moving
1. Verify Owner or User Access Administrator role on the subscription
2. Check Azure Portal → Management Groups
3. Wait a few minutes for propagation

### Policy Conflicts
1. Check Azure Portal → Policy → Compliance
2. Review Activity Log for denied operations
3. Update workload to comply or adjust policies in foundation

### State Lock Issues
If terraform operations fail due to state locks:
```bash
terraform force-unlock <lock-id>
```

## Best Practices

1. **Separate Landing Zones**: One per workload type or application family
2. **Shared Infrastructure**: Use landing zone VNet and Log Analytics for all related workloads
3. **Consistent Naming**: Follow the established naming convention
4. **Resource Tagging**: Apply consistent tags for cost tracking and governance
5. **Network Planning**: Ensure VNet address spaces don't overlap between landing zones

## Clean Up

To remove a landing zone (⚠️ WARNING: Destroy workloads first):

```bash
# 1. Destroy all workloads using this landing zone
cd ../../03-workloads/portals
terraform destroy

# 2. Then destroy the landing zone infrastructure
cd ../../02-landing-zones/workloads/portals-dev
terraform destroy
```

This will:
- Delete virtual network and subnets
- Delete Log Analytics workspace (❌ logs will be lost)
- Delete resource groups
- Remove subscription from management group

## Additional Resources

- [Azure Landing Zones Documentation](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/)

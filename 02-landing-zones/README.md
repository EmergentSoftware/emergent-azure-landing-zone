# Landing Zone Subscription Placement

This directory contains configurations for placing Azure subscriptions into landing zone management groups with shared networking and monitoring resources.

## Structure

Each landing zone type has its own directory:

```
landing-zones/
├── corp/                    Corporate landing zones (internal apps)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── online/                  Online landing zones (internet-facing apps)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── README.md               This file
```

## Landing Zone Types

### Corporate (`corp/`)
For internal, corporate applications:
- **Management Group**: `acme-landingzones-corp`
- **Network Range**: `10.0.0.0/16` (default)
- **Connectivity**: Can be connected to on-premises via ExpressRoute/VPN
- **DNS**: Typically uses corporate DNS servers
- **Use Cases**: Intranet apps, internal APIs, employee portals

### Online (`online/`)
For internet-facing, public applications:
- **Management Group**: `acme-landingzones-online`
- **Network Range**: `10.1.0.0/16` (default)
- **Connectivity**: Internet-facing with public endpoints
- **DNS**: Azure default DNS
- **Use Cases**: Public websites, customer APIs, e-commerce

## Quick Start

### 1. Choose Landing Zone Type

Decide whether your workload is corporate (internal) or online (public-facing).

### 2. Configure the Landing Zone

```bash
# For Corporate Landing Zone
cd landing-zones/corp
cp terraform.tfvars.example terraform.tfvars

# OR for Online Landing Zone
cd landing-zones/online
cp terraform.tfvars.example terraform.tfvars
```

### 3. Edit Configuration

Edit `terraform.tfvars`:
- Update `landing_zone_name` (e.g., "corp-web-apps" or "online-apis")
- Customize network address space if needed
- Configure subnets for your workload types
- Set custom DNS servers (corp) or use Azure default (online)

### 4. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 5. Get Outputs

```bash
# Virtual Network ID (for workload integration)
terraform output -raw virtual_network_id

# Subnet IDs (for deploying resources)
terraform output subnets

# Log Analytics workspace (for diagnostics)
terraform output -raw log_analytics_workspace_resource_id
```

## What Each Landing Zone Creates

### Networking Resources
- **Resource Group**: `rg-{landing_zone_name}-networking-{location}`
- **Virtual Network**: `vnet-{landing_zone_name}-{location}`
  - Subnets as configured (default, webapp, data, etc.)
  - Service endpoints enabled per subnet
  - Optional custom DNS servers

### Monitoring Resources
- **Resource Group**: `rg-{landing_zone_name}-monitoring-{location}`
- **Log Analytics Workspace**: `log-{landing_zone_name}-{location}`
  - Configurable retention period
  - Shared by all workloads in this landing zone

### Management
- **Subscription Association**: Links subscription to management group
  - Inherits policies from ALZ foundation
  - Enables governance and compliance

## Example: Corporate Web Applications

```bash
cd landing-zones/corp
```

Edit `terraform.tfvars`:
```hcl
landing_zone_name = "corp-web-apps"
location          = "eastus"

vnet_address_space = ["10.10.0.0/16"]

vnet_subnets = {
  frontend = {
    address_prefixes  = ["10.10.1.0/24"]
    service_endpoints = ["Microsoft.Web"]
  }
  backend = {
    address_prefixes  = ["10.10.2.0/24"]
    service_endpoints = ["Microsoft.Web", "Microsoft.Sql"]
  }
  database = {
    address_prefixes  = ["10.10.3.0/24"]
    service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
  }
}

vnet_dns_servers = ["10.100.1.4", "10.100.1.5"]  # Corporate DNS
```

Deploy:
```bash
terraform apply
```

## Example: Online API Platform

```bash
cd landing-zones/online
```

Edit `terraform.tfvars`:
```hcl
landing_zone_name = "online-public-apis"
location          = "eastus"

vnet_address_space = ["10.20.0.0/16"]

vnet_subnets = {
  apim = {
    address_prefixes  = ["10.20.1.0/24"]
    service_endpoints = ["Microsoft.Web", "Microsoft.KeyVault"]
  }
  backend = {
    address_prefixes  = ["10.20.2.0/24"]
    service_endpoints = ["Microsoft.Web", "Microsoft.Sql", "Microsoft.Storage"]
  }
}

# Use Azure default DNS for internet-facing workloads
vnet_dns_servers = null
```

Deploy:
```bash
terraform apply
```

## Multiple Landing Zones

You can create multiple instances of the same type:

### Option A: Terraform Workspaces

```bash
cd landing-zones/corp

# Create workspace for dev environment
terraform workspace new corp-dev
terraform apply -var="landing_zone_name=corp-dev-apps"

# Create workspace for prod environment
terraform workspace new corp-prod
terraform apply -var="landing_zone_name=corp-prod-apps"
```

### Option B: Separate Directories

```bash
mkdir -p landing-zones/corp-dev
mkdir -p landing-zones/corp-prod

# Create symlinks to shared files
cd landing-zones/corp-dev
ln -s ../corp/main.tf .
ln -s ../corp/variables.tf .
ln -s ../corp/outputs.tf .

# Create unique terraform.tfvars for each
```

## Purpose

In Azure Landing Zones architecture:
1. **ALZ Foundation** creates the management group hierarchy and policies
2. **Landing Zone Placement** (this) associates subscriptions with management groups
3. **Workloads** deploy application resources into the placed subscriptions

## Deployment Order

```
Step 1: alz-foundation/     → Creates management groups & policies
         ↓
Step 2: landing-zones/      → Places subscription into management group (THIS)
         ↓
Step 3: workloads/web-app/  → Deploys application resources
```

## Management Group Options

Based on the ALZ foundation, you can place subscriptions into:

- **`acme-landingzones-corp`** - For corporate/internal applications
  - Connected to on-premises via ExpressRoute/VPN
  - Stricter compliance and security policies
  
- **`acme-landingzones-online`** - For internet-facing applications
  - Public endpoints allowed
  - More flexible networking

- **`acme-platform`** - For platform services (monitoring, connectivity, identity)

## Quick Start

### 1. Deploy ALZ Foundation First

```bash
cd alz-foundation
terraform init
terraform plan
terraform apply
```

### 2. Configure Landing Zone

```bash
cd ../landing-zones
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

Key settings:
- `landing_zone_management_group_name`: Use `acme-landingzones-corp` or `acme-landingzones-online`
- `workload_subscription_id`: The subscription to place in the landing zone

### 3. Deploy Landing Zone Placement

```bash
terraform init
terraform plan
terraform apply
```

### 4. Get Log Analytics Workspace ID

```bash
terraform output log_analytics_workspace_resource_id
```

Copy this value - you'll use it in your workload deployments.

### 5. Deploy Workloads

```bash
cd ../workloads/web-app
# Update terraform.tfvars with the Log Analytics workspace ID from step 4
terraform init
terraform plan
terraform apply
```

## What This Creates

### Subscription Association
- Places your subscription under the specified management group
- Inherits all policies from the management group hierarchy

### Optional Monitoring Resources
If `create_log_analytics = true`:
- **Resource Group**: `rg-{landing_zone_name}-monitoring-{location}`
- **Log Analytics Workspace**: `log-{landing_zone_name}-{location}`

These can be shared by all workloads in this landing zone.

## Example Scenarios

### Scenario 1: Corporate Web Application

```hcl
landing_zone_name                  = "corp-web-apps"
landing_zone_management_group_name = "acme-landingzones-corp"
workload_subscription_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### Scenario 2: Public API Platform

```hcl
landing_zone_name                  = "online-public-apis"
landing_zone_management_group_name = "acme-landingzones-online"
workload_subscription_id           = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
```

## Multiple Landing Zones

To create multiple landing zones, either:

**Option A: Use Workspaces**
```bash
terraform workspace new prod-corp
terraform workspace new prod-online
terraform workspace select prod-corp
terraform apply
```

**Option B: Separate Directories**
```
landing-zones/
├── corp-web-apps/
│   ├── main.tf -> ../main.tf (symlink)
│   └── terraform.tfvars
└── online-apis/
    ├── main.tf -> ../main.tf (symlink)
    └── terraform.tfvars
```

## Outputs

Use these outputs in your workload deployments:

```bash
# Get the Log Analytics workspace ID for workload diagnostics
terraform output -raw log_analytics_workspace_resource_id

# Verify subscription placement
terraform output management_group_id
```

## Connect to Workloads

In your workload's `terraform.tfvars`:

```hcl
# From landing-zones output
log_analytics_workspace_id = "/subscriptions/.../resourceGroups/rg-corp-web-apps-monitoring-eastus/providers/Microsoft.OperationalInsights/workspaces/log-corp-web-apps-eastus"

# Ensure subscription_id matches
subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

## Policy Compliance

After placing a subscription into a landing zone:
- It inherits policies from the management group
- Some policies may require specific configurations (e.g., allowed locations)
- Review policy assignments in the Azure Portal

## Troubleshooting

### Subscription Not Moving

If the subscription doesn't appear under the management group:
1. Verify you have Owner or User Access Administrator role on the subscription
2. Check Azure Portal → Management Groups → Find your subscription
3. Wait a few minutes for Azure Resource Manager to propagate changes

### Policy Conflicts

If workload deployment fails due to policies:
1. Check Azure Portal → Policy → Compliance
2. Review denied operations in Activity Log
3. Either fix the workload to comply, or modify policy assignments in alz-foundation

### Log Analytics Access

If workloads can't write to Log Analytics:
1. Verify the workspace exists: `terraform output log_analytics_workspace_id`
2. Ensure workload's managed identity has Contributor role on workspace
3. Check firewall rules if workspace has network restrictions

## Best Practices

1. **One Landing Zone per Subscription Type**: Separate corp vs online workloads
2. **Shared Monitoring**: Use the landing zone's Log Analytics for all workloads
3. **Consistent Naming**: Use `{org}-landingzones-{type}` pattern
4. **Tag Everything**: Apply consistent tags for cost tracking
5. **Document Dependencies**: Note which workloads depend on this landing zone

## Clean Up

To remove a landing zone (WARNING: This affects all workloads):

```bash
# 1. Destroy all workloads first
cd ../workloads/web-app
terraform destroy

# 2. Then destroy the landing zone
cd ../../landing-zones
terraform destroy
```

This will:
- Remove subscription from management group
- Delete Log Analytics workspace and monitoring resources
- Workloads will lose inherited policies

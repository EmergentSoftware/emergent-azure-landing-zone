# Landing Zone Workload Module

This module encapsulates the complete common pattern for all workload landing zones in the Azure Landing Zone architecture.

## Features

- **Management Group Association**: Associates the subscription with the appropriate management group
- **Naming Convention**: Provides consistent Azure resource naming via the naming module
- **Monitoring**: Optional Log Analytics workspace and monitoring resource group
- **Networking**: Complete spoke VNet infrastructure with NSGs, route tables, and subnets based on IPAM configuration
- **Tagging**: Standardized tagging strategy with environment, purpose, and landing zone metadata

## Usage

```hcl
module "landing_zone" {
  source = "../../../shared-modules/pattern-modules/landing-zone-workload"

  # Subscription Configuration
  subscription_id       = "00000000-0000-0000-0000-000000000000"
  tenant_id            = "00000000-0000-0000-0000-000000000000"
  management_group_name = "acme-portals"

  # Landing Zone Metadata
  landing_zone_name = "portals-admin-dev"
  purpose           = "Landing Zone - Portal Admin Dev"
  environment       = "dev"
  location          = "eastus"
  naming_suffix     = ["portals", "dev"]

  # Monitoring
  create_log_analytics = true
  log_retention_days   = 30

  # Networking - References IPAM configuration
  ipam_config_path = "../../ipam.yaml"
  ipam_key         = "portals-admin-dev"

  # Tags
  tags = {
    CostCenter = "IT"
  }
}
```

## What This Module Includes

### Core Infrastructure
1. **Subscription Association**: Places subscription in the correct management group
2. **Naming Module**: Configured with appropriate suffix for resource naming
3. **Common Tags**: Standardized tags for all resources

### Monitoring Resources
4. **Monitoring Resource Group**: Created if `create_log_analytics = true`
5. **Log Analytics Workspace**: Created if `create_log_analytics = true`

### Network Resources (IPAM-Driven)
6. **Network Resource Group**: For all networking resources
7. **Virtual Network**: Spoke VNet with address space from IPAM
8. **Network Security Groups**: One NSG per subnet, dynamically created
9. **Route Tables**: One route table per subnet, dynamically created
10. **Subnets**: All subnets defined in IPAM with proper associations to NSGs and route tables
11. **Service Endpoints**: Configured per subnet as defined in IPAM
12. **Subnet Delegations**: Applied where specified in IPAM (e.g., for App Service VNet integration)

## IPAM Configuration

The module reads network configuration from a centralized IPAM YAML file. Example structure:

```yaml
portals-admin-dev:
  location: "eastus2"
  location_short: "eus2"
  vnet:
    name: "acme-vnet-portals-admin-dev-eus2"
    address_space: "10.100.0.0/16"
    dns_servers: []

  subnets:
    - name: "acme-snet-portals-admin-apps-dev-eus2"
      address_prefix: "10.100.1.0/24"
      purpose: "Admin portal application workloads"
      service_endpoints: []
      delegations: []

    - name: "acme-snet-portals-admin-pes-dev-eus2"
      address_prefix: "10.100.2.0/24"
      purpose: "Private endpoints for Static Web App, Storage, etc."
      service_endpoints: []
      delegations: []
      private_endpoint_network_policies: "Disabled"
```

## What You Still Need to Add

Workload landing zones using this module only need to add:
- **VNet Peering**: Define peering to hub VNet (if required)
- **Custom NSG Rules**: Add any workload-specific NSG rules beyond defaults
- **Custom Routes**: Add any specific routing requirements

All other infrastructure is provided by the pattern module!

## Outputs

The module provides comprehensive outputs:

### Subscription & Management
- `management_group_id`
- `subscription_association_id`
- `subscription_id`
- `naming` (naming module)
- `common_tags`

### Monitoring
- `log_analytics_workspace_id`
- `log_analytics_workspace_resource_id`
- `monitoring_resource_group_name`
- `monitoring_resource_group_id`

### Networking
- `vnet_id`
- `vnet_name`
- `vnet_address_space`
- `network_resource_group_name`
- `network_resource_group_id`
- `subnets` (map of all subnets)
- `nsg_ids` (map of all NSG IDs)
- `route_table_ids` (map of all route table IDs)

## Example Complete Landing Zone Structure

```
02-landing-zones/workloads/my-workload-dev/
├── main.tf           # Uses this module (single module call!)
├── providers.tf      # Provider and backend configuration
├── locals.tf         # Any workload-specific local values
├── variables.tf      # Workload-specific variables
├── outputs.tf        # Workload-specific outputs
├── terraform.tfvars  # Variable values (just tenant_id)
└── backend.tfbackend # Backend configuration
```

Note: **network.tf is no longer needed** - all networking is in the pattern module!

## Benefits

- **Maximum Consistency**: All workload landing zones follow identical pattern
- **Minimal Code**: Each landing zone is just ~30 lines of configuration
- **IPAM-Driven**: All network configuration centralized in IPAM manifest
- **Reduced Duplication**: No repeated NSG, route table, subnet definitions
- **Easier Maintenance**: Updates to the pattern apply to all workloads
- **Faster Deployment**: New workloads deploy in minutes, not hours
- **Standardized Security**: NSGs and route tables follow consistent pattern

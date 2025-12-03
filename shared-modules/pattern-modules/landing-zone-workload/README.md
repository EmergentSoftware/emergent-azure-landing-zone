# Landing Zone Workload Module

This module encapsulates the common pattern for all workload landing zones in the Azure Landing Zone architecture.

## Features

- **Management Group Association**: Associates the subscription with the appropriate management group
- **Naming Convention**: Provides consistent Azure resource naming via the naming module
- **Monitoring**: Optional Log Analytics workspace and monitoring resource group
- **Tagging**: Standardized tagging strategy with environment, purpose, and landing zone metadata

## Usage

```hcl
module "landing_zone" {
  source = "../../../shared-modules/pattern-modules/landing-zone-workload"

  # Subscription Configuration
  subscription_id        = "00000000-0000-0000-0000-000000000000"
  management_group_name  = "acme-portals"

  # Landing Zone Metadata
  landing_zone_name = "portals-admin-dev"
  purpose           = "Landing Zone - Portal Admin Dev"
  environment       = "dev"
  location          = "eastus"
  naming_suffix     = ["portals", "dev"]

  # Monitoring
  create_log_analytics = true
  log_retention_days   = 30

  # Tags
  tags = {
    CostCenter = "IT"
  }
}
```

## What This Module Includes

1. **Subscription Association**: Places subscription in the correct management group
2. **Naming Module**: Configured with appropriate suffix for resource naming
3. **Monitoring Resource Group**: Created if `create_log_analytics = true`
4. **Log Analytics Workspace**: Created if `create_log_analytics = true`
5. **Common Tags**: Standardized tags for all resources

## What You Still Need to Add

Each workload landing zone should include a `network.tf` file alongside this module to define:
- Network resource group
- Virtual network configuration
- Subnets with NSGs and route tables
- VNet peering configuration

## Outputs

The module provides outputs for:
- Management group and subscription association details
- Naming module (for use in network.tf)
- Common tags (for use in network.tf)
- Log Analytics workspace details
- Monitoring resource group details

## Example Complete Landing Zone Structure

```
02-landing-zones/workloads/my-workload-dev/
├── main.tf           # Uses this module + provider/backend config
├── network.tf        # Workload-specific networking (uses module outputs)
├── variables.tf      # Workload-specific variables (tenant_id, etc.)
├── outputs.tf        # Workload-specific outputs
├── terraform.tfvars  # Variable values
└── backend.tfbackend # Backend configuration
```

## Benefits

- **Consistency**: All workload landing zones follow the same pattern
- **Reduced Duplication**: Common code is centralized in one module
- **Easier Maintenance**: Updates to the pattern only need to be made once
- **Faster Deployment**: New workloads can be deployed by simply instantiating this module + adding network.tf

# Shared Modules

This directory contains reusable Terraform modules organized by type.

## Directory Structure

```
shared-modules/
 resource-modules/      # Individual Azure resource wrappers
 utility-modules/       # Helper and utility modules
─ pattern-modules/       # Composite patterns and templates
```

## Module Categories

### Resource Modules (`resource-modules/`)

Thin wrappers around individual Azure resources using Azure Verified Modules (AVM) where available. These modules provide a consistent interface and standardized tagging/naming.

**Available Modules:**
- `app-service-plan` - Azure App Service Plans
- `application-insights` - Application Insights instances
- `log-analytics-workspace` - Log Analytics workspaces
- `network-security-group` - Network Security Groups (NSGs)
- `resource-group` - Azure Resource Groups
- `route-table` - Route Tables (UDRs)
- `virtual-network` - Virtual Networks with subnet support
- `web-app` - Web Apps (App Services)

**When to use:** When you need to deploy a single Azure resource with standardized configuration.

### Utility Modules (`utility-modules/`)

Helper modules that provide supporting functionality without creating resources (or creating minimal supporting resources).

**Available Modules:**
- `naming` - Generates consistent Azure resource names following naming conventions

**When to use:** When you need to generate names, validate configurations, or perform utility operations.

### Pattern Modules (`pattern-modules/`)

Composite modules that encapsulate common deployment patterns by combining multiple resource modules and implementing organizational standards.

**Available Modules:**
- `landing-zone-workload` - Complete workload landing zone pattern (subscription association, monitoring, naming)

**When to use:** When deploying a complete solution or pattern that combines multiple resources following organizational standards.

## Usage Guidelines

### Resource Modules
```hcl
module "my_vnet" {
  source = "../../shared-modules/resource-modules/virtual-network"
  
  name                = "my-vnet"
  resource_group_name = "my-rg"
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]
}
```

### Utility Modules
```hcl
module "naming" {
  source   = "../../shared-modules/utility-modules/naming"
  location = "eastus"
  suffix   = ["app", "dev"]
}

resource "azurerm_resource_group" "example" {
  name     = module.naming.resource_group.name
  location = "eastus"
}
```

### Pattern Modules
```hcl
module "landing_zone" {
  source = "../../shared-modules/pattern-modules/landing-zone-workload"
  
  subscription_id       = var.subscription_id
  management_group_name = "acme-portals"
  landing_zone_name     = "my-workload-dev"
  environment           = "dev"
}
```

## Module Development Guidelines

### Resource Modules
- Wrap a single Azure resource type
- Use Azure Verified Modules (AVM) when available
- Expose commonly-used parameters
- Provide sensible defaults
- Include comprehensive outputs

### Utility Modules
- Provide helper functionality
- Minimize resource creation
- Focus on data transformation or generation
- Keep dependencies minimal

### Pattern Modules
- Combine multiple resource/utility modules
- Implement organizational standards
- Reduce boilerplate in consuming code
- Document the pattern and use cases

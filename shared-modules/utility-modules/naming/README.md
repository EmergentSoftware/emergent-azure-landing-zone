# Naming Wrapper Module

This module wraps the [Azure Naming module](https://github.com/Azure/terraform-azurerm-naming) with a pinned commit hash for security and consistency.

## Purpose

- Provides centralized naming configuration across all layers
- Ensures consistent commit hash usage (security requirement)
- Simplifies future updates to the naming module
- Allows for customization of naming conventions

## Usage

```hcl
module "naming" {
  source = "../../shared-modules/naming"
  suffix = [var.environment, var.location]
}

# Use the naming outputs
resource "azurerm_resource_group" "example" {
  name     = module.naming.resource_group.name_unique
  location = var.location
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| suffix | Suffix to append to resource names | `list(string)` | `[]` | no |
| prefix | Prefix to prepend to resource names | `list(string)` | `[]` | no |
| unique_seed | Custom seed value for unique name generation | `string` | `""` | no |
| unique_length | Length of the unique identifier suffix | `number` | `4` | no |
| unique_include_numbers | Include numbers in the unique identifier | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group | Resource group naming convention |
| storage_account | Storage account naming convention |
| virtual_network | Virtual network naming convention |
| log_analytics_workspace | Log Analytics workspace naming convention |
| app_service_plan | App Service Plan naming convention |
| app_service | App Service naming convention |
| application_insights | Application Insights naming convention |
| naming | All naming conventions (pass-through) |

## Examples

### Bootstrap Layer
```hcl
module "naming" {
  source = "../shared-modules/naming"
  suffix = [var.environment, var.location]
}
```

### Landing Zone
```hcl
module "naming" {
  source = "../../shared-modules/naming"
  suffix = [var.landing_zone_name, var.location]
}
```

### Workload
```hcl
module "naming" {
  source = "../../shared-modules/naming"
  suffix = [var.workload_name, var.environment]
}
```

## Security

This module pins the Azure naming module to commit hash `55e932f8edf91c50e6acf0bd62042766b2d2a120` to satisfy Checkov security requirements and prevent supply chain attacks.

## Maintenance

To update the naming module version:
1. Review the [Azure Naming module releases](https://github.com/Azure/terraform-azurerm-naming/releases)
2. Update the commit hash in `main.tf`
3. Test all layers
4. Update this README with the new commit hash

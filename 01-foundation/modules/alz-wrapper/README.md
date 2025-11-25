# ALZ Wrapper Module

This wrapper module provides an abstraction layer over the Azure Verified Module (AVM) for Azure Landing Zones. It insulates your configuration from potential breaking changes in the upstream module.

## Purpose

- **Insulation**: Protects your root configuration from changes in the external AVM module
- **Consistency**: Provides a stable interface for ACME's ALZ deployments
- **Customization**: Easy place to add ACME-specific defaults or transformations
- **Version Control**: Centralized control over which version of the upstream module is used

## Usage

```hcl
module "alz" {
  source = "./modules/alz-wrapper"

  parent_resource_id = data.azurerm_client_config.current.tenant_id
  architecture_name  = "alz"
  location           = "eastus"

  management_group_hierarchy_settings = {
    default_management_group_name            = "acme-alz"
    require_authorization_for_group_creation = true
  }

  policy_assignments_to_modify = {
    alzroot = {
      policy_assignments = {
        Deny-Resource-Locations = {
          enforcement_mode = "Default"
          parameters = {
            listOfAllowedLocations = jsonencode({
              value = ["eastus", "eastus2"]
            })
          }
        }
      }
    }
  }

  enable_telemetry = true
}
```

## Upstream Module

This wrapper uses: `Azure/avm-ptn-alz/azurerm` version `~> 0.14`

To update the upstream module version, modify the `version` constraint in `main.tf`.

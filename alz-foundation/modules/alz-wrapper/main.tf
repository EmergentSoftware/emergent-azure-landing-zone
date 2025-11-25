# =============================================================================
# ALZ Wrapper Module
# This wrapper module insulates the configuration from changes to the 
# upstream Azure Verified Module (AVM) for Azure Landing Zones
# =============================================================================

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    alz = {
      source  = "azure/alz"
      version = "~> 0.20"
    }
  }
}

module "alz" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "~> 0.14"

  parent_resource_id                  = var.parent_resource_id
  architecture_name                   = var.architecture_name
  location                            = var.location
  management_group_hierarchy_settings = var.management_group_hierarchy_settings
  policy_assignments_to_modify        = var.policy_assignments_to_modify
  policy_default_values               = var.policy_default_values
  enable_telemetry                    = var.enable_telemetry
}

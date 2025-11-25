# =============================================================================
# Azure Landing Zone Demo using Azure Verified Modules (AVM)
# This configuration deploys a CAF-aligned management group hierarchy
# and applies baseline governance policies
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

provider "azurerm" {
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID
  tenant_id       = "00000000-0000-0000-0000-000000000000" # Replace with your tenant ID
}

# Configure the ALZ provider with library references
provider "alz" {
  library_references = [
    {
      path = "platform/alz"
      ref  = "2025.09.0"
    }
  ]
}

# Get current Azure context
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

# =============================================================================
# Deploy Management Groups and Policies using ALZ Wrapper Module
# The wrapper module insulates this configuration from changes to the
# upstream Azure Verified Module (AVM)
# =============================================================================

module "alz" {
  source = "./modules/alz-wrapper"

  # Parent management group - use tenant root group
  parent_resource_id = data.azurerm_client_config.current.tenant_id

  # Architecture definition - uses the default ALZ architecture
  architecture_name = "alz"

  # Default location for policy managed identities
  location = var.default_location

  # Optional: Configure hierarchy settings
  management_group_hierarchy_settings = {
    default_management_group_name            = "acme-alz"
    require_authorization_for_group_creation = true
  }

  # Optional: Modify policy assignments
  policy_assignments_to_modify = {
    alzroot = {
      policy_assignments = {
        # Modify allowed locations
        Deny-Resource-Locations = {
          enforcement_mode = "Default"
          parameters = {
            listOfAllowedLocations = jsonencode({
              value = var.allowed_locations
            })
          }
        }
      }
    }
  }

  # Enable telemetry
  enable_telemetry = var.enable_telemetry
}

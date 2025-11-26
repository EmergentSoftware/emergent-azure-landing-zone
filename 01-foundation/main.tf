# =============================================================================
# Azure Landing Zone Demo using Azure Verified Modules (AVM)
# This configuration deploys a CAF-aligned management group hierarchy
# and applies baseline governance policies
# =============================================================================

terraform {
  required_version = ">= 1.12.0"
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

  backend "azurerm" {
    resource_group_name  = "acme-rg-prod-eus-vw01"
    storage_account_name = "acmestprodeusvw01"
    container_name       = "tfstate-foundation"
    key                  = "foundation.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  tenant_id                       = var.tenant_id
  resource_provider_registrations = "none"
}

# Configure the ALZ provider with library references
provider "alz" {
  library_references = [
    {
      path = "platform/alz"
      ref  = "2025.09.0"
    },
    {
      custom_url = "${path.root}/lib"
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

  # Architecture definition - uses custom ACME architecture with acme-alz prefix
  architecture_name = "acme-alz"

  # Default location for policy managed identities
  location = var.default_location

  # Configure hierarchy settings with ACME prefix
  management_group_hierarchy_settings = {
    default_management_group_name            = "acme-workloads"
    require_authorization_for_group_creation = true
  }

  # Enable telemetry
  enable_telemetry = var.enable_telemetry
}

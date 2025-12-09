# =============================================================================
# Azure Landing Zone Demo using Azure Verified Modules (AVM)
# This configuration deploys a CAF-aligned management group hierarchy
# and applies baseline governance policies
# =============================================================================

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

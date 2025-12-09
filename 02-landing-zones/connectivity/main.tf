# =============================================================================
# Landing Zone Subscription Placement - Connectivity
# This places the connectivity subscription into the acme-connectivity management group
# Deploy this AFTER alz-foundation
# =============================================================================

# Data source to get the acme-connectivity management group
data "azurerm_management_group" "connectivity" {
  name = var.management_group_name
}

# Place the connectivity subscription into the acme-connectivity management group
resource "azurerm_management_group_subscription_association" "connectivity" {
  management_group_id = data.azurerm_management_group.connectivity.id
  subscription_id     = "/subscriptions/${var.subscription_id}"
}

# =============================================================================
# Naming Module for Consistent Azure Resource Naming
# =============================================================================

module "naming" {
  source   = "../../shared-modules/utility-modules/naming"
  location = var.location
  suffix   = ["connectivity", "prod"]
}

# Prepare common tags for all resources
locals {
  common_tags = merge(
    var.tags,
    {
      Purpose         = "Landing Zone - Connectivity"
      LandingZone     = "connectivity"
      Environment     = "production"
      ManagementGroup = var.management_group_name
      ManagedBy       = "Terraform"
      DeployedBy      = "AVM"
    }
  )
}

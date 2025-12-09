# =============================================================================
# Landing Zone Subscription Placement - Identity
# This places the identity subscription into the acme-identity management group
# Deploy this AFTER alz-foundation
# =============================================================================

# Data source to get the acme-identity management group
data "azurerm_management_group" "identity" {
  name = var.management_group_name
}

# Place the identity subscription into the acme-identity management group
resource "azurerm_management_group_subscription_association" "identity" {
  management_group_id = data.azurerm_management_group.identity.id
  subscription_id     = "/subscriptions/${var.subscription_id}"
}

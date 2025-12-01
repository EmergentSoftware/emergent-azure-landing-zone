# =============================================================================
# Static Web App Wrapper Module
# Wraps azurerm_static_web_app resource
# Note: No official AVM module exists for Static Web Apps yet
# =============================================================================

terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_static_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size

  # Disable public network access if private endpoints are configured
  public_network_access_enabled = var.private_endpoint_subnet_id != null ? false : var.public_network_access_enabled

  tags = var.tags

  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}

# Private Endpoint for Static Web App
module "private_endpoint" {
  source = "../private-endpoint"
  count  = var.private_endpoint_subnet_id != null ? 1 : 0

  name                           = "${var.name}-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.private_endpoint_subnet_id
  private_connection_resource_id = azurerm_static_web_app.this.id
  subresource_names              = ["staticSites"]
  private_dns_zone_ids           = var.private_dns_zone_ids

  tags = var.tags
}

# =============================================================================
# App Service Plan Wrapper Module
# Wraps Azure/avm-res-web-serverfarm/azurerm
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

module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "~> 0.2"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name
  tags                = var.tags
}

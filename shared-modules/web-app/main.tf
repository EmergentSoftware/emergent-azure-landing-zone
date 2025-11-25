# =============================================================================
# Web App Wrapper Module
# Wraps Azure/avm-res-web-site/azurerm
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

module "web_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "~> 0.13"

  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  os_type                  = var.os_type
  kind                     = var.kind
  service_plan_resource_id = var.service_plan_resource_id
  https_only               = var.https_only
  site_config              = var.site_config
  app_settings             = var.app_settings
  managed_identities       = var.managed_identities
  diagnostic_settings      = var.diagnostic_settings
  tags                     = var.tags
}

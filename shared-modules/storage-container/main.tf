terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# =============================================================================
# Azure Storage Container
# Wrapper module for azurerm_storage_container
# =============================================================================

resource "azurerm_storage_container" "this" {
  name                  = var.name
  storage_account_id    = var.storage_account_id
  container_access_type = var.container_access_type
  metadata              = var.metadata
}

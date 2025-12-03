# =============================================================================
# Resource Group Wrapper Module
# Wraps Azure/avm-res-resources-resourcegroup/azurerm
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

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.1"

  name     = var.name
  location = var.location
  tags     = var.tags
}

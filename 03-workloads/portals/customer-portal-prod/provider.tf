# =============================================================================
# Terraform Configuration
# =============================================================================

terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    # Backend configuration will be provided via backend config parameters
  }
}

# =============================================================================
# Azure Provider Configuration
# =============================================================================

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

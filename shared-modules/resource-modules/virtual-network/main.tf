# =============================================================================
# Virtual Network Wrapper Module
# Wraps Azure/avm-res-network-virtualnetwork/azurerm
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

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.16"

  name      = var.name
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  location  = var.location

  address_space = var.address_space
  subnets       = var.subnets
  dns_servers   = var.dns_servers

  # Explicitly disable DDoS Protection Plan
  ddos_protection_plan = null

  tags = var.tags
}

# Get current Azure context
data "azurerm_client_config" "current" {}

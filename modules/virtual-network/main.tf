# =============================================================================
# Virtual Network Wrapper Module
# Wraps Azure/avm-res-network-virtualnetwork/azurerm
# =============================================================================

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.7"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space

  subnets = var.subnets

  dns_servers = var.dns_servers

  tags = var.tags
}

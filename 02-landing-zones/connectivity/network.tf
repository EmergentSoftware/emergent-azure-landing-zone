# =============================================================================
# Hub VNet - Connectivity Landing Zone
# Network infrastructure for hub-and-spoke topology
# Based on IPAM manifest: 02-landing-zones/ipam.yaml
# =============================================================================

# Load IPAM configuration
locals {
  ipam = yamldecode(file("${path.module}/../ipam.yaml"))
  hub  = local.ipam.connectivity.hub
}

# Naming module for consistent resource naming
module "naming" {
  source   = "../../shared-modules/naming"
  location = local.hub.location
  suffix   = ["hub", "prod"]
}

# Generate random suffix for unique naming
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Resource Group for Hub Network
module "network_resource_group" {
  source = "../../shared-modules/resource-group"

  name     = "acme-rg-connectivity-network-prod-${local.hub.location_short}-${random_string.suffix.result}"
  location = local.hub.location
  tags = merge(
    var.tags,
    {
      Purpose = "Hub Network Infrastructure"
    }
  )
}

# Hub Virtual Network
module "hub_vnet" {
  source = "../../shared-modules/virtual-network"

  name                = local.hub.vnet.name
  resource_group_name = module.network_resource_group.name
  location            = local.hub.location

  address_space = [local.hub.vnet.address_space]
  dns_servers = length(local.hub.vnet.dns_servers) > 0 ? {
    dns_servers = local.hub.vnet.dns_servers
  } : null

  # Subnets based on IPAM manifest
  subnets = {
    # Gateway Subnet for VPN/ExpressRoute
    GatewaySubnet = {
      name             = "GatewaySubnet"
      address_prefixes = [local.hub.subnets[0].address_prefix]
    }

    # Azure Firewall Subnet
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = [local.hub.subnets[1].address_prefix]
    }

    # Azure Bastion Subnet
    AzureBastionSubnet = {
      name             = "AzureBastionSubnet"
      address_prefixes = [local.hub.subnets[2].address_prefix]
    }

    # Shared Services
    "${local.hub.subnets[3].name}" = {
      name = local.hub.subnets[3].name
      address_prefixes = [local.hub.subnets[3].address_prefix]
      service_endpoints_with_location = [
        for endpoint in local.hub.subnets[3].service_endpoints : {
          service   = endpoint
          locations = ["*"]
        }
      ]
    }

    # Network Virtual Appliances
    "${local.hub.subnets[4].name}" = {
      name             = local.hub.subnets[4].name
      address_prefixes = [local.hub.subnets[4].address_prefix]
    }

    # Management and Monitoring
    "${local.hub.subnets[5].name}" = {
      name = local.hub.subnets[5].name
      address_prefixes = [local.hub.subnets[5].address_prefix]
      service_endpoints_with_location = [
        for endpoint in local.hub.subnets[5].service_endpoints : {
          service   = endpoint
          locations = ["*"]
        }
      ]
    }
  }

  tags = merge(
    var.tags,
    {
      Purpose     = "Hub VNet"
      Environment = "Production"
      IPAM        = "Managed via 02-landing-zones/ipam.yaml"
    }
  )

  depends_on = [module.network_resource_group]
}

# =============================================================================
# Spoke VNet - Portals Dev Landing Zone
# Network infrastructure for portals workloads
# Based on IPAM manifest: 02-landing-zones/ipam.yaml
# =============================================================================

# Load IPAM configuration
locals {
  ipam        = yamldecode(file("${path.module}/../../ipam.yaml"))
  portals_dev = local.ipam["portals-dev"]
}

# Resource Group for Network
resource "azurerm_resource_group" "network" {
  name     = "acme-rg-portals-network-dev-${local.portals_dev.location_short}"
  location = local.portals_dev.location
  tags = merge(
    var.tags,
    {
      Purpose = "Network Infrastructure"
    }
  )
}

# Portals Dev Virtual Network
module "portals_vnet" {
  source = "../../../shared-modules/virtual-network"

  name                = local.portals_dev.vnet.name
  resource_group_name = azurerm_resource_group.network.name
  location            = local.portals_dev.location

  address_space = [local.portals_dev.vnet.address_space]
  dns_servers = length(local.portals_dev.vnet.dns_servers) > 0 ? {
    dns_servers = local.portals_dev.vnet.dns_servers
  } : null

  # Subnets based on IPAM manifest
  subnets = {
    # Application Subnet
    "${local.portals_dev.subnets[0].name}" = {
      name = local.portals_dev.subnets[0].name
      address_prefixes = [local.portals_dev.subnets[0].address_prefix]
      service_endpoints_with_location = [
        for endpoint in local.portals_dev.subnets[0].service_endpoints : {
          service   = endpoint
          locations = ["*"]
        }
      ]
    }

    # Private Endpoints Subnet
    "${local.portals_dev.subnets[1].name}" = {
      name                                      = local.portals_dev.subnets[1].name
      address_prefixes                          = [local.portals_dev.subnets[1].address_prefix]
      private_endpoint_network_policies_enabled = false
    }

    # VNet Integration Subnet (for App Service if needed)
    "${local.portals_dev.subnets[2].name}" = {
      name             = local.portals_dev.subnets[2].name
      address_prefixes = [local.portals_dev.subnets[2].address_prefix]
      service_endpoints_with_location = [
        for endpoint in local.portals_dev.subnets[2].service_endpoints : {
          service   = endpoint
          locations = ["*"]
        }
      ]
      delegation = [{
        name = "delegation"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
        }
      }]
    }

    # Data Services Subnet
    "${local.portals_dev.subnets[3].name}" = {
      name = local.portals_dev.subnets[3].name
      address_prefixes = [local.portals_dev.subnets[3].address_prefix]
      service_endpoints_with_location = [
        for endpoint in local.portals_dev.subnets[3].service_endpoints : {
          service   = endpoint
          locations = ["*"]
        }
      ]
    }
  }

  tags = merge(
    var.tags,
    {
      Purpose     = "Portals Spoke VNet"
      Environment = "Development"
      IPAM        = "Managed via 02-landing-zones/ipam.yaml"
    }
  )

  depends_on = [azurerm_resource_group.network]
}

# =============================================================================
# Network Configuration - Portal Admin Prod (REFACTORED EXAMPLE)
# This file remains workload-specific and uses outputs from the landing_zone module
# =============================================================================

# Load IPAM configuration
locals {
  ipam_config = yamldecode(file("${path.module}/../../ipam.yaml"))
  ipam        = local.ipam_config.ip_allocation

  # Get the portals-prod IPAM section (shared by both admin and customer prod)
  portals_prod = local.ipam["portals-prod"]
}

# =============================================================================
# Network Resource Group
# =============================================================================

resource "azurerm_resource_group" "network" {
  name     = "${module.landing_zone.naming.resource_group.name}-net"
  location = var.location
  tags     = module.landing_zone.common_tags
}

# =============================================================================
# Network Security Groups
# =============================================================================

module "nsg_app_subnet" {
  source = "../../../shared-modules/resource-modules/network-security-group"

  name                = "acme-nsg-${replace(local.portals_prod.subnets.app.name, "acme-", "")}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = module.landing_zone.common_tags
}

# ... Additional NSGs for other subnets ...

# =============================================================================
# Route Tables
# =============================================================================

module "rt_app_subnet" {
  source = "../../../shared-modules/resource-modules/route-table"

  name                = "acme-rt-${replace(local.portals_prod.subnets.app.name, "acme-", "")}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = module.landing_zone.common_tags

  routes = [
    {
      name                   = "default-to-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = local.ipam.connectivity.subnets.nva.routes.default_next_hop
    }
  ]
}

# ... Additional route tables ...

# =============================================================================
# Virtual Network
# =============================================================================

module "portals_vnet" {
  source = "../../../shared-modules/resource-modules/virtual-network"

  name                = local.portals_prod.vnet.name
  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  address_space       = [local.portals_prod.vnet.address_space]

  subnets = {
    app = {
      name             = local.portals_prod.subnets.app.name
      address_prefixes = [local.portals_prod.subnets.app.address_prefix]
      network_security_group = {
        id = module.nsg_app_subnet.resource_id
      }
      route_table = {
        id = module.rt_app_subnet.resource_id
      }
      service_endpoints = local.portals_prod.subnets.app.service_endpoints
    }
    # ... Additional subnets ...
  }

  tags = module.landing_zone.common_tags

  depends_on = [
    azurerm_resource_group.network,
    module.nsg_app_subnet,
    module.rt_app_subnet
  ]
}

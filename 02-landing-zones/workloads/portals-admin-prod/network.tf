# =============================================================================
# Spoke VNet - Portals Admin Prod Landing Zone
# Network infrastructure for admin portal workloads
# Based on IPAM manifest: 02-landing-zones/ipam.yaml
# =============================================================================

# Load IPAM configuration
locals {
  ipam               = yamldecode(file("${path.module}/../../ipam.yaml"))
  portals_admin_prod = local.ipam["portals-prod"]
}

# Resource Group for Network
resource "azurerm_resource_group" "network" {
  name     = "acme-rg-portals-admin-network-prod-${local.portals_admin_prod.location_short}"
  location = local.portals_admin_prod.location
  tags = merge(
    var.tags,
    {
      Purpose     = "Network Infrastructure"
      Application = "Admin Portal"
      CreatedBy   = "Terraform"
      ManagedBy   = "Terraform"
      Environment = "Development"
    }
  )
}

# Network Security Groups for Subnets
module "nsg_app_subnet" {
  source = "../../../shared-modules/resource-modules/network-security-group"

  name                = "acme-nsg-${replace(local.portals_admin_prod.subnets[0].name, "acme-", "")}"
  location            = local.portals_admin_prod.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Application Subnet NSG"
      Application = "Admin Portal"
      Environment = "Development"
    }
  )
}

module "nsg_private_endpoints_subnet" {
  source = "../../../shared-modules/resource-modules/network-security-group"

  name                = "acme-nsg-${replace(local.portals_admin_prod.subnets[1].name, "acme-", "")}"
  location            = local.portals_admin_prod.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Private Endpoints Subnet NSG"
      Application = "Admin Portal"
      Environment = "Development"
    }
  )
}

module "nsg_vnet_integration_subnet" {
  source = "../../../shared-modules/resource-modules/network-security-group"

  name                = "acme-nsg-${replace(local.portals_admin_prod.subnets[2].name, "acme-", "")}"
  location            = local.portals_admin_prod.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "VNet Integration Subnet NSG"
      Application = "Admin Portal"
      Environment = "Development"
    }
  )
}

module "nsg_data_services_subnet" {
  source = "../../../shared-modules/resource-modules/network-security-group"

  name                = "acme-nsg-${replace(local.portals_admin_prod.subnets[3].name, "acme-", "")}"
  location            = local.portals_admin_prod.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Data Services Subnet NSG"
      Application = "Admin Portal"
      Environment = "Development"
    }
  )
}

# Route Tables for Subnets
module "rt_app_subnet" {
  source = "../../../shared-modules/resource-modules/route-table"

  name                = "acme-rt-${replace(local.portals_admin_prod.subnets[0].name, "acme-", "")}"
  location            = local.portals_admin_prod.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Application Subnet Route Table"
      Application = "Admin Portal"
      Environment = "Development"
    }
  )
}

module "rt_private_endpoints_subnet" {
  source = "../../../shared-modules/resource-modules/route-table"

  name                = "acme-rt-${replace(local.portals_admin_prod.subnets[1].name, "acme-", "")}"
  location            = local.portals_admin_prod.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Private Endpoints Subnet Route Table"
      Application = "Admin Portal"
      Environment = "Development"
    }
  )
}

module "rt_vnet_integration_subnet" {
  source = "../../../shared-modules/resource-modules/route-table"

  name                = "acme-rt-${replace(local.portals_admin_prod.subnets[2].name, "acme-", "")}"
  location            = local.portals_admin_prod.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "VNet Integration Subnet Route Table"
      Application = "Admin Portal"
      Environment = "Development"
    }
  )
}

module "rt_data_services_subnet" {
  source = "../../../shared-modules/resource-modules/route-table"

  name                = "acme-rt-${replace(local.portals_admin_prod.subnets[3].name, "acme-", "")}"
  location            = local.portals_admin_prod.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Data Services Subnet Route Table"
      Application = "Admin Portal"
      Environment = "Development"
    }
  )
}

# Portals Admin prod Virtual Network
module "portals_vnet" {
  source = "../../../shared-modules/resource-modules/virtual-network"

  name                = local.portals_admin_prod.vnet.name
  resource_group_name = azurerm_resource_group.network.name
  location            = local.portals_admin_prod.location

  address_space = [local.portals_admin_prod.vnet.address_space]
  dns_servers = length(local.portals_admin_prod.vnet.dns_servers) > 0 ? {
    dns_servers = local.portals_admin_prod.vnet.dns_servers
  } : null

  # Subnets based on IPAM manifest
  subnets = {
    # Application Subnet
    "${local.portals_admin_prod.subnets[0].name}" = {
      name             = local.portals_admin_prod.subnets[0].name
      address_prefixes = [local.portals_admin_prod.subnets[0].address_prefix]
      network_security_group = {
        id = module.nsg_app_subnet.id
      }
      route_table = {
        id = module.rt_app_subnet.id
      }
      service_endpoints_with_location = [
        for endpoint in local.portals_admin_prod.subnets[0].service_endpoints : {
          service   = endpoint
          locations = ["*"]
        }
      ]
    }

    # Private Endpoints Subnet
    "${local.portals_admin_prod.subnets[1].name}" = {
      name             = local.portals_admin_prod.subnets[1].name
      address_prefixes = [local.portals_admin_prod.subnets[1].address_prefix]
      network_security_group = {
        id = module.nsg_private_endpoints_subnet.id
      }
      route_table = {
        id = module.rt_private_endpoints_subnet.id
      }
      private_endpoint_network_policies_enabled = false
    }

    # VNet Integration Subnet (for App Service if needed)
    "${local.portals_admin_prod.subnets[2].name}" = {
      name             = local.portals_admin_prod.subnets[2].name
      address_prefixes = [local.portals_admin_prod.subnets[2].address_prefix]
      network_security_group = {
        id = module.nsg_vnet_integration_subnet.id
      }
      route_table = {
        id = module.rt_vnet_integration_subnet.id
      }
      service_endpoints_with_location = [
        for endpoint in local.portals_admin_prod.subnets[2].service_endpoints : {
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
    "${local.portals_admin_prod.subnets[3].name}" = {
      name             = local.portals_admin_prod.subnets[3].name
      address_prefixes = [local.portals_admin_prod.subnets[3].address_prefix]
      network_security_group = {
        id = module.nsg_data_services_subnet.id
      }
      route_table = {
        id = module.rt_data_services_subnet.id
      }
      service_endpoints_with_location = [
        for endpoint in local.portals_admin_prod.subnets[3].service_endpoints : {
          service   = endpoint
          locations = ["*"]
        }
      ]
    }
  }

  tags = merge(
    var.tags,
    {
      Purpose     = "Admin Portal Spoke VNet"
      Environment = "Development"
      Application = "Admin Portal"
      IPAM        = "Managed via 02-landing-zones/ipam.yaml"
    }
  )

  depends_on = [azurerm_resource_group.network]
}


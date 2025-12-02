# =============================================================================
# Spoke VNet - Portals Customer Dev Landing Zone
# Network infrastructure for customer portal workloads
# Based on IPAM manifest: 02-landing-zones/ipam.yaml
# =============================================================================

# Load IPAM configuration
locals {
  ipam                 = yamldecode(file("${path.module}/../../ipam.yaml"))
  portals_customer_dev = local.ipam["portals-customer-dev"]
}

# Resource Group for Network
resource "azurerm_resource_group" "network" {
  name     = "acme-rg-portals-customer-network-dev-${local.portals_customer_dev.location_short}"
  location = local.portals_customer_dev.location
  tags = merge(
    var.tags,
    {
      Purpose     = "Network Infrastructure"
      Application = "Customer Portal"
      CreatedBy   = "Terraform"
      ManagedBy   = "Terraform"
      Environment = "Development"
    }
  )
}

# Network Security Groups for Subnets
module "nsg_app_subnet" {
  source = "../../../shared-modules/network-security-group"

  name                = "nsg-${local.portals_customer_dev.subnets[0].name}"
  location            = local.portals_customer_dev.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Application Subnet NSG"
      Application = "Customer Portal"
      Environment = "Development"
    }
  )
}

module "nsg_private_endpoints_subnet" {
  source = "../../../shared-modules/network-security-group"

  name                = "nsg-${local.portals_customer_dev.subnets[1].name}"
  location            = local.portals_customer_dev.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Private Endpoints Subnet NSG"
      Application = "Customer Portal"
      Environment = "Development"
    }
  )
}

module "nsg_vnet_integration_subnet" {
  source = "../../../shared-modules/network-security-group"

  name                = "nsg-snet-portals-customer-int-dev-eus2"
  location            = local.portals_customer_dev.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "VNet Integration Subnet NSG"
      Application = "Customer Portal"
      Environment = "Development"
    }
  )
}

module "nsg_data_services_subnet" {
  source = "../../../shared-modules/network-security-group"

  name                = "nsg-${local.portals_customer_dev.subnets[3].name}"
  location            = local.portals_customer_dev.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Data Services Subnet NSG"
      Application = "Customer Portal"
      Environment = "Development"
    }
  )
}

# Route Tables for Subnets
module "rt_app_subnet" {
  source = "../../../shared-modules/route-table"

  name                = "rt-${local.portals_customer_dev.subnets[0].name}"
  location            = local.portals_customer_dev.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Application Subnet Route Table"
      Application = "Customer Portal"
      Environment = "Development"
    }
  )
}

module "rt_private_endpoints_subnet" {
  source = "../../../shared-modules/route-table"

  name                = "rt-${local.portals_customer_dev.subnets[1].name}"
  location            = local.portals_customer_dev.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Private Endpoints Subnet Route Table"
      Application = "Customer Portal"
      Environment = "Development"
    }
  )
}

module "rt_vnet_integration_subnet" {
  source = "../../../shared-modules/route-table"

  name                = "rt-${local.portals_customer_dev.subnets[2].name}"
  location            = local.portals_customer_dev.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "VNet Integration Subnet Route Table"
      Application = "Customer Portal"
      Environment = "Development"
    }
  )
}

module "rt_data_services_subnet" {
  source = "../../../shared-modules/route-table"

  name                = "rt-${local.portals_customer_dev.subnets[3].name}"
  location            = local.portals_customer_dev.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(
    var.tags,
    {
      Purpose     = "Data Services Subnet Route Table"
      Application = "Customer Portal"
      Environment = "Development"
    }
  )
}

# Portals Customer Dev Virtual Network
module "portals_vnet" {
  source = "../../../shared-modules/virtual-network"

  name                = local.portals_customer_dev.vnet.name
  resource_group_name = azurerm_resource_group.network.name
  location            = local.portals_customer_dev.location

  address_space = [local.portals_customer_dev.vnet.address_space]
  dns_servers = length(local.portals_customer_dev.vnet.dns_servers) > 0 ? {
    dns_servers = local.portals_customer_dev.vnet.dns_servers
  } : null

  # Subnets based on IPAM manifest
  subnets = {
    # Application Subnet
    "${local.portals_customer_dev.subnets[0].name}" = {
      name                               = local.portals_customer_dev.subnets[0].name
      address_prefixes                   = [local.portals_customer_dev.subnets[0].address_prefix]
      network_security_group_resource_id = module.nsg_app_subnet.id
      route_table_resource_id            = module.rt_app_subnet.id
      service_endpoints_with_location = [
        for endpoint in local.portals_customer_dev.subnets[0].service_endpoints : {
          service   = endpoint
          locations = ["*"]
        }
      ]
    }

    # Private Endpoints Subnet
    "${local.portals_customer_dev.subnets[1].name}" = {
      name                                      = local.portals_customer_dev.subnets[1].name
      address_prefixes                          = [local.portals_customer_dev.subnets[1].address_prefix]
      network_security_group_resource_id        = module.nsg_private_endpoints_subnet.id
      route_table_resource_id                   = module.rt_private_endpoints_subnet.id
      private_endpoint_network_policies_enabled = false
    }

    # VNet Integration Subnet (for App Service if needed)
    "${local.portals_customer_dev.subnets[2].name}" = {
      name                               = local.portals_customer_dev.subnets[2].name
      address_prefixes                   = [local.portals_customer_dev.subnets[2].address_prefix]
      network_security_group_resource_id = module.nsg_vnet_integration_subnet.id
      route_table_resource_id            = module.rt_vnet_integration_subnet.id
      service_endpoints_with_location = [
        for endpoint in local.portals_customer_dev.subnets[2].service_endpoints : {
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
    "${local.portals_customer_dev.subnets[3].name}" = {
      name                               = local.portals_customer_dev.subnets[3].name
      address_prefixes                   = [local.portals_customer_dev.subnets[3].address_prefix]
      network_security_group_resource_id = module.nsg_data_services_subnet.id
      route_table_resource_id            = module.rt_data_services_subnet.id
      service_endpoints_with_location = [
        for endpoint in local.portals_customer_dev.subnets[3].service_endpoints : {
          service   = endpoint
          locations = ["*"]
        }
      ]
    }
  }

  tags = merge(
    var.tags,
    {
      Purpose     = "Customer Portal Spoke VNet"
      Environment = "Development"
      Application = "Customer Portal"
      IPAM        = "Managed via 02-landing-zones/ipam.yaml"
    }
  )

  depends_on = [azurerm_resource_group.network]
}

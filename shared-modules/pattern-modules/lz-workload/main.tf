# =============================================================================
# Landing Zone Workload Module
# Encapsulates common pattern for all workload landing zones:
# - Management group subscription association
# - Monitoring resource group and Log Analytics workspace
# - Networking (VNet, NSGs, Route Tables, Subnets)
# - Naming convention setup
# =============================================================================

# Data source to get the target management group
data "azurerm_management_group" "target" {
  name = var.management_group_name
}

# =============================================================================
# IPAM Configuration Loading
# =============================================================================

locals {
  ipam        = yamldecode(file("${path.root}/${var.ipam_config_path}"))
  ipam_config = local.ipam[var.ipam_key]
}

# =============================================================================
# Naming Module for Consistent Azure Resource Naming
# =============================================================================

module "naming" {
  source   = "../../utility-modules/naming"
  location = var.location
  suffix   = var.naming_suffix
}

# Prepare common tags for all resources
locals {
  common_tags = merge(
    var.tags,
    var.common_tags,
    {
      Purpose     = var.purpose
      LandingZone = var.landing_zone_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      DeployedBy  = "ALZ-Foundation"
    }
  )

  network_tags = merge(
    local.common_tags,
    {
      Purpose = "Network Infrastructure"
    }
  )
}

# Place the subscription into the target management group
resource "azurerm_management_group_subscription_association" "this" {
  management_group_id = data.azurerm_management_group.target.id
  subscription_id     = "/subscriptions/${var.subscription_id}"
}

# =============================================================================
# Monitoring Resources
# =============================================================================

# Resource Group for monitoring resources
module "monitoring_resource_group" {
  count  = var.create_log_analytics ? 1 : 0
  source = "../../resource-modules/resource-group"

  name     = "${module.naming.resource_group.name}-mon"
  location = var.location
  tags     = local.common_tags
}

# Log Analytics Workspace for monitoring and diagnostics
module "log_analytics_workspace" {
  count  = var.create_log_analytics ? 1 : 0
  source = "../../resource-modules/log-analytics-workspace"

  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = module.monitoring_resource_group[0].name
  location            = var.location
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags

  depends_on = [module.monitoring_resource_group]
}

# =============================================================================
# Network Resources
# =============================================================================

# Resource Group for Network
resource "azurerm_resource_group" "network" {
  name     = "acme-rg-${var.landing_zone_name}-${var.network_resource_group_suffix}-${var.environment}-${local.ipam_config.location_short}"
  location = local.ipam_config.location
  tags     = local.network_tags
}

# Network Security Groups for each subnet
module "nsg" {
  source   = "../../resource-modules/network-security-group"
  for_each = { for idx, subnet in local.ipam_config.subnets : idx => subnet }

  name                = "acme-nsg-${replace(each.value.name, "acme-", "")}"
  location            = local.ipam_config.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(local.network_tags, { Purpose = "${each.value.purpose} NSG" })
}

# Route Tables for each subnet
module "route_table" {
  source   = "../../resource-modules/route-table"
  for_each = { for idx, subnet in local.ipam_config.subnets : idx => subnet }

  name                = "acme-rt-${replace(each.value.name, "acme-", "")}"
  location            = local.ipam_config.location
  resource_group_name = azurerm_resource_group.network.name

  tags = merge(local.network_tags, { Purpose = "${each.value.purpose} Route Table" })
}

# Virtual Network with subnets
module "vnet" {
  source = "../../resource-modules/virtual-network"

  name                = local.ipam_config.vnet.name
  resource_group_name = azurerm_resource_group.network.name
  location            = local.ipam_config.location

  address_space = [local.ipam_config.vnet.address_space]
  dns_servers = length(local.ipam_config.vnet.dns_servers) > 0 ? {
    dns_servers = local.ipam_config.vnet.dns_servers
  } : null

  # Dynamically create subnets based on IPAM configuration
  subnets = {
    for idx, subnet in local.ipam_config.subnets : subnet.name => merge(
      {
        name             = subnet.name
        address_prefixes = [subnet.address_prefix]
        network_security_group = {
          id = module.nsg[idx].id
        }
        route_table = {
          id = module.route_table[idx].id
        }
      },
      # Add service endpoints if defined
      length(subnet.service_endpoints) > 0 ? {
        service_endpoints_with_location = [
          for endpoint in subnet.service_endpoints : {
            service   = endpoint
            locations = ["*"]
          }
        ]
      } : {},
      # Add delegations if defined
      length(subnet.delegations) > 0 ? {
        delegation = subnet.delegations
      } : {},
      # Add private endpoint policies if defined
      lookup(subnet, "private_endpoint_network_policies", "") == "Disabled" ? {
        private_endpoint_network_policies_enabled = false
      } : {}
    )
  }

  tags = merge(local.network_tags, {
    Purpose = "${var.landing_zone_name} Spoke VNet"
    IPAM    = "Managed via ${var.ipam_config_path}"
  })

  depends_on = [azurerm_resource_group.network]
}

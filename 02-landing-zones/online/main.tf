# =============================================================================
# Landing Zone Subscription Placement - Online
# This places a subscription into the online landing zone management group
# Deploy this AFTER alz-foundation and BEFORE workloads
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

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Data source to get the management group created by ALZ foundation
data "azurerm_management_group" "landing_zone" {
  name = var.landing_zone_management_group_name
}

# Place the subscription into the landing zone management group
resource "azurerm_management_group_subscription_association" "workload" {
  management_group_id = data.azurerm_management_group.landing_zone.id
  subscription_id     = "/subscriptions/${var.workload_subscription_id}"
}

# =============================================================================
# Networking Resources using AVM Wrapper Modules
# =============================================================================

# Resource Group for networking resources
module "networking_resource_group" {
  count  = var.create_virtual_network ? 1 : 0
  source = "../../shared-modules/resource-group"

  name     = "rg-${var.landing_zone_name}-networking-${var.location}"
  location = var.location

  tags = merge(
    var.tags,
    {
      Purpose     = "Networking"
      LandingZone = var.landing_zone_name
      ManagedBy   = "Terraform"
      DeployedBy  = "AVM"
    }
  )
}

# Virtual Network for landing zone workloads
module "virtual_network" {
  count  = var.create_virtual_network ? 1 : 0
  source = "../../shared-modules/virtual-network"

  name                = "vnet-${var.landing_zone_name}-${var.location}"
  resource_group_name = module.networking_resource_group[0].name
  location            = var.location
  address_space       = var.vnet_address_space

  subnets = var.vnet_subnets

  dns_servers = var.vnet_dns_servers

  tags = merge(
    var.tags,
    {
      Purpose     = "Networking"
      LandingZone = var.landing_zone_name
      ManagedBy   = "Terraform"
      DeployedBy  = "AVM"
    }
  )
}

# =============================================================================
# Monitoring Resources using AVM Wrapper Modules
# =============================================================================

# Resource Group for monitoring resources
module "monitoring_resource_group" {
  count  = var.create_log_analytics ? 1 : 0
  source = "../../shared-modules/resource-group"

  name     = "rg-${var.landing_zone_name}-monitoring-${var.location}"
  location = var.location

  tags = merge(
    var.tags,
    {
      Purpose     = "Monitoring"
      LandingZone = var.landing_zone_name
      ManagedBy   = "Terraform"
      DeployedBy  = "AVM"
    }
  )
}

# Log Analytics Workspace for landing zone diagnostics
module "log_analytics_workspace" {
  count  = var.create_log_analytics ? 1 : 0
  source = "../../shared-modules/log-analytics-workspace"

  name                = "log-${var.landing_zone_name}-${var.location}"
  resource_group_name = module.monitoring_resource_group[0].name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Purpose     = "Monitoring"
      LandingZone = var.landing_zone_name
      ManagedBy   = "Terraform"
      DeployedBy  = "AVM"
    }
  )
}

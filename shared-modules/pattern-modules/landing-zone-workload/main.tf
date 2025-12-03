# =============================================================================
# Landing Zone Workload Module
# Encapsulates common pattern for all workload landing zones:
# - Management group subscription association
# - Monitoring resource group and Log Analytics workspace
# - Naming convention setup
# =============================================================================

# Data source to get the target management group
data "azurerm_management_group" "target" {
  name = var.management_group_name
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

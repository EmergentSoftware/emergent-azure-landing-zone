# =============================================================================
# Landing Zone Workload Module Outputs
# =============================================================================

output "management_group_id" {
  description = "The ID of the target management group"
  value       = data.azurerm_management_group.target.id
}

output "subscription_association_id" {
  description = "The ID of the subscription association"
  value       = azurerm_management_group_subscription_association.this.id
}

output "subscription_id" {
  description = "The subscription ID"
  value       = var.subscription_id
}

# Naming outputs
output "naming" {
  description = "The naming module for generating consistent resource names"
  value       = module.naming
}

output "common_tags" {
  description = "The common tags applied to all resources"
  value       = local.common_tags
}

# Monitoring outputs
output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace (if created)"
  value       = var.create_log_analytics ? module.log_analytics_workspace[0].resource_id : null
}

output "log_analytics_workspace_resource_id" {
  description = "The resource ID of the Log Analytics workspace for use in workloads (if created)"
  value       = var.create_log_analytics ? module.log_analytics_workspace[0].resource_id : ""
}

output "monitoring_resource_group_name" {
  description = "The name of the monitoring resource group (if created)"
  value       = var.create_log_analytics ? module.monitoring_resource_group[0].name : null
}

output "monitoring_resource_group_id" {
  description = "The ID of the monitoring resource group (if created)"
  value       = var.create_log_analytics ? module.monitoring_resource_group[0].resource_id : null
}

# Network Outputs
output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.vnet.resource_id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = module.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = module.vnet.address_space
}

output "network_resource_group_name" {
  description = "The name of the network resource group"
  value       = azurerm_resource_group.network.name
}

output "network_resource_group_id" {
  description = "The ID of the network resource group"
  value       = azurerm_resource_group.network.id
}

output "subnets" {
  description = "Map of subnet names to subnet details"
  value       = module.vnet.subnets
}

output "nsg_ids" {
  description = "Map of NSG names to NSG IDs"
  value       = { for idx, nsg in module.nsg : local.ipam_config.subnets[idx].name => nsg.id }
}

output "route_table_ids" {
  description = "Map of route table names to route table IDs"
  value       = { for idx, rt in module.route_table : local.ipam_config.subnets[idx].name => rt.id }
}

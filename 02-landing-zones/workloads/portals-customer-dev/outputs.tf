output "management_group_id" {
  description = "The ID of the portals management group"
  value       = data.azurerm_management_group.portals.id
}

output "subscription_association_id" {
  description = "The ID of the subscription association"
  value       = azurerm_management_group_subscription_association.portal_dev.id
}

output "subscription_id" {
  description = "The portal dev subscription ID"
  value       = var.subscription_id
}

# Networking Outputs
output "portals_vnet_id" {
  description = "The ID of the portals spoke virtual network"
  value       = module.portals_vnet.resource_id
}

output "portals_vnet_name" {
  description = "The name of the portals spoke virtual network"
  value       = module.portals_vnet.name
}

output "portals_vnet_address_space" {
  description = "The address space of the portals spoke virtual network"
  value       = module.portals_vnet.address_space
}

output "portals_network_resource_group_name" {
  description = "The name of the portals network resource group"
  value       = azurerm_resource_group.network.name
}

output "portals_network_resource_group_id" {
  description = "The ID of the portals network resource group"
  value       = azurerm_resource_group.network.id
}

# Monitoring Outputs
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

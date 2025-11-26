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
output "virtual_network_id" {
  description = "The resource ID of the virtual network (if created)"
  value       = var.create_virtual_network ? module.virtual_network[0].resource_id : null
}

output "virtual_network_name" {
  description = "The name of the virtual network (if created)"
  value       = var.create_virtual_network ? module.virtual_network[0].name : null
}

output "subnets" {
  description = "Map of subnet names to their resource IDs (if created)"
  value       = var.create_virtual_network ? module.virtual_network[0].subnets : {}
}

output "networking_resource_group_name" {
  description = "The name of the networking resource group (if created)"
  value       = var.create_virtual_network ? module.networking_resource_group[0].name : null
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

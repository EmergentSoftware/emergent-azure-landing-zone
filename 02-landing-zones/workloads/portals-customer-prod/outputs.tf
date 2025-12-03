# =============================================================================
# Landing Zone Pattern Module Outputs
# =============================================================================

output "management_group_id" {
  description = "The ID of the portals management group"
  value       = module.landing_zone.management_group_id
}

output "subscription_association_id" {
  description = "The ID of the subscription association"
  value       = module.landing_zone.subscription_association_id
}

output "subscription_id" {
  description = "The portal customer prod subscription ID"
  value       = module.landing_zone.subscription_id
}

# Networking Outputs
output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.landing_zone.vnet_id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = module.landing_zone.vnet_name
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = module.landing_zone.vnet_address_space
}

output "network_resource_group_name" {
  description = "The name of the network resource group"
  value       = module.landing_zone.network_resource_group_name
}

output "network_resource_group_id" {
  description = "The ID of the network resource group"
  value       = module.landing_zone.network_resource_group_id
}

output "subnets" {
  description = "Map of subnet names to subnet details"
  value       = module.landing_zone.subnets
}

# Monitoring Outputs
output "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace (if created)"
  value       = module.landing_zone.log_analytics_workspace_id
}

output "log_analytics_workspace_resource_id" {
  description = "The resource ID of the Log Analytics workspace for use in workloads (if created)"
  value       = module.landing_zone.log_analytics_workspace_resource_id
}

output "monitoring_resource_group_name" {
  description = "The name of the monitoring resource group (if created)"
  value       = module.landing_zone.monitoring_resource_group_name
}

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

# =============================================================================
# Azure Monitor Action Group Outputs
# =============================================================================

output "id" {
  description = "The ID of the action group"
  value       = azurerm_monitor_action_group.this.id
}

output "name" {
  description = "The name of the action group"
  value       = azurerm_monitor_action_group.this.name
}

output "resource_group_name" {
  description = "The resource group name of the action group"
  value       = azurerm_monitor_action_group.this.resource_group_name
}

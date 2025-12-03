# =============================================================================
# Route Table Module - Outputs
# =============================================================================

output "id" {
  description = "ID of the Route Table"
  value       = azurerm_route_table.this.id
}

output "name" {
  description = "Name of the Route Table"
  value       = azurerm_route_table.this.name
}

output "location" {
  description = "Location of the Route Table"
  value       = azurerm_route_table.this.location
}

output "resource_group_name" {
  description = "Resource group name of the Route Table"
  value       = azurerm_route_table.this.resource_group_name
}

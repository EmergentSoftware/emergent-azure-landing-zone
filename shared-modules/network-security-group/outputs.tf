# =============================================================================
# Network Security Group Module - Outputs
# =============================================================================

output "id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "Name of the Network Security Group"
  value       = azurerm_network_security_group.this.name
}

output "location" {
  description = "Location of the Network Security Group"
  value       = azurerm_network_security_group.this.location
}

output "resource_group_name" {
  description = "Resource group name of the Network Security Group"
  value       = azurerm_network_security_group.this.resource_group_name
}

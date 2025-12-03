output "id" {
  description = "The ID of the private endpoint"
  value       = azurerm_private_endpoint.this.id
}

output "name" {
  description = "The name of the private endpoint"
  value       = azurerm_private_endpoint.this.name
}

output "private_ip_address" {
  description = "The private IP address of the private endpoint"
  value       = try(azurerm_private_endpoint.this.private_service_connection[0].private_ip_address, null)
}

output "network_interface_ids" {
  description = "The IDs of the network interfaces created for the private endpoint"
  value       = azurerm_private_endpoint.this.network_interface[*].id
}

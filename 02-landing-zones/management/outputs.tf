output "management_group_id" {
  description = "The ID of the management management group"
  value       = data.azurerm_management_group.management.id
}

output "subscription_association_id" {
  description = "The ID of the subscription association"
  value       = azurerm_management_group_subscription_association.management.id
}

output "subscription_id" {
  description = "The management subscription ID"
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
  value       = var.create_virtual_network ? module.virtual_network[0].subnets : null
}

output "networking_resource_group_name" {
  description = "The name of the networking resource group (if created)"
  value       = var.create_virtual_network ? module.networking_resource_group[0].name : null
}

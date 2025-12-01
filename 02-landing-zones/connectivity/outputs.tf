output "management_group_id" {
  description = "The ID of the connectivity management group"
  value       = data.azurerm_management_group.connectivity.id
}

output "subscription_association_id" {
  description = "The ID of the subscription association"
  value       = azurerm_management_group_subscription_association.connectivity.id
}

output "subscription_id" {
  description = "The connectivity subscription ID"
  value       = var.subscription_id
}

# Network outputs
output "hub_vnet_id" {
  description = "The ID of the hub virtual network"
  value       = module.hub_vnet.resource_id
}

output "hub_vnet_name" {
  description = "The name of the hub virtual network"
  value       = module.hub_vnet.name
}

output "hub_vnet_address_space" {
  description = "The address space of the hub virtual network"
  value       = module.hub_vnet.address_space
}

output "network_resource_group_name" {
  description = "The name of the network resource group"
  value       = module.network_resource_group.name
}

output "network_resource_group_id" {
  description = "The ID of the network resource group"
  value       = module.network_resource_group.resource_id
}

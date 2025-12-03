output "name" {
  description = "The name of the virtual network"
  value       = module.virtual_network.name
}

output "resource_id" {
  description = "The resource ID of the virtual network"
  value       = module.virtual_network.resource_id
}

output "id" {
  description = "The resource ID of the virtual network"
  value       = module.virtual_network.resource_id
}

output "subnets" {
  description = "Map of subnet names to their IDs"
  value       = module.virtual_network.subnets
}

output "address_space" {
  description = "The address space of the virtual network"
  value       = module.virtual_network.address_spaces
}

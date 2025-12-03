output "name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "resource_id" {
  description = "The resource ID of the resource group"
  value       = module.resource_group.resource_id
}

output "location" {
  description = "The location of the resource group"
  value       = module.resource_group.resource.location
}

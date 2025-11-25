output "name" {
  description = "The name of the App Service Plan"
  value       = module.app_service_plan.name
}

output "resource_id" {
  description = "The resource ID of the App Service Plan"
  value       = module.app_service_plan.resource_id
}

output "id" {
  description = "The ID of the App Service Plan"
  value       = module.app_service_plan.resource_id
}

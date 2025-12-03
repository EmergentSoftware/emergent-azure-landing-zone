# =============================================================================
# Naming Module Outputs
# Pass through all naming outputs from the underlying module
# =============================================================================

output "resource_group" {
  description = "Resource group naming convention"
  value       = module.naming.resource_group
}

output "storage_account" {
  description = "Storage account naming convention"
  value       = module.naming.storage_account
}

output "virtual_network" {
  description = "Virtual network naming convention"
  value       = module.naming.virtual_network
}

output "log_analytics_workspace" {
  description = "Log Analytics workspace naming convention"
  value       = module.naming.log_analytics_workspace
}

output "app_service_plan" {
  description = "App Service Plan naming convention"
  value       = module.naming.app_service_plan
}

output "app_service" {
  description = "App Service naming convention"
  value       = module.naming.app_service
}

output "application_insights" {
  description = "Application Insights naming convention"
  value       = module.naming.application_insights
}

# Pass through all other outputs dynamically
output "naming" {
  description = "All naming conventions from the Azure naming module"
  value       = module.naming
}

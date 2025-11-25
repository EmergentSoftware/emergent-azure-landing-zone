# =============================================================================
# Outputs for Web App Workload
# =============================================================================

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.resource_id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = module.app_service_plan.resource_id
}

output "app_service_plan_name" {
  description = "The name of the App Service Plan"
  value       = module.app_service_plan.name
}

output "web_app_id" {
  description = "The ID of the web app"
  value       = module.web_app.resource_id
}

output "web_app_name" {
  description = "The name of the web app"
  value       = module.web_app.name
}

output "web_app_default_hostname" {
  description = "The default hostname of the web app"
  value       = module.web_app.default_hostname
}

output "web_app_url" {
  description = "The HTTPS URL of the web app"
  value       = "https://${module.web_app.default_hostname}"
}

output "web_app_identity" {
  description = "The managed identity of the web app"
  value       = module.web_app.system_assigned_mi_principal_id
  sensitive   = true
}

output "application_insights_id" {
  description = "The ID of Application Insights (if enabled)"
  value       = var.enable_application_insights ? module.application_insights[0].resource_id : null
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights (if enabled)"
  value       = var.enable_application_insights ? module.application_insights[0].instrumentation_key : null
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights (if enabled)"
  value       = var.enable_application_insights ? module.application_insights[0].connection_string : null
  sensitive   = true
}

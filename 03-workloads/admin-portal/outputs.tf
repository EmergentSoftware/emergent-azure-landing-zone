# =============================================================================
# Outputs for Static Web App Workload
# =============================================================================

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.resource_id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "static_web_app_id" {
  description = "The ID of the Static Web App"
  value       = module.static_web_app.id
}

output "static_web_app_name" {
  description = "The name of the Static Web App"
  value       = module.static_web_app.name
}

output "static_web_app_default_hostname" {
  description = "The default hostname of the Static Web App"
  value       = module.static_web_app.default_hostname
}

output "static_web_app_url" {
  description = "The HTTPS URL of the Static Web App"
  value       = "https://${module.static_web_app.default_hostname}"
}

output "static_web_app_api_key" {
  description = "The API key for the Static Web App"
  value       = module.static_web_app.api_key
  sensitive   = true
}

output "static_web_app_identity" {
  description = "The managed identity of the Static Web App"
  value       = var.enable_managed_identity ? module.static_web_app.identity : null
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

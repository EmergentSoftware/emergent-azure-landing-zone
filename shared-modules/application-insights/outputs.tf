output "name" {
  description = "The name of the Application Insights component"
  value       = module.application_insights.name
}

output "resource_id" {
  description = "The resource ID of Application Insights"
  value       = module.application_insights.resource_id
}

output "instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = module.application_insights.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "The connection string for Application Insights"
  value       = module.application_insights.connection_string
  sensitive   = true
}

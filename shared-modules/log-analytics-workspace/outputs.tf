output "name" {
  description = "The name of the Log Analytics workspace"
  value       = module.log_analytics_workspace.name
}

output "resource_id" {
  description = "The resource ID of the Log Analytics workspace"
  value       = module.log_analytics_workspace.resource_id
}

output "workspace_id" {
  description = "The workspace ID (GUID) of the Log Analytics workspace"
  value       = module.log_analytics_workspace.workspace_id
}

output "id" {
  description = "The resource ID of the Log Analytics workspace"
  value       = module.log_analytics_workspace.resource_id
}

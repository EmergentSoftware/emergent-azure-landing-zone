output "name" {
  description = "The name of the web app"
  value       = module.web_app.name
}

output "resource_id" {
  description = "The resource ID of the web app"
  value       = module.web_app.resource_id
}

output "default_hostname" {
  description = "The default hostname of the web app"
  value       = module.web_app.default_hostname
}

output "system_assigned_mi_principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = module.web_app.system_assigned_mi_principal_id
}

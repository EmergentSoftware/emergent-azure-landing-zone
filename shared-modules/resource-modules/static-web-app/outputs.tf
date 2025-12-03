output "id" {
  description = "The ID of the Static Web App"
  value       = azurerm_static_web_app.this.id
}

output "default_hostname" {
  description = "The default hostname of the Static Web App"
  value       = azurerm_static_web_app.this.default_host_name
}

output "api_key" {
  description = "The API key for the Static Web App"
  value       = azurerm_static_web_app.this.api_key
  sensitive   = true
}

output "identity" {
  description = "The managed identity of the Static Web App"
  value       = var.enable_managed_identity ? azurerm_static_web_app.this.identity[0] : null
}

output "name" {
  description = "The name of the Static Web App"
  value       = azurerm_static_web_app.this.name
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint (if created)"
  value       = try(module.private_endpoint[0].id, null)
}

output "private_endpoint_ip" {
  description = "The private IP address of the private endpoint (if created)"
  value       = try(module.private_endpoint[0].private_ip_address, null)
}

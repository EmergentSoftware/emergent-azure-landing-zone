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

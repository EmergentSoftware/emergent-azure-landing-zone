# =============================================================================
# Outputs for Static Site Storage Workload
# =============================================================================

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.static_site.resource_group_id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.static_site.resource_group_name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.static_site.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.static_site.storage_account_name
}

output "primary_web_endpoint" {
  description = "The primary web endpoint for the static website"
  value       = module.static_site.primary_web_endpoint
}

output "primary_web_host" {
  description = "The primary web host for the static website"
  value       = module.static_site.primary_web_host
}

output "static_website_url" {
  description = "The HTTPS URL of the static website"
  value       = module.static_site.static_website_url
}

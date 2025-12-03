# =============================================================================
# Outputs for Static Site Storage Pattern
# =============================================================================

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.resource_id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.resource_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "primary_web_endpoint" {
  description = "The primary web endpoint for the static website"
  value       = module.storage_account.primary_web_endpoint
}

output "primary_web_host" {
  description = "The primary web host for the static website"
  value       = module.storage_account.primary_web_host
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint of the storage account"
  value       = module.storage_account.primary_blob_endpoint
}

output "static_website_url" {
  description = "The HTTPS URL of the static website"
  value       = "https://${module.storage_account.primary_web_host}"
}

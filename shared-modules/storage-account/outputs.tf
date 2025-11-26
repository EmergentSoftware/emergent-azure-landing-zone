output "resource_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.resource_id
}

output "name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = module.storage_account.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key"
  value       = module.storage_account.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key"
  value       = module.storage_account.secondary_access_key
  sensitive   = true
}

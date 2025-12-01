output "resource_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.resource_id
}

output "name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "resource" {
  description = "The full storage account resource output"
  value       = module.storage_account.resource
  sensitive   = true
}

output "fqdn" {
  description = "FQDNs for storage services"
  value       = module.storage_account.fqdn
}

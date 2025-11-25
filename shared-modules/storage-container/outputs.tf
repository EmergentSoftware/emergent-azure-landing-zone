output "id" {
  description = "The ID of the storage container"
  value       = azurerm_storage_container.this.id
}

output "name" {
  description = "The name of the storage container"
  value       = azurerm_storage_container.this.name
}

output "has_immutability_policy" {
  description = "Whether the container has an immutability policy"
  value       = azurerm_storage_container.this.has_immutability_policy
}

output "has_legal_hold" {
  description = "Whether the container has a legal hold"
  value       = azurerm_storage_container.this.has_legal_hold
}

output "management_group_id" {
  description = "The ID of the connectivity management group"
  value       = data.azurerm_management_group.connectivity.id
}

output "subscription_association_id" {
  description = "The ID of the subscription association"
  value       = azurerm_management_group_subscription_association.connectivity.id
}

output "subscription_id" {
  description = "The connectivity subscription ID"
  value       = var.subscription_id
}

output "management_group_id" {
  description = "The ID of the management management group"
  value       = data.azurerm_management_group.management.id
}

output "subscription_association_id" {
  description = "The ID of the subscription association"
  value       = azurerm_management_group_subscription_association.management.id
}

output "subscription_id" {
  description = "The management subscription ID"
  value       = var.subscription_id
}

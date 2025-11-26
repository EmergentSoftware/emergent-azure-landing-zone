output "management_group_id" {
  description = "The ID of the identity management group"
  value       = data.azurerm_management_group.identity.id
}

output "subscription_association_id" {
  description = "The ID of the subscription association"
  value       = azurerm_management_group_subscription_association.identity.id
}

output "subscription_id" {
  description = "The identity subscription ID"
  value       = var.subscription_id
}

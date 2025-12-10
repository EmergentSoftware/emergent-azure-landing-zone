# =============================================================================
# Azure Consumption Budget Outputs
# =============================================================================

output "id" {
  description = "The ID of the consumption budget"
  value       = azurerm_consumption_budget_subscription.this.id
}

output "name" {
  description = "The name of the consumption budget"
  value       = azurerm_consumption_budget_subscription.this.name
}

output "subscription_id" {
  description = "The subscription ID the budget is applied to"
  value       = azurerm_consumption_budget_subscription.this.subscription_id
}

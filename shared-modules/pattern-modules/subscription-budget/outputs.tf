# =============================================================================
# Subscription Budget Pattern Module - Outputs
# =============================================================================

output "budget_id" {
  description = "The ID of the consumption budget"
  value       = module.budget.id
}

output "budget_name" {
  description = "The name of the consumption budget"
  value       = module.budget.name
}

output "action_group_id" {
  description = "The ID of the action group (if created)"
  value       = var.enable_action_group ? module.action_group[0].id : null
}

output "action_group_name" {
  description = "The name of the action group (if created)"
  value       = var.enable_action_group ? module.action_group[0].name : null
}

output "budget_summary" {
  description = "Summary of the budget configuration"
  value = {
    name                 = module.budget.name
    subscription_id      = var.subscription_id
    amount               = var.budget_amount
    time_grain           = var.time_grain
    actual_threshold     = var.actual_threshold
    forecasted_threshold = var.forecasted_threshold
    action_group_enabled = var.enable_action_group
    action_group_id      = var.enable_action_group ? module.action_group[0].id : null
  }
}

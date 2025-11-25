# =============================================================================
# Outputs for Azure Landing Zone Deployment
# =============================================================================

output "management_group_ids" {
  description = "Map of management group names to their resource IDs"
  value       = module.alz.management_group_resource_ids
}

output "policy_assignment_ids" {
  description = "Map of policy assignment names to their resource IDs"
  value       = module.alz.policy_assignment_resource_ids
}

output "policy_definition_ids" {
  description = "Map of policy definition names to their resource IDs"
  value       = module.alz.policy_definition_resource_ids
}

output "policy_set_definition_ids" {
  description = "Map of policy set definition (initiative) names to their resource IDs"
  value       = module.alz.policy_set_definition_resource_ids
}

output "policy_role_assignment_ids" {
  description = "Map of policy role assignments to their resource IDs"
  value       = module.alz.policy_role_assignment_resource_ids
}

output "tenant_id" {
  description = "Azure AD tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  description = "Current subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
}

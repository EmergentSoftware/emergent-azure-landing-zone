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

# =============================================================================
# Cost Management Budget Outputs
# =============================================================================

output "cost_monitoring_resource_group_name" {
  description = "The name of the cost monitoring resource group"
  value       = module.cost_monitoring_resource_group.name
}

output "action_group_ids" {
  description = "Map of cost center action group IDs"
  value = {
    infrastructure = module.budget_management.action_group_id
    it_operations  = module.budget_portals_admin_dev.action_group_id
    marketing      = module.budget_portals_customer_dev.action_group_id
  }
}

output "budget_ids" {
  description = "Map of budget names to their resource IDs"
  value = {
    management            = module.budget_management.budget_id
    connectivity          = module.budget_connectivity.budget_id
    identity              = module.budget_identity.budget_id
    portals_admin_dev     = module.budget_portals_admin_dev.budget_id
    portals_admin_prod    = module.budget_portals_admin_prod.budget_id
    portals_customer_dev  = module.budget_portals_customer_dev.budget_id
    portals_customer_prod = module.budget_portals_customer_prod.budget_id
  }
}

output "budget_summary" {
  description = "Summary of all budgets with amounts and alert thresholds"
  value = {
    management            = module.budget_management.budget_summary
    connectivity          = module.budget_connectivity.budget_summary
    identity              = module.budget_identity.budget_summary
    portals_admin_dev     = module.budget_portals_admin_dev.budget_summary
    portals_admin_prod    = module.budget_portals_admin_prod.budget_summary
    portals_customer_dev  = module.budget_portals_customer_dev.budget_summary
    portals_customer_prod = module.budget_portals_customer_prod.budget_summary
  }
}

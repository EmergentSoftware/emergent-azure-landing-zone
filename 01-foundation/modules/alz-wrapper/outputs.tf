# =============================================================================
# Wrapper Module Outputs
# =============================================================================

output "management_group_resource_ids" {
  description = "Map of management group names to their resource IDs"
  value       = module.alz.management_group_resource_ids
}

output "policy_assignment_resource_ids" {
  description = "Map of policy assignment names to their resource IDs"
  value       = module.alz.policy_assignment_resource_ids
}

output "policy_definition_resource_ids" {
  description = "Map of policy definition names to their resource IDs"
  value       = module.alz.policy_definition_resource_ids
}

output "policy_set_definition_resource_ids" {
  description = "Map of policy set definition names to their resource IDs"
  value       = module.alz.policy_set_definition_resource_ids
}

output "policy_role_assignment_resource_ids" {
  description = "Map of policy role assignment IDs"
  value       = module.alz.policy_role_assignment_resource_ids
}

output "role_definition_resource_ids" {
  description = "Map of custom role definition names to their resource IDs"
  value       = module.alz.role_definition_resource_ids
}

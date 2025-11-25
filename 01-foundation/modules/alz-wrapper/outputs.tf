# =============================================================================
# Wrapper Module Outputs
# =============================================================================

output "management_group_ids" {
  description = "Map of management group names to their resource IDs"
  value       = module.alz.management_groups
}

output "policy_assignment_ids" {
  description = "Map of policy assignment names to their resource IDs"
  value       = module.alz.policy_assignments
}

output "policy_definition_ids" {
  description = "Map of policy definition names to their resource IDs"
  value       = module.alz.policy_definitions
}

output "policy_set_definition_ids" {
  description = "Map of policy set definition names to their resource IDs"
  value       = module.alz.policy_set_definitions
}

output "policy_role_assignment_ids" {
  description = "Map of policy role assignment IDs"
  value       = module.alz.policy_role_assignments
}

output "role_definition_ids" {
  description = "Map of custom role definition names to their resource IDs"
  value       = module.alz.role_definitions
}

# =============================================================================
# Wrapper Module Variables
# =============================================================================

variable "parent_resource_id" {
  description = "The parent resource ID (typically the tenant ID)"
  type        = string
}

variable "architecture_name" {
  description = "The name of the architecture definition to use (e.g., 'alz')"
  type        = string
  default     = "alz"
}

variable "location" {
  description = "The default Azure region for policy managed identities and resources"
  type        = string
}

variable "management_group_hierarchy_settings" {
  description = "Settings for the management group hierarchy"
  type = object({
    default_management_group_name            = string
    require_authorization_for_group_creation = bool
  })
  default = null
}

variable "policy_assignments_to_modify" {
  description = "Policy assignments to modify from the default architecture"
  type = map(object({
    policy_assignments = map(object({
      enforcement_mode = optional(string, null)
      identity         = optional(string, null)
      identity_ids     = optional(list(string), null)
      parameters       = optional(map(string), null)
      non_compliance_messages = optional(set(object({
        message                        = string
        policy_definition_reference_id = optional(string, null)
      })), null)
      resource_selectors = optional(list(object({
        name = string
        resource_selector_selectors = optional(list(object({
          kind   = string
          in     = optional(set(string), null)
          not_in = optional(set(string), null)
        })), [])
      })))
      overrides = optional(list(object({
        kind  = string
        value = string
        override_selectors = optional(list(object({
          kind   = string
          in     = optional(set(string), null)
          not_in = optional(set(string), null)
        })), [])
      })))
    }))
  }))
  default = {}
}

variable "policy_default_values" {
  description = "Default values to apply to policy assignments"
  type        = map(string)
  default     = null
}

variable "enable_telemetry" {
  description = "Enable telemetry for the AVM module"
  type        = bool
  default     = true
}

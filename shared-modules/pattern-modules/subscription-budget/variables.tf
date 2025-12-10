# =============================================================================
# Subscription Budget Pattern Module - Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Budget Configuration
# -----------------------------------------------------------------------------

variable "budget_name" {
  description = "The name of the consumption budget"
  type        = string
}

variable "subscription_id" {
  description = "The ID of the subscription to apply the budget to"
  type        = string
}

variable "budget_amount" {
  description = "The total amount for the budget (in USD)"
  type        = number
}

variable "time_grain" {
  description = "The time grain for the budget (Monthly, Quarterly, Annually)"
  type        = string
  default     = "Monthly"

  validation {
    condition     = contains(["Monthly", "Quarterly", "Annually"], var.time_grain)
    error_message = "time_grain must be one of: Monthly, Quarterly, Annually"
  }
}

variable "start_date" {
  description = "The start date for the budget in RFC3339 format (YYYY-MM-01T00:00:00Z)"
  type        = string
}

variable "end_date" {
  description = "The end date for the budget in RFC3339 format (YYYY-MM-01T00:00:00Z). Use null for no end date."
  type        = string
  default     = null
}

variable "actual_threshold" {
  description = "The threshold percentage for actual spend alerts (e.g., 120 for 120%). Set to null to disable."
  type        = number
  default     = 120
}

variable "forecasted_threshold" {
  description = "The threshold percentage for forecasted spend alerts (e.g., 130 for 130%). Set to null to disable."
  type        = number
  default     = null
}

variable "contact_emails" {
  description = "List of email addresses to notify when thresholds are exceeded"
  type        = list(string)
  default     = []
}

variable "contact_roles" {
  description = "List of Azure RBAC roles to notify (e.g., Owner, Contributor)"
  type        = list(string)
  default     = ["Owner", "Contributor"]
}

variable "resource_group_filter" {
  description = "Optional list of resource group names to filter the budget scope"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Action Group Configuration
# -----------------------------------------------------------------------------

variable "enable_action_group" {
  description = "Whether to create an action group for this budget"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "The name of the resource group where the action group will be created. Required if enable_action_group is true."
  type        = string
  default     = null
}

variable "action_group_name" {
  description = "The name of the action group. If not provided, defaults to 'ag-{budget_name}'"
  type        = string
  default     = null
}

variable "action_group_short_name" {
  description = "The short name of the action group (max 12 characters). Required if enable_action_group is true."
  type        = string
  default     = null

  validation {
    condition     = var.action_group_short_name == null || length(var.action_group_short_name) <= 12
    error_message = "action_group_short_name must be 12 characters or less"
  }
}

variable "action_group_enabled" {
  description = "Whether the action group is enabled"
  type        = bool
  default     = true
}

variable "email_receivers" {
  description = "List of email receivers for the action group"
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = []
}

variable "sms_receivers" {
  description = "List of SMS receivers for the action group"
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = []
}

variable "webhook_receivers" {
  description = "List of webhook receivers for the action group"
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = []
}

variable "azure_app_push_receivers" {
  description = "List of Azure App push receivers for the action group"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "additional_action_group_ids" {
  description = "List of additional action group resource IDs to notify (in addition to the one created by this module)"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Common
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

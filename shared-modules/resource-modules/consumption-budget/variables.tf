# =============================================================================
# Azure Consumption Budget Variables
# =============================================================================

variable "name" {
  description = "The name of the consumption budget"
  type        = string
}

variable "subscription_id" {
  description = "The ID of the subscription to apply the budget to"
  type        = string
}

variable "amount" {
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

variable "contact_groups" {
  description = "List of action group resource IDs to notify"
  type        = list(string)
  default     = []
}

variable "resource_group_filter" {
  description = "Optional list of resource group names to filter the budget scope"
  type        = list(string)
  default     = []
}

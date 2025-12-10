# =============================================================================
# Variables for Azure Landing Zone Deployment
# =============================================================================

variable "subscription_id" {
  description = "Azure subscription ID for the management subscription"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "default_location" {
  description = "The default Azure region for policy managed identities and resources"
  type        = string
  default     = "eastus"
}

variable "security_contact_email" {
  description = "Email address for security contact notifications"
  type        = string
  default     = "joshd@acmecorporation.dev"
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for centralized logging (optional)"
  type        = string
  default     = ""
}

variable "allowed_locations" {
  description = "List of allowed Azure regions for resource deployment"
  type        = list(string)
  default = [
    "eastus",
    "centralus",
  ]
}

variable "enable_telemetry" {
  description = "Enable telemetry for the AVM module"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Subscription IDs for Budget Management
# =============================================================================

variable "management_subscription_id" {
  description = "Management subscription ID"
  type        = string
}

variable "connectivity_subscription_id" {
  description = "Connectivity subscription ID"
  type        = string
}

variable "identity_subscription_id" {
  description = "Identity subscription ID"
  type        = string
}

variable "portals_admin_dev_subscription_id" {
  description = "Portals Admin Dev subscription ID"
  type        = string
}

variable "portals_admin_prod_subscription_id" {
  description = "Portals Admin Prod subscription ID"
  type        = string
}

variable "portals_customer_dev_subscription_id" {
  description = "Portals Customer Dev subscription ID"
  type        = string
}

variable "portals_customer_prod_subscription_id" {
  description = "Portals Customer Prod subscription ID"
  type        = string
}

# =============================================================================
# Budget Configuration
# =============================================================================

variable "budget_start_date" {
  description = "Start date for all budgets in RFC3339 format (YYYY-MM-01T00:00:00Z)"
  type        = string
  default     = "2025-12-01T00:00:00Z"
}

variable "budget_contact_emails" {
  description = "List of email addresses to notify for budget alerts"
  type        = list(string)
  default     = ["finance@acmecorporation.dev", "joshd@acmecorporation.dev"]
}

# Platform Subscription Budgets (Infrastructure cost center)
variable "budget_amount_management" {
  description = "Monthly budget amount for management subscription (USD)"
  type        = number
  default     = 10
}

variable "budget_amount_connectivity" {
  description = "Monthly budget amount for connectivity subscription (USD)"
  type        = number
  default     = 10
}

variable "budget_amount_identity" {
  description = "Monthly budget amount for identity subscription (USD)"
  type        = number
  default     = 10
}

# Workload Subscription Budgets
variable "budget_amount_portals_admin_dev" {
  description = "Monthly budget amount for portals admin dev subscription (USD)"
  type        = number
  default     = 10
}

variable "budget_amount_portals_admin_prod" {
  description = "Monthly budget amount for portals admin prod subscription (USD)"
  type        = number
  default     = 10
}

variable "budget_amount_portals_customer_dev" {
  description = "Monthly budget amount for portals customer dev subscription (USD)"
  type        = number
  default     = 10
}

variable "budget_amount_portals_customer_prod" {
  description = "Monthly budget amount for portals customer prod subscription (USD)"
  type        = number
  default     = 10
}

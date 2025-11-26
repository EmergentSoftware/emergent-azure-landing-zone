# =============================================================================
# Pre-Bootstrap Variables
# =============================================================================

variable "tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "management_subscription_id" {
  description = "Existing subscription ID where this Terraform runs (temporary, can be any subscription with contributor access)"
  type        = string
}

variable "billing_scope_id" {
  description = "Azure billing scope ID for subscription creation. Format: /providers/Microsoft.Billing/billingAccounts/{billingAccountId}/enrollmentAccounts/{enrollmentAccountId} for EA or /providers/Microsoft.Billing/billingAccounts/{billingAccountId}/billingProfiles/{billingProfileId}/invoiceSections/{invoiceSectionId} for MCA. Not required for CSP - leave empty."
  type        = string
  default     = ""
}

variable "billing_model" {
  description = "Billing model: 'EA' (Enterprise Agreement), 'MCA' (Microsoft Customer Agreement), or 'CSP' (Cloud Solution Provider)"
  type        = string
  default     = "EA"
  validation {
    condition     = contains(["EA", "MCA", "CSP"], var.billing_model)
    error_message = "billing_model must be one of: EA, MCA, CSP"
  }
}

variable "csp_customer_tenant_id" {
  description = "Customer tenant ID for CSP subscription creation. Required when billing_model is 'CSP'."
  type        = string
  default     = ""
}

# =============================================================================
# Management Subscription Configuration
# =============================================================================

variable "create_management_subscription" {
  description = "Create a new management subscription for bootstrap resources"
  type        = bool
  default     = true
}

variable "management_subscription_alias" {
  description = "Alias name for the management subscription"
  type        = string
  default     = "sub-management-001"
}

variable "management_subscription_name" {
  description = "Display name for the management subscription"
  type        = string
  default     = "Management"
}

# =============================================================================
# Corp Landing Zone Subscriptions
# =============================================================================

variable "corp_subscriptions" {
  description = "Map of corp landing zone subscriptions to create"
  type = map(object({
    alias        = string
    display_name = string
    workload     = string
  }))
  default = {
    corp_001 = {
      alias        = "sub-corp-001"
      display_name = "Corp-001"
      workload     = "Production"
    }
  }
}

# =============================================================================
# Online Landing Zone Subscriptions
# =============================================================================

variable "online_subscriptions" {
  description = "Map of online landing zone subscriptions to create"
  type = map(object({
    alias        = string
    display_name = string
    workload     = string
  }))
  default = {
    online_001 = {
      alias        = "sub-online-001"
      display_name = "Online-001"
      workload     = "Production"
    }
  }
}

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
  default     = "security@acme.com"
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
    "eastus2",
    "centralus",
    "westus2"
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

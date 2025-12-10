# =============================================================================
# Azure Monitor Action Group Variables
# =============================================================================

variable "name" {
  description = "The name of the action group"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the action group will be created"
  type        = string
}

variable "short_name" {
  description = "The short name of the action group (max 12 characters)"
  type        = string

  validation {
    condition     = length(var.short_name) <= 12
    error_message = "short_name must be 12 characters or less"
  }
}

variable "enabled" {
  description = "Whether the action group is enabled"
  type        = bool
  default     = true
}

variable "email_receivers" {
  description = "List of email receivers"
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = []
}

variable "sms_receivers" {
  description = "List of SMS receivers"
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  default = []
}

variable "webhook_receivers" {
  description = "List of webhook receivers"
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = optional(bool, true)
  }))
  default = []
}

variable "azure_app_push_receivers" {
  description = "List of Azure App push receivers"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the action group"
  type        = map(string)
  default     = {}
}

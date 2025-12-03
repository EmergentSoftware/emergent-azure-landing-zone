variable "subscription_id" {
  description = "The portal customer prod subscription ID"
  type        = string
  default     = "b13c8883-9bf3-4ebb-af9c-7ebfcc8e9a5a" # acme-portals-customer-prod
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "management_group_name" {
  description = "Management group name for portals (acme-portals)"
  type        = string
  default     = "acme-portals"
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for shared resources"
  type        = string
  default     = "eastus2"
}

# Monitoring Variables
variable "create_log_analytics" {
  description = "Whether to create a Log Analytics workspace for this landing zone"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

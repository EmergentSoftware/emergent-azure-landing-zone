# =============================================================================
# Landing Zone Workload Module Variables
# =============================================================================

# Subscription Configuration
variable "subscription_id" {
  description = "The subscription ID for this workload landing zone"
  type        = string
}

variable "management_group_name" {
  description = "The name of the management group to associate the subscription with"
  type        = string
}

# Naming and Tagging
variable "landing_zone_name" {
  description = "The name of this landing zone (e.g., 'portals-admin-dev')"
  type        = string
}

variable "purpose" {
  description = "The purpose of this landing zone (e.g., 'Landing Zone - Portal Admin Dev')"
  type        = string
}

variable "environment" {
  description = "The environment for this landing zone (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod"
  }
}

variable "location" {
  description = "The Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "naming_suffix" {
  description = "Suffix for naming module (e.g., ['portals', 'dev'])"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    DeploymentMethod = "Terraform"
    Repository       = "emergent-azure-landing-zone"
  }
}

# Monitoring Configuration
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

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

# =============================================================================
# Variables for Portal Workload
# =============================================================================

variable "subscription_id" {
  description = "The Azure subscription ID where resources will be deployed"
  type        = string
}

variable "landing_zone" {
  description = "Landing zone name (used in resource naming)"
  type        = string
  default     = "portals"
}

variable "workload_name" {
  description = "Name of the workload (used in resource naming)"
  type        = string
  default     = "demo"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.workload_name))
    error_message = "Workload name must be 2-20 lowercase alphanumeric characters or hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus2" # Static Web Apps common regions
}

variable "static_web_app_sku_tier" {
  description = "SKU tier for Static Web App (Free or Standard). Standard required for private endpoints."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard"], var.static_web_app_sku_tier)
    error_message = "SKU tier must be either Free or Standard."
  }
}

variable "static_web_app_sku_size" {
  description = "SKU size for Static Web App (Free or Standard). Standard required for private endpoints."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard"], var.static_web_app_sku_size)
    error_message = "SKU size must be either Free or Standard."
  }
}

variable "enable_managed_identity" {
  description = "Enable system-assigned managed identity for the Static Web App"
  type        = bool
  default     = true
}

variable "enable_application_insights" {
  description = "Enable Application Insights monitoring"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics and App Insights"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default = {
    Project = "ALZ Demo"
  }
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}


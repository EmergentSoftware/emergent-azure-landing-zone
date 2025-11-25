# =============================================================================
# Variables for Web App Workload
# =============================================================================

variable "subscription_id" {
  description = "The Azure subscription ID where resources will be deployed"
  type        = string
}

variable "workload_name" {
  description = "Name of the workload (used in resource naming)"
  type        = string
  default     = "demo"

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.workload_name))
    error_message = "Workload name must be 2-10 lowercase alphanumeric characters."
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
  default     = "eastus"
}

variable "app_service_os_type" {
  description = "Operating system type for App Service (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.app_service_os_type)
    error_message = "OS type must be Linux or Windows."
  }
}

variable "app_service_sku_name" {
  description = "SKU name for App Service Plan (e.g., B1, S1, P1v2)"
  type        = string
  default     = "B1"

  validation {
    condition     = can(regex("^(B[1-3]|S[1-3]|P[1-3]v[2-3]|F1|D1)$", var.app_service_sku_name))
    error_message = "Invalid SKU name. Examples: B1, S1, P1v2."
  }
}

variable "enable_managed_identity" {
  description = "Enable system-assigned managed identity for the web app"
  type        = bool
  default     = true
}

variable "enable_cors" {
  description = "Enable CORS configuration"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = []
}

variable "health_check_path" {
  description = "Path for health check endpoint (leave empty to disable)"
  type        = string
  default     = ""
}

variable "app_settings" {
  description = "Additional application settings for the web app"
  type        = map(string)
  default     = {}
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

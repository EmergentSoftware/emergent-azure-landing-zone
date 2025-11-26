# =============================================================================
# Bootstrap Variables
# =============================================================================

variable "subscription_id" {
  description = "Azure subscription ID where the state storage will be created (platform/management subscription)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for Terraform state storage"
  type        = string
  default     = "rg-terraform-state"
}

variable "location" {
  description = "Azure region for the state storage resources"
  type        = string
  default     = "eastus"
}

variable "storage_account_prefix" {
  description = "Prefix for the storage account name (will be appended with random suffix)"
  type        = string
  default     = "tfstate"

  validation {
    condition     = can(regex("^[a-z0-9]{3,18}$", var.storage_account_prefix))
    error_message = "Storage account prefix must be 3-18 characters, lowercase letters and numbers only."
  }
}

variable "storage_account_replication" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS" # Options: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication)
    error_message = "Invalid replication type. Must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain deleted blobs and containers"
  type        = number
  default     = 30

  validation {
    condition     = var.soft_delete_retention_days >= 1 && var.soft_delete_retention_days <= 365
    error_message = "Retention days must be between 1 and 365."
  }
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
  default     = "prod"
}

variable "containers" {
  description = "List of blob container names to create for Terraform state storage"
  type        = list(string)
  default = [
    "tfstate-foundation",
    "tfstate-workloads",
    "tfstate-portal-dev",
    "tfstate-portal-prod"
  ]

  validation {
    condition = alltrue([
      for container in var.containers :
      can(regex("^[a-z0-9]([a-z0-9-]{1,61}[a-z0-9])?$", container))
    ])
    error_message = "Container names must be 3-63 characters, lowercase letters, numbers, and hyphens only."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default = {
    Project = "Azure Landing Zone"
    Owner   = "Platform Team"
  }
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

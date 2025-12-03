# =============================================================================
# Required Variables
# =============================================================================

variable "subscription_id" {
  description = "The Azure subscription ID where resources will be deployed"
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus2"
}

# =============================================================================
# Naming and Tagging
# =============================================================================

variable "naming_suffix" {
  description = "Suffix components for resource naming (e.g., ['portals', 'admin', 'dev'])"
  type        = list(string)
}

variable "purpose" {
  description = "Purpose description for the static site"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Storage Configuration
# =============================================================================

variable "storage_account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Invalid storage replication type."
  }
}

# =============================================================================
# Static Website Configuration
# =============================================================================

variable "index_document" {
  description = "The default document for the static website (e.g., index.html)"
  type        = string
  default     = "index.html"
}

variable "error_404_document" {
  description = "The 404 error document for the static website (e.g., 404.html)"
  type        = string
  default     = "404.html"
}

# =============================================================================
# Variables for Static Site Storage Pattern
# =============================================================================

variable "subscription_id" {
  description = "The Azure subscription ID where resources will be deployed"
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "workload_name" {
  description = "Name of the workload (used in resource naming)"
  type        = string
  default     = "site"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"

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
# Storage Configuration
# =============================================================================

variable "storage_account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"
}

# =============================================================================
# Static Website Configuration
# =============================================================================

variable "index_document" {
  description = "The default document for the static website"
  type        = string
  default     = "index.html"
}

variable "error_404_document" {
  description = "The 404 error document for the static website"
  type        = string
  default     = "404.html"
}

# =============================================================================
# Tagging Configuration
# =============================================================================

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

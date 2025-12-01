variable "name" {
  description = "The name of the Static Web App"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the Static Web App will be created"
  type        = string
}

variable "sku_tier" {
  description = "The SKU tier for the Static Web App (Free or Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "sku_tier must be either 'Free' or 'Standard'"
  }
}

variable "sku_size" {
  description = "The SKU size for the Static Web App (Free or Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard"], var.sku_size)
    error_message = "sku_size must be either 'Free' or 'Standard'"
  }
}

variable "enable_managed_identity" {
  description = "Enable system-assigned managed identity for the Static Web App"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

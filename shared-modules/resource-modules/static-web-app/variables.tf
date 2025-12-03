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

variable "public_network_access_enabled" {
  description = "Enable public network access for the Static Web App. Automatically set to false when private_endpoint_subnet_id is provided."
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet where the private endpoint will be created. If provided, a private endpoint will be created and public access will be disabled."
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs to associate with the private endpoint. Required when private_endpoint_subnet_id is provided."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "subscription_id" {
  description = "The connectivity subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "management_group_name" {
  description = "Management group name for connectivity (acme-connectivity)"
  type        = string
  default     = "acme-connectivity"
}

variable "location" {
  description = "Primary Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "Short name for Azure region"
  type        = string
  default     = "eus2"
}

variable "dns_servers" {
  description = "List of DNS servers for the VNet (empty = Azure default DNS)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Environment = "Production"
    LandingZone = "Connectivity"
  }
}

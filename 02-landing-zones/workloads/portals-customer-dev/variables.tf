variable "subscription_id" {
  description = "The portal customer dev subscription ID"
  type        = string
  default     = "9a877ddf-9796-43a8-a557-f6af1df195bf" # acme-portals-customer-dev
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
  default     = "dev"
}

variable "location" {
  description = "Azure region for shared resources"
  type        = string
  default     = "eastus2"
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

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    DeploymentMethod = "Terraform"
    Repository       = "emergent-azure-landing-zone"
  }
}

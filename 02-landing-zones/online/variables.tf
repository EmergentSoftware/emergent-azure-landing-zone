variable "subscription_id" {
  description = "The subscription ID where this Terraform will authenticate (can be different from workload subscription)"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "workload_subscription_id" {
  description = "The subscription ID to place into the landing zone"
  type        = string
}

variable "landing_zone_name" {
  description = "Name of the landing zone (e.g., 'online-public-apis', 'online-ecommerce')"
  type        = string
}

variable "landing_zone_management_group_name" {
  description = "Management group name from ALZ foundation (typically 'acme-landingzones-online')"
  type        = string
  default     = "acme-landingzones-online"
}

variable "location" {
  description = "Azure region for shared resources"
  type        = string
  default     = "eastus"
}

# Networking Variables
variable "create_virtual_network" {
  description = "Whether to create a virtual network for this landing zone"
  type        = bool
  default     = true
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "vnet_subnets" {
  description = "Map of subnets to create in the virtual network"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    })), [])
  }))
  default = {
    frontend = {
      address_prefixes  = ["10.1.1.0/24"]
      service_endpoints = ["Microsoft.Web", "Microsoft.Storage"]
    }
    backend = {
      address_prefixes  = ["10.1.2.0/24"]
      service_endpoints = ["Microsoft.Web", "Microsoft.Sql", "Microsoft.Storage"]
    }
  }
}

variable "vnet_dns_servers" {
  description = "List of DNS servers for the virtual network (use Azure default if not specified)"
  type        = list(string)
  default     = null
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
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

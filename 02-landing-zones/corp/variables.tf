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
  description = "Name of the landing zone (e.g., 'corp-web-apps', 'corp-data')"
  type        = string
}

variable "landing_zone_management_group_name" {
  description = "Management group name from ALZ foundation (typically 'acme-landingzones-corp')"
  type        = string
  default     = "acme-landingzones-corp"
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
  default     = ["10.0.0.0/16"]
}

variable "vnet_subnets" {
  description = "Map of subnets to create in the virtual network (AVM v0.16+ format)"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    service_endpoints_with_location = optional(list(object({
      service   = string
      locations = optional(list(string), ["*"])
    })), [])
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })), [])
  }))
  default = {
    default = {
      name             = "subnet-default"
      address_prefixes = ["10.0.1.0/24"]
    }
    webapp = {
      name             = "subnet-webapp"
      address_prefixes = ["10.0.2.0/24"]
      service_endpoints_with_location = [
        { service = "Microsoft.Web" },
        { service = "Microsoft.Storage" },
        { service = "Microsoft.KeyVault" }
      ]
    }
  }
}

variable "vnet_dns_servers" {
  description = "DNS servers configuration for the virtual network (AVM v0.16+ format)"
  type = object({
    dns_servers = list(string)
  })
  default = null
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

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "subscription_id" {
  description = "The portal admin dev subscription ID"
  type        = string
  default     = "588aa873-b13e-40bc-a96f-89805c56d7d0" # acme-portals-admin-dev
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

# Networking Variables
variable "create_virtual_network" {
  description = "Whether to create a virtual network for this landing zone"
  type        = bool
  default     = true
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.200.0.0/16"]
}

variable "vnet_subnets" {
  description = "Map of subnets to create in the virtual network"
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
    webapp = {
      name             = "subnet-webapp"
      address_prefixes = ["10.200.1.0/24"]
      delegations = [{
        name = "delegation"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
        }
      }]
    }
    privateendpoints = {
      name             = "subnet-privateendpoints"
      address_prefixes = ["10.200.2.0/24"]
    }
    data = {
      name             = "subnet-data"
      address_prefixes = ["10.200.3.0/24"]
      service_endpoints_with_location = [
        { service = "Microsoft.Sql", locations = ["eastus"] },
        { service = "Microsoft.Storage", locations = ["eastus"] }
      ]
    }
  }
}

variable "vnet_dns_servers" {
  description = "DNS servers configuration for the virtual network"
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

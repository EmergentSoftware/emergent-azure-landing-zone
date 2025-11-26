variable "subscription_id" {
  description = "The management subscription ID"
  type        = string
  default     = "1302f5fd-f3b5-4eda-909c-e3ae2dfee3d6"
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "management_group_name" {
  description = "Management group name for management (acme-management)"
  type        = string
  default     = "acme-management"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
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
  default     = ["10.100.0.0/16"]
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
    management = {
      name             = "subnet-management"
      address_prefixes = ["10.100.1.0/24"]
      service_endpoints_with_location = [
        { service = "Microsoft.Storage" },
        { service = "Microsoft.KeyVault" }
      ]
    }
    bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.100.2.0/26"]
    }
    devops = {
      name             = "subnet-devops"
      address_prefixes = ["10.100.3.0/24"]
      service_endpoints_with_location = [
        { service = "Microsoft.Storage" },
        { service = "Microsoft.ContainerRegistry" }
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

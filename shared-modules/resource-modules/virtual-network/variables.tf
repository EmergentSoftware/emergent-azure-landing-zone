variable "name" {
  description = "The name of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the virtual network will be created"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets to create in the virtual network (AVM v0.16+ format)"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    network_security_group = optional(object({
      id = string
    }))
    route_table = optional(object({
      id = string
    }))
    private_endpoint_network_policies_enabled = optional(bool, true)
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
  default = {}
}

variable "dns_servers" {
  description = "DNS servers configuration for the virtual network (AVM v0.16+ format requires object)"
  type = object({
    dns_servers = list(string)
  })
  default = null
}

variable "tags" {
  description = "Tags to apply to the virtual network"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Route Table Module - Variables
# =============================================================================

variable "name" {
  description = "Name of the Route Table"
  type        = string
}

variable "location" {
  description = "Azure region where the Route Table will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Route Table"
  type        = map(string)
  default     = {}
}

variable "routes" {
  description = "Map of routes to create"
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}
}

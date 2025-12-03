variable "name" {
  description = "The name of the private endpoint"
  type        = string
}

variable "location" {
  description = "The Azure region where the private endpoint will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the private endpoint will be created"
  type        = string
}

variable "private_connection_resource_id" {
  description = "The ID of the resource to which the private endpoint will connect"
  type        = string
}

variable "subresource_names" {
  description = "A list of subresource names which the Private Endpoint is able to connect to"
  type        = list(string)
}

variable "is_manual_connection" {
  description = "Does the Private Endpoint require Manual Approval from the remote resource owner?"
  type        = bool
  default     = false
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs to associate with the private endpoint"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

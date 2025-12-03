variable "name" {
  description = "The name of the storage container"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{1,61}[a-z0-9])?$", var.name))
    error_message = "Container names must be 3-63 characters, lowercase letters, numbers, and hyphens only."
  }
}

variable "storage_account_id" {
  description = "The ID of the storage account where the container will be created"
  type        = string
}

variable "container_access_type" {
  description = "The access level for the container (private, blob, or container)"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "Container access type must be one of: private, blob, container."
  }
}

variable "metadata" {
  description = "A mapping of metadata to assign to the container"
  type        = map(string)
  default     = {}
}

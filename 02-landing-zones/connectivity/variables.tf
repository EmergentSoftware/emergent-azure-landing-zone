variable "subscription_id" {
  description = "The connectivity subscription ID"
  type        = string
  default     = "c82e0943-3765-49ff-97ff-92855167f3ea"
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

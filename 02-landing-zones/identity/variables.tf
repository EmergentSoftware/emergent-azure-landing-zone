variable "subscription_id" {
  description = "The identity subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "management_group_name" {
  description = "Management group name for identity (acme-identity)"
  type        = string
  default     = "acme-identity"
}

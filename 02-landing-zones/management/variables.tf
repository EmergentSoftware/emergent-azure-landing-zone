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

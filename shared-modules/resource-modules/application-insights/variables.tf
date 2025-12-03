variable "name" {
  description = "The name of the Application Insights component"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where Application Insights will be created"
  type        = string
}

variable "application_type" {
  description = "The type of application (web, ios, java, etc.)"
  type        = string
  default     = "web"
}

variable "workspace_id" {
  description = "The resource ID of the Log Analytics workspace"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to Application Insights"
  type        = map(string)
  default     = {}
}

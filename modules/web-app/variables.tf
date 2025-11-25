variable "name" {
  description = "The name of the web app"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the web app will be created"
  type        = string
}

variable "kind" {
  description = "The kind of web app (e.g., 'app,linux' or 'app')"
  type        = string
  default     = "app,linux"
}

variable "service_plan_resource_id" {
  description = "The resource ID of the App Service Plan"
  type        = string
}

variable "https_only" {
  description = "Enable HTTPS only"
  type        = bool
  default     = true
}

variable "site_config" {
  description = "Site configuration block"
  type        = any
  default     = {}
}

variable "app_settings" {
  description = "Application settings"
  type        = map(string)
  default     = {}
}

variable "managed_identities" {
  description = "Managed identity configuration"
  type        = any
  default     = null
}

variable "diagnostic_settings" {
  description = "Diagnostic settings configuration"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the web app"
  type        = map(string)
  default     = {}
}

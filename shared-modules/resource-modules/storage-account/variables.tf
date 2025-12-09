variable "name" {
  description = "Name of the storage account"
  type        = string
}

variable "location" {
  description = "Azure region for the storage account"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "GRS"
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

variable "allow_nested_items_to_be_public" {
  description = "Allow nested items to be public"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Enable shared access key"
  type        = bool
  default     = true
}

variable "https_traffic_only_enabled" {
  description = "Enforce HTTPS traffic only"
  type        = bool
  default     = true
}

variable "infrastructure_encryption_enabled" {
  description = "Enable infrastructure encryption"
  type        = bool
  default     = true
}

variable "cross_tenant_replication_enabled" {
  description = "Enable cross-tenant replication"
  type        = bool
  default     = false
}

variable "default_to_oauth_authentication" {
  description = "Default to OAuth authentication"
  type        = bool
  default     = false
}

variable "nfsv3_enabled" {
  description = "Enable NFSv3"
  type        = bool
  default     = false
}

variable "sftp_enabled" {
  description = "Enable SFTP"
  type        = bool
  default     = false
}

variable "large_file_share_enabled" {
  description = "Enable large file shares"
  type        = bool
  default     = false
}

variable "queue_encryption_key_type" {
  description = "Queue encryption key type"
  type        = string
  default     = "Service"
}

variable "table_encryption_key_type" {
  description = "Table encryption key type"
  type        = string
  default     = "Service"
}

variable "access_tier" {
  description = "Access tier (Hot or Cool)"
  type        = string
  default     = "Hot"
}

variable "is_hns_enabled" {
  description = "Enable hierarchical namespace (Data Lake Gen2)"
  type        = bool
  default     = false
}

variable "azure_files_authentication" {
  description = "Azure Files authentication configuration"
  type        = any
  default     = null
}

variable "customer_managed_key" {
  description = "Customer managed key configuration"
  type        = any
  default     = null
}

variable "immutability_policy" {
  description = "Immutability policy configuration"
  type        = any
  default     = null
}

variable "edge_zone" {
  description = "Edge zone"
  type        = string
  default     = null
}

variable "sas_policy" {
  description = "SAS policy configuration"
  type        = any
  default     = null
}

variable "allowed_copy_scope" {
  description = "Allowed copy scope"
  type        = string
  default     = null
}

variable "network_rules" {
  description = "Network rules configuration"
  type        = any
  default     = null
}

variable "local_user" {
  description = "Local user configuration"
  type        = map(any)
  default     = {}
}

variable "managed_identities" {
  description = "Managed identities configuration"
  type        = any
  default     = {}
}

variable "private_endpoints" {
  description = "Private endpoints configuration"
  type        = any
  default     = {}
}

variable "queue_properties" {
  description = "Queue properties configuration"
  type        = any
  default     = null
}

variable "role_assignments" {
  description = "Role assignments configuration"
  type        = any
  default     = {}
}

variable "static_website" {
  description = "Static website configuration"
  type        = any
  default     = {}
}

variable "share_properties" {
  description = "Share properties configuration"
  type        = any
  default     = null
}

variable "blob_properties" {
  description = "Blob properties configuration"
  type        = any
  default     = null
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Storage Account Wrapper Module
# Wraps Azure/avm-res-storage-storageaccount/azurerm
# =============================================================================

terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.4"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # Security settings
  min_tls_version                   = var.min_tls_version
  public_network_access_enabled     = var.public_network_access_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  shared_access_key_enabled         = var.shared_access_key_enabled
  https_traffic_only_enabled        = var.https_traffic_only_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  nfsv3_enabled                     = var.nfsv3_enabled
  sftp_enabled                      = var.sftp_enabled
  large_file_share_enabled          = var.large_file_share_enabled
  queue_encryption_key_type         = var.queue_encryption_key_type
  table_encryption_key_type         = var.table_encryption_key_type
  access_tier                       = var.access_tier
  is_hns_enabled                    = var.is_hns_enabled

  # Optional complex objects
  azure_files_authentication = var.azure_files_authentication
  customer_managed_key       = var.customer_managed_key
  immutability_policy        = var.immutability_policy
  edge_zone                  = var.edge_zone
  sas_policy                 = var.sas_policy
  allowed_copy_scope         = var.allowed_copy_scope
  network_rules              = var.network_rules
  local_user                 = var.local_user
  managed_identities         = var.managed_identities
  private_endpoints          = var.private_endpoints
  queue_properties           = var.queue_properties
  role_assignments           = var.role_assignments
  static_website             = var.static_website
  share_properties           = var.share_properties
  blob_properties            = var.blob_properties

  tags = var.tags
}

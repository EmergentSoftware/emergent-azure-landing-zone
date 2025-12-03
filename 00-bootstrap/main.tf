# =============================================================================
# Bootstrap: Terraform State Storage
# This configuration creates the Azure Storage Account and containers
# for storing Terraform state files for the Azure Landing Zone deployment
# =============================================================================

terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Bootstrap uses local state - this is the only layer without remote state
  # After this runs, all other layers will use the storage account created here
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

# Get current Azure context
data "azurerm_client_config" "current" {}

# =============================================================================
# Naming Module for Consistent Azure Resource Naming
# =============================================================================

module "naming" {
  source   = "../shared-modules/utility-modules/naming"
  location = var.location
  suffix   = [var.environment]
}

# Prepare common tags for all resources
locals {
  common_tags = merge(
    var.tags,
    var.common_tags,
    {
      Purpose     = "Terraform State Storage"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  )
}

# =============================================================================
# Resource Group for Terraform State
# =============================================================================

module "resource_group" {
  source = "../shared-modules/resource-modules/resource-group"

  name     = module.naming.resource_group.name_unique
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# Storage Account for Terraform State
# =============================================================================

module "storage_account" {
  source = "../shared-modules/resource-modules/storage-account"

  name                = module.naming.storage_account.name_unique
  location            = var.location
  resource_group_name = module.resource_group.name

  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication

  # Security settings
  min_tls_version                   = "TLS1_2"
  public_network_access_enabled     = true
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = true
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true
  cross_tenant_replication_enabled  = false
  default_to_oauth_authentication   = false
  nfsv3_enabled                     = false
  sftp_enabled                      = false
  large_file_share_enabled          = false
  queue_encryption_key_type         = "Service"
  table_encryption_key_type         = "Service"
  access_tier                       = "Hot"
  is_hns_enabled                    = false

  # Optional complex objects
  azure_files_authentication = null
  customer_managed_key       = null
  immutability_policy        = null
  edge_zone                  = null
  sas_policy                 = null
  allowed_copy_scope         = null
  network_rules              = null
  local_user                 = {}
  managed_identities         = {}
  private_endpoints          = {}
  queue_properties           = {}
  role_assignments           = {}
  static_website             = {}
  share_properties           = null

  # Enable versioning and soft delete for protection
  blob_properties = {
    versioning_enabled       = true
    last_access_time_enabled = false
    change_feed_enabled      = false

    delete_retention_policy = {
      days = var.soft_delete_retention_days
    }

    container_delete_retention_policy = {
      days = var.soft_delete_retention_days
    }
  }

  tags = local.common_tags
}

# =============================================================================
# Blob Containers for Each Deployment Layer
# =============================================================================

module "containers" {
  source   = "../shared-modules/resource-modules/storage-container"
  for_each = toset(var.containers)

  name               = each.value
  storage_account_id = module.storage_account.resource_id
}

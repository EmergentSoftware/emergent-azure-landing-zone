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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
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
  subscription_id = var.subscription_id
}

# Get current Azure context
data "azurerm_client_config" "current" {}

# =============================================================================
# Naming Module for Consistent Azure Resource Naming
# =============================================================================

module "naming" {
  source = "../shared-modules/naming"
  suffix = [var.environment, var.location]
}

# Generate a random suffix for storage account name (must be globally unique)
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
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
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = module.naming.resource_group.name_unique
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# Storage Account for Terraform State
# =============================================================================

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.7"

  name                = "${module.naming.storage_account.name}${random_string.storage_suffix.result}"
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
  queue_properties           = null
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

module "foundation_container" {
  source = "../shared-modules/storage-container"

  name               = "tfstate-foundation"
  storage_account_id = module.storage_account.resource_id
}

module "landing_zones_container" {
  source = "../shared-modules/storage-container"

  name               = "tfstate-landing-zones"
  storage_account_id = module.storage_account.resource_id
}

module "workloads_container" {
  source = "../shared-modules/storage-container"

  name               = "tfstate-workloads"
  storage_account_id = module.storage_account.resource_id
}

# Optional: Create additional containers for different environments
module "additional_containers" {
  source   = "../shared-modules/storage-container"
  for_each = toset(var.additional_containers)

  name               = each.value
  storage_account_id = module.storage_account.resource_id
}

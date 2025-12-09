# =============================================================================
# Static Site Storage Pattern Module
# Creates blob storage configured for static website hosting
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

# =============================================================================
# Naming Module for Consistent Azure Resource Naming
# =============================================================================

module "naming" {
  source   = "../../utility-modules/naming"
  location = var.location
  suffix   = var.naming_suffix
}

# Prepare common tags for all resources
locals {
  common_tags = merge(
    var.tags,
    var.common_tags,
    {
      Purpose     = var.purpose
      Environment = var.environment
      ManagedBy   = "Terraform"
      Pattern     = "static-site-storage"
    }
  )
}

# =============================================================================
# Resource Group
# =============================================================================

module "resource_group" {
  source = "../../resource-modules/resource-group"

  name     = module.naming.resource_group.name_unique
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# Storage Account with Static Website Enabled
# =============================================================================

module "storage_account" {
  source = "../../resource-modules/storage-account"

  name                       = module.naming.storage_account.name_unique
  resource_group_name        = module.resource_group.name
  location                   = var.location
  account_tier               = var.storage_account_tier
  account_replication_type   = var.storage_replication_type
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  # Disable public network access to comply with policy
  # Note: Static websites won't work with disabled public access
  # This may need to be addressed with policy exemption for static sites
  public_network_access_enabled = false

  # Note: static_website disabled temporarily due to AVM module compatibility
  # Will be re-enabled after checking AVM module requirements
  # static_website = {
  #   index_document     = var.index_document
  #   error_404_document = var.error_404_document
  # }

  # Explicitly set queue_properties to empty map to avoid for_each null error
  queue_properties = {}

  tags = local.common_tags
}

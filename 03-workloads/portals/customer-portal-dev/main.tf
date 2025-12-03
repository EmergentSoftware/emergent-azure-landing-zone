# =============================================================================
# Customer Portal Dev Workload - Static Website Storage
# This demonstrates deploying a static HTML site using blob storage
# =============================================================================

terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    # Backend configuration will be provided via backend config parameters
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# =============================================================================
# Static Site Storage Pattern Module
# =============================================================================

module "static_site" {
  source = "../../../shared-modules/pattern-modules/static-site-storage"

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  environment     = var.environment
  location        = var.location
  naming_suffix   = ["portals", "customer", var.workload_name, var.environment]
  purpose         = "Customer Portal Static Site"

  storage_account_tier     = var.storage_account_tier
  storage_replication_type = var.storage_replication_type
  index_document           = var.index_document
  error_404_document       = var.error_404_document

  tags = var.tags
  common_tags = {
    DeploymentMethod = "Terraform"
    Repository       = "emergent-azure-landing-zone"
  }
}

# Prepare common tags for all resources
locals {
  common_tags = merge(
    var.tags,
    var.common_tags,
    {
      Workload    = var.workload_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      DeployedBy  = "Terraform"
    }
  )
}

# =============================================================================
# Resource Group using Wrapper Module
# =============================================================================

module "resource_group" {
  source = "../../../shared-modules/resource-modules/resource-group"

  name     = module.naming.resource_group.name_unique
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# Storage Account using Wrapper Module
# =============================================================================

module "storage_account" {
  source = "../../../shared-modules/resource-modules/storage-account"

  name                       = module.naming.storage_account.name_unique
  resource_group_name        = module.resource_group.name
  location                   = var.location
  account_tier               = var.storage_account_tier
  account_replication_type   = var.storage_replication_type
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
  tags                       = local.common_tags
}

# =============================================================================
# Blob Container using Wrapper Module
# =============================================================================

module "blob_container" {
  source = "../../../shared-modules/resource-modules/storage-container"

  name                  = var.container_name
  storage_account_id    = module.storage_account.resource_id
  container_access_type = var.container_access_type
}

# =============================================================================
# Application Insights for monitoring (optional)
# =============================================================================

module "application_insights" {
  count  = var.enable_application_insights ? 1 : 0
  source = "../../../shared-modules/resource-modules/application-insights"

  name                = module.naming.application_insights.name_unique
  resource_group_name = module.resource_group.name
  location            = var.location
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id != "" ? var.log_analytics_workspace_id : null
  tags                = local.common_tags
}

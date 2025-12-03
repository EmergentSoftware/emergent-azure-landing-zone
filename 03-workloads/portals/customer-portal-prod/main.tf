# =============================================================================
# Customer Portal Prod Workload - Static Website Storage
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

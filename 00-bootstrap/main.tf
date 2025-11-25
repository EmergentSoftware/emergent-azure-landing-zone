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

# Generate a random suffix for storage account name (must be globally unique)
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# =============================================================================
# Resource Group for Terraform State
# =============================================================================

resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.tags,
    {
      Purpose     = "Terraform State Storage"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  )
}

# =============================================================================
# Storage Account for Terraform State
# =============================================================================

resource "azurerm_storage_account" "tfstate" {
  name                     = "${var.storage_account_prefix}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication

  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  https_traffic_only_enabled      = true

  # Enable versioning and soft delete for protection
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = var.soft_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.soft_delete_retention_days
    }
  }

  tags = merge(
    var.tags,
    {
      Purpose     = "Terraform State Storage"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  )
}

# =============================================================================
# Blob Containers for Each Deployment Layer
# =============================================================================

resource "azurerm_storage_container" "foundation" {
  name                  = "tfstate-foundation"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "landing_zones" {
  name                  = "tfstate-landing-zones"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "workloads" {
  name                  = "tfstate-workloads"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Optional: Create additional containers for different environments
resource "azurerm_storage_container" "additional" {
  for_each              = toset(var.additional_containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# =============================================================================
# Example Workload: Customer Portal using Azure Static Web Apps
# This demonstrates deploying a portal application using Static Web Apps
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
  backend "azurerm" {
    # Backend configuration will be provided via backend config parameters
    # Use different state files per environment
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# =============================================================================
# Naming Module for Consistent Azure Resource Naming
# =============================================================================

module "naming" {
  source   = "../../../shared-modules/naming"
  location = var.location
  suffix   = [var.landing_zone, var.workload_name, var.environment]
}

# Generate random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
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
  source = "../../../shared-modules/resource-group"

  name     = module.naming.resource_group.name_unique
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# Static Web App using Wrapper Module
# =============================================================================

module "static_web_app" {
  source = "../../../shared-modules/static-web-app"

  name                    = module.naming.app_service.name_unique
  resource_group_name     = module.resource_group.name
  location                = var.location
  sku_tier                = var.static_web_app_sku_tier
  sku_size                = var.static_web_app_sku_size
  enable_managed_identity = var.enable_managed_identity
  tags                    = local.common_tags
}

# =============================================================================
# Application Insights for monitoring (optional)
# =============================================================================

module "application_insights" {
  count  = var.enable_application_insights ? 1 : 0
  source = "../../../shared-modules/application-insights"

  name                = module.naming.application_insights.name_unique
  resource_group_name = module.resource_group.name
  location            = var.location
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id != "" ? var.log_analytics_workspace_id : null
  tags                = local.common_tags
}

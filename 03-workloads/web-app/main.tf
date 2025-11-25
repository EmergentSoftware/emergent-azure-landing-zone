# =============================================================================
# Example Workload: Web Application using Azure Verified Modules
# This demonstrates deploying a compliant web app using AVM modules
# =============================================================================

terraform {
  required_version = ">= 1.3.0"
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
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Generate random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# =============================================================================
# Resource Group using Wrapper Module
# =============================================================================

module "resource_group" {
  source = "../../shared-modules/resource-group"

  name     = "rg-${var.workload_name}-${var.environment}-${var.location}"
  location = var.location

  tags = merge(
    var.tags,
    {
      Workload    = var.workload_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      DeployedBy  = "AVM"
    }
  )
}

# =============================================================================
# App Service Plan using Wrapper Module
# =============================================================================

module "app_service_plan" {
  source = "../../shared-modules/app-service-plan"

  name                = "asp-${var.workload_name}-${var.environment}-${random_string.suffix.result}"
  resource_group_name = module.resource_group.name
  location            = var.location
  os_type             = var.app_service_os_type
  sku_name            = var.app_service_sku_name

  tags = merge(
    var.tags,
    {
      Workload    = var.workload_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      DeployedBy  = "AVM"
    }
  )
}

# =============================================================================
# Web App using Wrapper Module
# =============================================================================

module "web_app" {
  source = "../../shared-modules/web-app"

  name                     = "app-${var.workload_name}-${var.environment}-${random_string.suffix.result}"
  resource_group_name      = module.resource_group.name
  location                 = var.location
  kind                     = var.app_service_os_type == "Linux" ? "app,linux" : "app"
  service_plan_resource_id = module.app_service_plan.resource_id
  https_only               = true

  site_config = {
    minimum_tls_version = "1.2"

    # CORS configuration if needed
    cors = var.enable_cors ? {
      allowed_origins     = var.cors_allowed_origins
      support_credentials = false
    } : null

    # Always on for production workloads
    always_on = var.environment == "prod" ? true : false

    # Health check path
    health_check_path = var.health_check_path
  }

  # Application settings
  app_settings = merge(
    var.app_settings,
    {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
      "ENVIRONMENT"              = var.environment
    }
  )

  # Enable managed identity
  managed_identities = {
    system_assigned = var.enable_managed_identity
  }

  # Diagnostic settings for compliance
  diagnostic_settings = var.log_analytics_workspace_id != "" ? {
    workspace = {
      name                           = "diag-${var.workload_name}"
      workspace_resource_id          = var.log_analytics_workspace_id
      log_analytics_destination_type = "Dedicated"
    }
  } : {}

  tags = merge(
    var.tags,
    {
      Workload    = var.workload_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      DeployedBy  = "AVM"
    }
  )

  depends_on = [module.app_service_plan]
}

# =============================================================================
# Optional: Application Insights using Wrapper Module
# =============================================================================

module "application_insights" {
  count  = var.enable_application_insights ? 1 : 0
  source = "../../shared-modules/application-insights"

  name                = "appi-${var.workload_name}-${var.environment}-${random_string.suffix.result}"
  resource_group_name = module.resource_group.name
  location            = var.location
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id

  tags = merge(
    var.tags,
    {
      Workload    = var.workload_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      DeployedBy  = "AVM"
    }
  )
}

# Connect Application Insights to Web App
resource "azurerm_app_service_site_extension" "app_insights" {
  count = var.enable_application_insights ? 1 : 0

  site_id = module.web_app.resource_id
}

# =============================================================================
# Application Insights Wrapper Module
# Wraps Azure/avm-res-insights-component/azurerm
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

module "application_insights" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = "~> 0.1"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = var.application_type
  workspace_id        = var.workspace_id
  tags                = var.tags
}

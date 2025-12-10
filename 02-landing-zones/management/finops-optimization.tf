# =============================================================================
# Azure Optimization Engine (AOE) Deployment
# Deploys the Microsoft FinOps Toolkit Optimization Engine
# https://aka.ms/AzureOptimizationEngine
# =============================================================================

# NOTE: The Azure Optimization Engine is best deployed using the official PowerShell script
# from the Microsoft FinOps Toolkit. This file creates the placeholder resource group
# and documents the deployment process.

locals {
  aoe_enabled             = var.enable_azure_optimization_engine
  aoe_resource_group_name = "acme-rg-management-finops-aoe-prod-${var.location}"

  aoe_tags = merge(
    local.common_tags,
    {
      Purpose    = "FinOps - Cost Optimization"
      Component  = "Azure Optimization Engine"
      Toolkit    = "Microsoft FinOps Toolkit"
      CostCenter = "Infrastructure"
    }
  )
}

# Random suffix for globally unique resource names
resource "random_string" "aoe_suffix" {
  count   = local.aoe_enabled ? 1 : 0
  length  = 6
  special = false
  upper   = false
}

# Resource Group for Azure Optimization Engine
resource "azurerm_resource_group" "aoe" {
  count    = local.aoe_enabled ? 1 : 0
  name     = local.aoe_resource_group_name
  location = var.location
  tags     = local.aoe_tags
}

# Output deployment instructions and details
output "azure_optimization_engine" {
  description = "Azure Optimization Engine deployment details and instructions"
  value = local.aoe_enabled ? {
    enabled             = true
    resource_group_name = azurerm_resource_group.aoe[0].name
    location            = var.location
    subscription_id     = var.subscription_id

    deployment_instructions = <<-EOT

      ========================================
      Azure Optimization Engine Deployment
      ========================================

      The resource group has been created. To deploy AOE, run:

      1. Clone the FinOps Toolkit:
         git clone https://github.com/microsoft/finops-toolkit.git
         cd finops-toolkit/src/optimization-engine

      2. Run the deployment script:
         .\Deploy-AzureOptimizationEngine.ps1

      3. When prompted, use these values:
         - Subscription: ${var.subscription_id}
         - Resource Group: ${azurerm_resource_group.aoe[0].name}
         - Region: ${var.location}
         - SQL Auth: Managed Identity
         - Log Analytics: ${var.log_analytics_workspace_name != "" ? "Reuse existing: ${var.log_analytics_workspace_name}" : "Create new"}

      4. After deployment:
         - Wait 24-48 hours for first recommendations
         - View recommendations in Azure Portal or SQL Database
         - Configure alerts via existing Action Groups

      Documentation: https://aka.ms/AzureOptimizationEngine/deployment

    EOT
  } : {
    enabled = false
    message = "Azure Optimization Engine is disabled. Set enable_azure_optimization_engine = true in terraform.tfvars to enable."

    enable_instructions = <<-EOT

      To enable Azure Optimization Engine:

      1. Add to terraform.tfvars:
         enable_azure_optimization_engine = true
         aoe_admin_upn                   = "your-email@domain.com"
         aoe_admin_object_id             = "your-aad-object-id"

      2. Run terraform apply

      3. Follow the deployment instructions in the output

    EOT
  }
}

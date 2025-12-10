# =============================================================================
# FinOps Hub Deployment (Optional - Advanced Analytics)
# Microsoft FinOps Toolkit - FinOps Hub
# https://aka.ms/finops/toolkit
# =============================================================================

# NOTE: FinOps Hub provides advanced cost analytics and should only be deployed
# if Azure Cost Management and Azure Optimization Engine reporting is insufficient.
# This is typically used for large enterprises with complex cost allocation needs.

locals {
  finops_hub_enabled      = var.enable_finops_hub
  hub_resource_group_name = "acme-rg-management-finops-hub-prod-${var.location}"
  hub_name                = local.finops_hub_enabled ? "acme-finopshub-${random_string.hub_suffix[0].result}" : ""

  hub_tags = merge(
    local.common_tags,
    {
      Purpose    = "FinOps - Advanced Analytics"
      Component  = "FinOps Hub"
      Toolkit    = "Microsoft FinOps Toolkit"
      CostCenter = "Infrastructure"
    }
  )
}

# Random suffix for globally unique resource names
resource "random_string" "hub_suffix" {
  count   = local.finops_hub_enabled ? 1 : 0
  length  = 8
  special = false
  upper   = false
}

# Resource Group for FinOps Hub
resource "azurerm_resource_group" "finops_hub" {
  count    = local.finops_hub_enabled ? 1 : 0
  name     = local.hub_resource_group_name
  location = var.location
  tags     = local.hub_tags
}

# Output deployment instructions
output "finops_hub" {
  description = "FinOps Hub deployment details and instructions"
  value = local.finops_hub_enabled ? {
    enabled             = true
    resource_group_name = azurerm_resource_group.finops_hub[0].name
    location            = var.location
    subscription_id     = var.subscription_id

    deployment_instructions = <<-EOT
      
      ========================================
      FinOps Hub Deployment
      ========================================
      
      The resource group has been created. To deploy FinOps Hub:
      
      Option 1: Azure Portal (Easiest)
      ---------------------------------
      1. Go to: https://aka.ms/finops/hub/deploy
      2. Select subscription: {var.subscription_id}
      3. Select resource group: {azurerm_resource_group.finops_hub[0].name}
      4. Choose data platform: Microsoft Fabric (recommended for demo/cost)
      5. Follow the wizard
      
      Option 2: PowerShell
      --------------------
      1. Install FinOps toolkit module:
         Install-Module -Name FinOpsToolkit
      
      2. Deploy FinOps Hub:
         Deploy-FinOpsHub -Name {local.hub_name} -ResourceGroupName {azurerm_resource_group.finops_hub[0].name} -Location {var.location}
      
      3. Configure cost exports in Azure Cost Management
      
      Documentation: https://aka.ms/finops/hub
      
      NOTE: FinOps Hub is optional. Most organizations can start with:
      - Azure Cost Management (built-in)
      - Azure Optimization Engine (deployed separately)
      - Power BI reports from Cost Management connector
      
    EOT
    } : {
    enabled = false
    message = "FinOps Hub is disabled. This is optional - only enable for advanced analytics needs."

    enable_instructions = <<-EOT
      
      To enable FinOps Hub (Optional - Advanced Feature):
      
      1. Add to terraform.tfvars:
         enable_finops_hub = true
      
      2. Run terraform apply
      
      3. Follow the deployment instructions in the output
      
      NOTE: FinOps Hub adds ~$100+/month in costs. Consider if you need:
      - Advanced cost analytics beyond Azure Cost Management
      - Custom Power BI dashboards
      - Integration with Microsoft Fabric
      
      If unsure, start with Azure Optimization Engine only.
      
    EOT
  }
}

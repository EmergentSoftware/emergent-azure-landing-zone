# =============================================================================
# FinOps Tagging Policies
# Enforce tagging for cost allocation and governance
# =============================================================================

# Data source for Workloads management group
data "azurerm_management_group" "workloads" {
  name = "acme-workloads"
}

# Policy Definition: Require specific tags on resource groups
resource "azurerm_policy_definition" "require_cost_tags" {
  name                = "acme-require-cost-allocation-tags"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "ACME - Require cost allocation tags on resource groups"
  description         = "Enforces required tags for FinOps cost allocation: CostCenter, Environment, Owner, Project"
  management_group_id = data.azurerm_management_group.workloads.id

  metadata = jsonencode({
    category = "FinOps"
    version  = "1.0.0"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Resources/subscriptions/resourceGroups"
        },
        {
          anyOf = [
            {
              field  = "tags['CostCenter']"
              exists = "false"
            },
            {
              field  = "tags['Environment']"
              exists = "false"
            },
            {
              field  = "tags['Owner']"
              exists = "false"
            },
            {
              field  = "tags['Project']"
              exists = "false"
            }
          ]
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Assignment: Assign to Workloads management group
resource "azurerm_management_group_policy_assignment" "require_cost_tags" {
  name                 = "acme-require-cost-tags"
  display_name         = "ACME - Require Cost Allocation Tags"
  description          = "Requires CostCenter, Environment, Owner, and Project tags on all resource groups for FinOps cost allocation"
  management_group_id  = data.azurerm_management_group.workloads.id
  policy_definition_id = azurerm_policy_definition.require_cost_tags.id

  metadata = jsonencode({
    category   = "FinOps"
    assignedBy = "Terraform - Azure Landing Zone"
  })

  non_compliance_message {
    content = "Resource groups must have CostCenter, Environment, Owner, and Project tags for cost allocation tracking."
  }
}

# Policy Definition: Inherit tags from resource group
resource "azurerm_policy_definition" "inherit_cost_center_tag" {
  name                = "acme-inherit-costcenter-tag-from-rg"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "ACME - Inherit CostCenter tag from resource group"
  description         = "Automatically inherits CostCenter tag from parent resource group if not present"
  management_group_id = data.azurerm_management_group.workloads.id

  metadata = jsonencode({
    category = "FinOps"
    version  = "1.0.0"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "tags['CostCenter']"
          exists = "false"
        },
        {
          value     = "[resourceGroup().tags['CostCenter']]"
          notEquals = ""
        }
      ]
    }
    then = {
      effect = "modify"
      details = {
        roleDefinitionIds = [
          "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c" # Contributor
        ]
        operations = [
          {
            operation = "add"
            field     = "tags['CostCenter']"
            value     = "[resourceGroup().tags['CostCenter']]"
          }
        ]
      }
    }
  })
}

# Assign CostCenter tag inheritance
resource "azurerm_management_group_policy_assignment" "inherit_costcenter" {
  name                 = "acme-inherit-costcenter"
  display_name         = "ACME - Inherit CostCenter Tag"
  description          = "Automatically inherits CostCenter tag from resource group"
  management_group_id  = data.azurerm_management_group.workloads.id
  policy_definition_id = azurerm_policy_definition.inherit_cost_center_tag.id

  identity {
    type = "SystemAssigned"
  }

  location = var.default_location

  metadata = jsonencode({
    category   = "FinOps"
    assignedBy = "Terraform - Azure Landing Zone"
  })
}

# Role assignment for tag modification
resource "azurerm_role_assignment" "finops_tagging_contributor" {
  scope                = data.azurerm_management_group.workloads.id
  role_definition_name = "Tag Contributor"
  principal_id         = azurerm_management_group_policy_assignment.inherit_costcenter.identity[0].principal_id

  depends_on = [
    azurerm_management_group_policy_assignment.inherit_costcenter
  ]
}

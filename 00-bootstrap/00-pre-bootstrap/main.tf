# =============================================================================
# Pre-Bootstrap: Azure Subscription Creation
# This configuration creates Azure subscriptions required for the landing zone
# Requires Azure EA or MCA billing account enrollment
# =============================================================================

terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.4"
    }
  }

  # Pre-bootstrap uses local state - no remote backend yet
}

provider "azurerm" {
  features {}
  subscription_id = var.management_subscription_id
  tenant_id       = var.tenant_id
}

provider "azapi" {
  subscription_id = var.management_subscription_id
  tenant_id       = var.tenant_id
}

# Get current Azure context
data "azurerm_client_config" "current" {}

# =============================================================================
# Create Management Subscription (for Bootstrap)
# =============================================================================

resource "azapi_resource" "management_subscription" {
  count     = var.create_management_subscription && var.billing_model != "CSP" ? 1 : 0
  type      = "Microsoft.Subscription/aliases@2021-10-01"
  name      = var.management_subscription_alias
  parent_id = "/providers/Microsoft.Subscription"

  body = {
    properties = {
      displayName  = var.management_subscription_name
      workload     = "Production"
      billingScope = var.billing_scope_id
    }
  }

  response_export_values = ["properties.subscriptionId"]
}

# CSP: Management Subscription
resource "azapi_resource" "management_subscription_csp" {
  count     = var.create_management_subscription && var.billing_model == "CSP" ? 1 : 0
  type      = "Microsoft.Subscription/aliases@2021-10-01"
  name      = var.management_subscription_alias
  parent_id = "/providers/Microsoft.Subscription"

  body = {
    properties = {
      displayName = var.management_subscription_name
      workload    = "Production"
      additionalProperties = {
        subscriptionTenantId = var.csp_customer_tenant_id
        subscriptionOwnerId  = data.azurerm_client_config.current.object_id
      }
    }
  }

  response_export_values = ["properties.subscriptionId"]
}

# =============================================================================
# Create Corp Landing Zone Subscriptions
# =============================================================================

resource "azapi_resource" "corp_subscriptions" {
  for_each  = var.billing_model != "CSP" ? var.corp_subscriptions : {}
  type      = "Microsoft.Subscription/aliases@2021-10-01"
  name      = each.value.alias
  parent_id = "/providers/Microsoft.Subscription"

  body = {
    properties = {
      displayName  = each.value.display_name
      workload     = each.value.workload
      billingScope = var.billing_scope_id
    }
  }

  response_export_values = ["properties.subscriptionId"]
}

# CSP: Corp Subscriptions
resource "azapi_resource" "corp_subscriptions_csp" {
  for_each  = var.billing_model == "CSP" ? var.corp_subscriptions : {}
  type      = "Microsoft.Subscription/aliases@2021-10-01"
  name      = each.value.alias
  parent_id = "/providers/Microsoft.Subscription"

  body = {
    properties = {
      displayName = each.value.display_name
      workload    = each.value.workload
      additionalProperties = {
        subscriptionTenantId = var.csp_customer_tenant_id
        subscriptionOwnerId  = data.azurerm_client_config.current.object_id
      }
    }
  }

  response_export_values = ["properties.subscriptionId"]
}

# =============================================================================
# Create Online Landing Zone Subscriptions
# =============================================================================

resource "azapi_resource" "online_subscriptions" {
  for_each  = var.billing_model != "CSP" ? var.online_subscriptions : {}
  type      = "Microsoft.Subscription/aliases@2021-10-01"
  name      = each.value.alias
  parent_id = "/providers/Microsoft.Subscription"

  body = {
    properties = {
      displayName  = each.value.display_name
      workload     = each.value.workload
      billingScope = var.billing_scope_id
    }
  }

  response_export_values = ["properties.subscriptionId"]
}

# CSP: Online Subscriptions
resource "azapi_resource" "online_subscriptions_csp" {
  for_each  = var.billing_model == "CSP" ? var.online_subscriptions : {}
  type      = "Microsoft.Subscription/aliases@2021-10-01"
  name      = each.value.alias
  parent_id = "/providers/Microsoft.Subscription"

  body = {
    properties = {
      displayName = each.value.display_name
      workload    = each.value.workload
      additionalProperties = {
        subscriptionTenantId = var.csp_customer_tenant_id
        subscriptionOwnerId  = data.azurerm_client_config.current.object_id
      }
    }
  }

  response_export_values = ["properties.subscriptionId"]
}

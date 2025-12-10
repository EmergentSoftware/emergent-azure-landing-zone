# =============================================================================
# Azure Consumption Budget Module
# =============================================================================

terraform {
  required_version = "~> 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_consumption_budget_subscription" "this" {
  name            = var.name
  subscription_id = "/subscriptions/${var.subscription_id}"

  amount     = var.amount
  time_grain = var.time_grain

  time_period {
    start_date = var.start_date
    end_date   = var.end_date
  }

  # Actual spend alert - triggers when actual spend exceeds threshold
  dynamic "notification" {
    for_each = var.actual_threshold != null ? [1] : []
    content {
      enabled        = true
      threshold      = var.actual_threshold
      operator       = "GreaterThan"
      threshold_type = "Actual"

      contact_emails = var.contact_emails
      contact_roles  = var.contact_roles
      contact_groups = var.contact_groups
    }
  }

  # Forecasted spend alert - triggers when forecast exceeds threshold
  dynamic "notification" {
    for_each = var.forecasted_threshold != null ? [1] : []
    content {
      enabled        = true
      threshold      = var.forecasted_threshold
      operator       = "GreaterThan"
      threshold_type = "Forecasted"

      contact_emails = var.contact_emails
      contact_roles  = var.contact_roles
      contact_groups = var.contact_groups
    }
  }

  # Optional filter for specific resource groups
  dynamic "filter" {
    for_each = length(var.resource_group_filter) > 0 ? [1] : []
    content {
      dimension {
        name   = "ResourceGroupName"
        values = var.resource_group_filter
      }
    }
  }
}

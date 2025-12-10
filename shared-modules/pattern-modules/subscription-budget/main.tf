# =============================================================================
# Subscription Budget Pattern Module
# Encapsulates action group and consumption budget for subscription-level budgets
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

# -----------------------------------------------------------------------------
# Action Group (optional - only created if enable_action_group is true)
# -----------------------------------------------------------------------------

module "action_group" {
  count  = var.enable_action_group ? 1 : 0
  source = "../../resource-modules/action-group"

  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name
  enabled             = var.action_group_enabled

  email_receivers          = var.email_receivers
  sms_receivers            = var.sms_receivers
  webhook_receivers        = var.webhook_receivers
  azure_app_push_receivers = var.azure_app_push_receivers

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Consumption Budget
# -----------------------------------------------------------------------------

module "budget" {
  source = "../../resource-modules/consumption-budget"

  name            = var.budget_name
  subscription_id = var.subscription_id
  amount          = var.budget_amount
  time_grain      = var.time_grain
  start_date      = var.start_date
  end_date        = var.end_date

  actual_threshold     = var.actual_threshold
  forecasted_threshold = var.forecasted_threshold

  contact_emails = var.contact_emails
  contact_roles  = var.contact_roles

  # Combine externally provided action groups with the one created by this module
  contact_groups = concat(
    var.additional_action_group_ids,
    var.enable_action_group ? [module.action_group[0].id] : []
  )

  resource_group_filter = var.resource_group_filter
}

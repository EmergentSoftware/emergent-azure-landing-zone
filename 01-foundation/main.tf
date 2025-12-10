# =============================================================================
# Azure Landing Zone Demo using Azure Verified Modules (AVM)
# This configuration deploys a CAF-aligned management group hierarchy
# and applies baseline governance policies
# =============================================================================

# Get current Azure context
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

# =============================================================================
# Deploy Management Groups and Policies using ALZ Wrapper Module
# The wrapper module insulates this configuration from changes to the
# upstream Azure Verified Module (AVM)
# =============================================================================

module "alz" {
  source = "./modules/alz-wrapper"

  # Parent management group - use tenant root group
  parent_resource_id = data.azurerm_client_config.current.tenant_id

  # Architecture definition - uses custom ACME architecture with acme-alz prefix
  architecture_name = "acme-alz"

  # Default location for policy managed identities
  location = var.default_location

  # Configure hierarchy settings with ACME prefix
  management_group_hierarchy_settings = {
    default_management_group_name            = "acme-workloads"
    require_authorization_for_group_creation = true
  }

  # Enable telemetry
  enable_telemetry = var.enable_telemetry
}

# =============================================================================
# Cost Management Monitoring Resources
# Resource group for cost management resources
# =============================================================================

# Resource group for cost management monitoring resources
module "cost_monitoring_resource_group" {
  source = "../shared-modules/resource-modules/resource-group"

  name     = "rg-cost-monitoring-${var.default_location}"
  location = var.default_location

  tags = merge(
    var.tags,
    {
      Purpose     = "Cost Management"
      ManagedBy   = "Terraform"
      Environment = "Production"
    }
  )
}

# =============================================================================
# Subscription Budgets with Integrated Action Groups
# Using pattern module for simplified configuration
# =============================================================================

# Platform Subscriptions - Actual alerts only (Infrastructure cost center)
module "budget_management" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-management-monthly"
  subscription_id = var.management_subscription_id
  budget_amount   = var.budget_amount_management
  start_date      = var.budget_start_date

  # Platform: Actual alerts only at 120%
  actual_threshold     = 120
  forecasted_threshold = null

  # Direct email notifications
  contact_emails = var.budget_contact_emails

  # Create dedicated action group for Infrastructure cost center
  enable_action_group     = true
  resource_group_name     = module.cost_monitoring_resource_group.name
  action_group_name       = "ag-cost-alerts-infrastructure"
  action_group_short_name = "costinfra"

  email_receivers = [
    {
      name                    = "Finance-Team"
      email_address           = var.budget_contact_emails[0]
      use_common_alert_schema = true
    },
    {
      name                    = "Platform-Team"
      email_address           = var.budget_contact_emails[1]
      use_common_alert_schema = true
    }
  ]

  tags = merge(
    var.tags,
    {
      CostCenter  = "Infrastructure"
      Environment = "Platform"
      ManagedBy   = "Terraform"
    }
  )
}

module "budget_connectivity" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-connectivity-monthly"
  subscription_id = var.connectivity_subscription_id
  budget_amount   = var.budget_amount_connectivity
  start_date      = var.budget_start_date

  # Platform: Actual alerts only at 120%
  actual_threshold     = 120
  forecasted_threshold = null

  contact_emails = var.budget_contact_emails

  # Reuse Infrastructure action group (no dedicated action group for this budget)
  enable_action_group         = false
  additional_action_group_ids = [module.budget_management.action_group_id]

  tags = merge(
    var.tags,
    {
      CostCenter  = "Infrastructure"
      Environment = "Platform"
      ManagedBy   = "Terraform"
    }
  )
}

module "budget_identity" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-identity-monthly"
  subscription_id = var.identity_subscription_id
  budget_amount   = var.budget_amount_identity
  start_date      = var.budget_start_date

  # Platform: Actual alerts only at 120%
  actual_threshold     = 120
  forecasted_threshold = null

  contact_emails = var.budget_contact_emails

  # Reuse Infrastructure action group
  enable_action_group         = false
  additional_action_group_ids = [module.budget_management.action_group_id]

  tags = merge(
    var.tags,
    {
      CostCenter  = "Infrastructure"
      Environment = "Platform"
      ManagedBy   = "Terraform"
    }
  )
}

# Workload Subscriptions - Dev environments: Actual only (IT-Operations cost center)
module "budget_portals_admin_dev" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-portals-admin-dev-monthly"
  subscription_id = var.portals_admin_dev_subscription_id
  budget_amount   = var.budget_amount_portals_admin_dev
  start_date      = var.budget_start_date

  # Dev: Actual alerts only at 120%
  actual_threshold     = 120
  forecasted_threshold = null

  contact_emails = var.budget_contact_emails

  # Create dedicated action group for IT-Operations cost center
  enable_action_group     = true
  resource_group_name     = module.cost_monitoring_resource_group.name
  action_group_name       = "ag-cost-alerts-it-operations"
  action_group_short_name = "costitops"

  email_receivers = [
    {
      name                    = "Finance-Team"
      email_address           = var.budget_contact_emails[0]
      use_common_alert_schema = true
    },
    {
      name                    = "IT-Operations"
      email_address           = var.budget_contact_emails[1]
      use_common_alert_schema = true
    }
  ]

  tags = merge(
    var.tags,
    {
      CostCenter  = "IT-Operations"
      Environment = "Development"
      ManagedBy   = "Terraform"
    }
  )
}

# Workload Subscriptions - Dev environments: Actual only (Marketing cost center)
module "budget_portals_customer_dev" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-portals-customer-dev-monthly"
  subscription_id = var.portals_customer_dev_subscription_id
  budget_amount   = var.budget_amount_portals_customer_dev
  start_date      = var.budget_start_date

  # Dev: Actual alerts only at 120%
  actual_threshold     = 120
  forecasted_threshold = null

  contact_emails = var.budget_contact_emails

  # Create dedicated action group for Marketing cost center
  enable_action_group     = true
  resource_group_name     = module.cost_monitoring_resource_group.name
  action_group_name       = "ag-cost-alerts-marketing"
  action_group_short_name = "costmkt"

  email_receivers = [
    {
      name                    = "Finance-Team"
      email_address           = var.budget_contact_emails[0]
      use_common_alert_schema = true
    },
    {
      name                    = "Marketing-Team"
      email_address           = var.budget_contact_emails[1]
      use_common_alert_schema = true
    }
  ]

  tags = merge(
    var.tags,
    {
      CostCenter  = "Marketing"
      Environment = "Development"
      ManagedBy   = "Terraform"
    }
  )
}

# Workload Subscriptions - Production: Both actual AND forecasted alerts (IT-Operations)
module "budget_portals_admin_prod" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-portals-admin-prod-monthly"
  subscription_id = var.portals_admin_prod_subscription_id
  budget_amount   = var.budget_amount_portals_admin_prod
  start_date      = var.budget_start_date

  # Production: Both actual (120%) and forecasted (130%) alerts
  actual_threshold     = 120
  forecasted_threshold = 130

  contact_emails = var.budget_contact_emails

  # Reuse IT-Operations action group
  enable_action_group         = false
  additional_action_group_ids = [module.budget_portals_admin_dev.action_group_id]

  tags = merge(
    var.tags,
    {
      CostCenter  = "IT-Operations"
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  )
}

# Workload Subscriptions - Production: Both actual AND forecasted alerts (Marketing)
module "budget_portals_customer_prod" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-portals-customer-prod-monthly"
  subscription_id = var.portals_customer_prod_subscription_id
  budget_amount   = var.budget_amount_portals_customer_prod
  start_date      = var.budget_start_date

  # Production: Both actual (120%) and forecasted (130%) alerts
  actual_threshold     = 120
  forecasted_threshold = 130

  contact_emails = var.budget_contact_emails

  # Reuse Marketing action group
  enable_action_group         = false
  additional_action_group_ids = [module.budget_portals_customer_dev.action_group_id]

  tags = merge(
    var.tags,
    {
      CostCenter  = "Marketing"
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  )
}

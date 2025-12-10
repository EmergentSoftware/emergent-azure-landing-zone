# =============================================================================
# Cost Anomaly Detection Alerts
# Uses Azure Cost Management's built-in anomaly detection
# =============================================================================

# Data source for existing action groups (created in main.tf)
data "azurerm_monitor_action_group" "infrastructure" {
  name                = "ag-cost-alerts-infrastructure"
  resource_group_name = module.cost_monitoring_resource_group.name

  depends_on = [
    module.budget_management
  ]
}

data "azurerm_monitor_action_group" "it_operations" {
  name                = "ag-cost-alerts-it-operations"
  resource_group_name = module.cost_monitoring_resource_group.name

  depends_on = [
    module.budget_portals_admin_dev
  ]
}

data "azurerm_monitor_action_group" "marketing" {
  name                = "ag-cost-alerts-marketing"
  resource_group_name = module.cost_monitoring_resource_group.name

  depends_on = [
    module.budget_portals_customer_dev
  ]
}

# Cost Anomaly Alert for Management subscription (Infrastructure)
resource "azurerm_cost_anomaly_alert" "management" {
  name            = "acme-anomaly-management-infrastructure"
  display_name    = "ACME Cost Anomaly - Management Infrastructure"
  subscription_id = "/subscriptions/${var.subscription_id}"
  email_subject   = "Cost Anomaly Detected - Management Subscription"

  email_addresses = [
    data.azurerm_monitor_action_group.infrastructure.email_receiver[0].email_address
  ]

  message = "Unusual spending detected in Management subscription. Review Cost Management for details."
}

# Cost Anomaly Alert for Connectivity subscription (Infrastructure)
resource "azurerm_cost_anomaly_alert" "connectivity" {
  name            = "acme-anomaly-connectivity-infrastructure"
  display_name    = "ACME Cost Anomaly - Connectivity Infrastructure"
  subscription_id = "/subscriptions/${var.connectivity_subscription_id}"
  email_subject   = "Cost Anomaly Detected - Connectivity Subscription"

  email_addresses = [
    data.azurerm_monitor_action_group.infrastructure.email_receiver[0].email_address
  ]

  message = "Unusual spending detected in Connectivity subscription. Review Cost Management for details."
}

# Cost Anomaly Alert for Admin Portal Dev (IT Operations)
resource "azurerm_cost_anomaly_alert" "portals_admin_dev" {
  name            = "acme-anomaly-portals-admin-dev"
  display_name    = "ACME Cost Anomaly - Admin Portal Dev"
  subscription_id = "/subscriptions/${var.portals_admin_dev_subscription_id}"
  email_subject   = "Cost Anomaly Detected - Admin Portal Dev"

  email_addresses = [
    data.azurerm_monitor_action_group.it_operations.email_receiver[0].email_address
  ]

  message = "Unusual spending detected in Admin Portal Dev subscription. Review Cost Management for details."
}

# Cost Anomaly Alert for Admin Portal Prod (IT Operations)
resource "azurerm_cost_anomaly_alert" "portals_admin_prod" {
  name            = "acme-anomaly-portals-admin-prod"
  display_name    = "ACME Cost Anomaly - Admin Portal Prod"
  subscription_id = "/subscriptions/${var.portals_admin_prod_subscription_id}"
  email_subject   = "Cost Anomaly Detected - Admin Portal Prod"

  email_addresses = [
    data.azurerm_monitor_action_group.it_operations.email_receiver[0].email_address
  ]

  message = "Unusual spending detected in Admin Portal Prod subscription. Review Cost Management for details."
}

# Cost Anomaly Alert for Customer Portal Dev (Marketing)
resource "azurerm_cost_anomaly_alert" "portals_customer_dev" {
  name            = "acme-anomaly-portals-customer-dev"
  display_name    = "ACME Cost Anomaly - Customer Portal Dev"
  subscription_id = "/subscriptions/${var.portals_customer_dev_subscription_id}"
  email_subject   = "Cost Anomaly Detected - Customer Portal Dev"

  email_addresses = [
    data.azurerm_monitor_action_group.marketing.email_receiver[0].email_address
  ]

  message = "Unusual spending detected in Customer Portal Dev subscription. Review Cost Management for details."
}

# Cost Anomaly Alert for Customer Portal Prod (Marketing)
resource "azurerm_cost_anomaly_alert" "portals_customer_prod" {
  name            = "acme-anomaly-portals-customer-prod"
  display_name    = "ACME Cost Anomaly - Customer Portal Prod"
  subscription_id = "/subscriptions/${var.portals_customer_prod_subscription_id}"
  email_subject   = "Cost Anomaly Detected - Customer Portal Prod"

  email_addresses = [
    data.azurerm_monitor_action_group.marketing.email_receiver[0].email_address
  ]

  message = "Unusual spending detected in Customer Portal Prod subscription. Review Cost Management for details."
}

# Output anomaly alert details
output "cost_anomaly_detection" {
  description = "Cost Anomaly Detection Alerts"
  value = {
    enabled = true

    alerts = {
      management = {
        id           = azurerm_cost_anomaly_alert.management.id
        display_name = azurerm_cost_anomaly_alert.management.display_name
      }
      connectivity = {
        id           = azurerm_cost_anomaly_alert.connectivity.id
        display_name = azurerm_cost_anomaly_alert.connectivity.display_name
      }
      portals_admin_dev = {
        id           = azurerm_cost_anomaly_alert.portals_admin_dev.id
        display_name = azurerm_cost_anomaly_alert.portals_admin_dev.display_name
      }
      portals_admin_prod = {
        id           = azurerm_cost_anomaly_alert.portals_admin_prod.id
        display_name = azurerm_cost_anomaly_alert.portals_admin_prod.display_name
      }
      portals_customer_dev = {
        id           = azurerm_cost_anomaly_alert.portals_customer_dev.id
        display_name = azurerm_cost_anomaly_alert.portals_customer_dev.display_name
      }
      portals_customer_prod = {
        id           = azurerm_cost_anomaly_alert.portals_customer_prod.id
        display_name = azurerm_cost_anomaly_alert.portals_customer_prod.display_name
      }
    }

    configuration = {
      sensitivity         = "Automatic AI-based detection"
      notification_method = "Email via action groups"
      coverage            = "All 6 subscriptions"
    }
  }
}

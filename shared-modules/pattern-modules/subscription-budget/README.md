# Subscription Budget Pattern Module

## Overview

This pattern module encapsulates both Azure Monitor Action Groups and Azure Consumption Budgets to provide a complete subscription-level budget monitoring solution with integrated alerting.

## Features

- **Integrated Action Group**: Optionally creates and manages an action group dedicated to the budget
- **Flexible Notifications**: Supports email, SMS, webhook, and Azure App push notifications
- **Multiple Alert Channels**: Can notify through direct email and/or action groups
- **Configurable Thresholds**: Separate thresholds for actual and forecasted spend
- **Production Ready**: Follows Azure best practices and governance patterns

## Usage

### Basic Usage (with Action Group)

```hcl
module "budget_management" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  # Budget configuration
  budget_name     = "budget-management-monthly"
  subscription_id = "1302f5fd-f3b5-4eda-909c-e3ae2dfee3d6"
  budget_amount   = 100
  start_date      = "2025-01-01T00:00:00Z"

  # Alert thresholds
  actual_threshold     = 120  # Alert at 120% of budget
  forecasted_threshold = null # No forecast alerts

  # Direct email notifications
  contact_emails = ["finance@example.com"]
  contact_roles  = ["Owner", "Contributor"]

  # Action group configuration
  enable_action_group      = true
  resource_group_name      = "rg-cost-monitoring-eastus"
  action_group_name        = "ag-cost-alerts-infrastructure"
  action_group_short_name  = "costinfra"

  email_receivers = [
    {
      name                    = "Finance-Team"
      email_address           = "finance@example.com"
      use_common_alert_schema = true
    },
    {
      name                    = "Platform-Team"
      email_address           = "platform@example.com"
      use_common_alert_schema = true
    }
  ]

  tags = {
    Environment = "Platform"
    CostCenter  = "Infrastructure"
    ManagedBy   = "Terraform"
  }
}
```

### Production Workload (with Forecast Alerts)

```hcl
module "budget_prod_app" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-prod-app-monthly"
  subscription_id = "95d02110-a8d8-4ca3-89f1-45c71b0db69e"
  budget_amount   = 500
  start_date      = "2025-01-01T00:00:00Z"

  # Production gets both actual and forecast alerts
  actual_threshold     = 120  # Alert at 120% actual
  forecasted_threshold = 130  # Alert at 130% forecast

  enable_action_group      = true
  resource_group_name      = "rg-cost-monitoring-eastus"
  action_group_name        = "ag-cost-alerts-production"
  action_group_short_name  = "costprod"

  email_receivers = [
    {
      name          = "Finance"
      email_address = "finance@example.com"
    },
    {
      name          = "DevOps"
      email_address = "devops@example.com"
    }
  ]

  # Add SMS for critical production alerts
  sms_receivers = [
    {
      name         = "On-Call-Engineer"
      country_code = "1"
      phone_number = "5551234567"
    }
  ]

  tags = {
    Environment = "Production"
    CostCenter  = "Engineering"
    Critical    = "true"
  }
}
```

### Without Action Group (Simple Budget)

```hcl
module "budget_dev" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-dev-monthly"
  subscription_id = "588aa873-3aee-4530-8ca4-9d4db96e25d8"
  budget_amount   = 50
  start_date      = "2025-01-01T00:00:00Z"

  actual_threshold = 120

  # Only use direct email notifications (no action group)
  enable_action_group = false
  contact_emails      = ["team@example.com"]

  tags = {
    Environment = "Development"
  }
}
```

### Using External Action Groups

```hcl
module "budget_with_shared_action_group" {
  source = "../shared-modules/pattern-modules/subscription-budget"

  budget_name     = "budget-shared-services-monthly"
  subscription_id = "c82e0943-9ea6-45a1-bcba-1f651cd1c79b"
  budget_amount   = 200
  start_date      = "2025-01-01T00:00:00Z"

  actual_threshold = 120

  # Don't create action group, use existing one
  enable_action_group = false

  # Reference existing action group(s)
  additional_action_group_ids = [
    azurerm_monitor_action_group.shared.id
  ]

  contact_emails = ["finance@example.com"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.9 |
| azurerm | ~> 4.0 |

## Providers

This module uses the following resource modules:
- `../../resource-modules/action-group`
- `../../resource-modules/consumption-budget`

## Resources Created

When `enable_action_group = true`:
- 1 Azure Monitor Action Group
- 1 Azure Consumption Budget (with action group notification)

When `enable_action_group = false`:
- 1 Azure Consumption Budget (with direct email/role notifications only)

## Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| `budget_name` | The name of the consumption budget | `string` |
| `subscription_id` | The ID of the subscription to apply the budget to | `string` |
| `budget_amount` | The total amount for the budget (in USD) | `number` |
| `start_date` | The start date for the budget in RFC3339 format | `string` |

### Budget Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `time_grain` | The time grain (Monthly, Quarterly, Annually) | `string` | `"Monthly"` |
| `end_date` | The end date for the budget (null for no end) | `string` | `null` |
| `actual_threshold` | Threshold percentage for actual spend alerts | `number` | `120` |
| `forecasted_threshold` | Threshold percentage for forecasted spend alerts | `number` | `null` |
| `contact_emails` | List of email addresses to notify | `list(string)` | `[]` |
| `contact_roles` | List of Azure RBAC roles to notify | `list(string)` | `["Owner", "Contributor"]` |
| `resource_group_filter` | Optional list of resource group names to filter scope | `list(string)` | `[]` |

### Action Group Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_action_group` | Whether to create an action group | `bool` | `true` |
| `resource_group_name` | Resource group for the action group | `string` | `null` |
| `action_group_name` | Name of the action group | `string` | `null` |
| `action_group_short_name` | Short name (max 12 chars) | `string` | `null` |
| `action_group_enabled` | Whether the action group is enabled | `bool` | `true` |
| `email_receivers` | List of email receivers | `list(object)` | `[]` |
| `sms_receivers` | List of SMS receivers | `list(object)` | `[]` |
| `webhook_receivers` | List of webhook receivers | `list(object)` | `[]` |
| `azure_app_push_receivers` | List of Azure App push receivers | `list(object)` | `[]` |
| `additional_action_group_ids` | Additional action group IDs to notify | `list(string)` | `[]` |

### Common

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `tags` | Tags to apply to resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `budget_id` | The ID of the consumption budget |
| `budget_name` | The name of the consumption budget |
| `action_group_id` | The ID of the action group (if created) |
| `action_group_name` | The name of the action group (if created) |
| `budget_summary` | Summary of the budget configuration |

## Examples

See the `Usage` section above for complete examples.

## Notes

- **Action Group Requirement**: If `enable_action_group = true`, you must provide `resource_group_name` and `action_group_short_name`
- **Short Name Limit**: Action group short names are limited to 12 characters
- **Multiple Notifications**: Budgets can notify through both direct email and action groups simultaneously
- **Threshold Types**:
  - `actual_threshold`: Triggers when actual spend exceeds the threshold
  - `forecasted_threshold`: Triggers when Azure's forecast predicts exceeding the threshold
- **Production Recommendation**: Use both actual and forecast thresholds for production workloads
- **Common Alert Schema**: Enabled by default for better integration with monitoring tools

## Related Modules

- [Action Group Module](../../resource-modules/action-group/README.md)
- [Consumption Budget Module](../../resource-modules/consumption-budget/README.md)

## License

See the main repository LICENSE file.

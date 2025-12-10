# Azure Consumption Budget Module

This module creates an Azure Consumption Budget at the subscription level with configurable alert thresholds for actual and forecasted spend.

## Features

- Subscription-scoped budgets
- Configurable actual spend alerts (default: 120%)
- Configurable forecasted spend alerts (optional, recommended: 130% for production)
- Email and RBAC role notifications
- Action group integration
- Optional resource group filtering

## Usage

### Basic Budget (Non-Production)

```hcl
module "dev_budget" {
  source = "../../../shared-modules/resource-modules/consumption-budget"

  name            = "budget-dev-monthly"
  subscription_id = "588aa873-b13e-40bc-a96f-89805c56d7d0"
  amount          = 10
  start_date      = "2025-01-01T00:00:00Z"

  # Dev/QA: Actual alerts only at 120%
  actual_threshold      = 120
  forecasted_threshold  = null

  contact_emails = ["finance@acme.com", "platform-team@acme.com"]
}
```

### Production Budget (Both Alerts)

```hcl
module "prod_budget" {
  source = "../../../shared-modules/resource-modules/consumption-budget"

  name            = "budget-prod-monthly"
  subscription_id = "95d02110-3796-4dc6-af3b-f4759cda0d2f"
  amount          = 100
  start_date      = "2025-01-01T00:00:00Z"

  # Production: Both actual (120%) and forecasted (130%) alerts
  actual_threshold      = 120
  forecasted_threshold  = 130

  contact_emails = ["finance@acme.com", "platform-team@acme.com"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | The name of the consumption budget | `string` | n/a | yes |
| subscription_id | The ID of the subscription to apply the budget to | `string` | n/a | yes |
| amount | The total amount for the budget (in USD) | `number` | n/a | yes |
| time_grain | The time grain for the budget | `string` | `"Monthly"` | no |
| start_date | The start date for the budget (RFC3339) | `string` | n/a | yes |
| end_date | The end date for the budget (RFC3339) | `string` | `null` | no |
| actual_threshold | Threshold % for actual spend alerts | `number` | `120` | no |
| forecasted_threshold | Threshold % for forecasted alerts | `number` | `null` | no |
| contact_emails | List of email addresses to notify | `list(string)` | `[]` | no |
| contact_roles | List of Azure RBAC roles to notify | `list(string)` | `["Owner", "Contributor"]` | no |
| contact_groups | List of action group resource IDs | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the consumption budget |
| name | The name of the consumption budget |
| subscription_id | The subscription ID the budget is applied to |

## Budget Governance Strategy

### Budget Definition
- **Base Amount**: Set at 110% of current monthly spend
- **Start Point**: Beginning of next month or current month

### Alert Triggers
- **Actual Spend**: Alert when actual spend exceeds **120%** of budget
- **Forecasted Spend**: Alert when forecast exceeds **130%** of budget

### Environment Strategy

| Environment | Alert Type | Thresholds | Reason |
|-------------|-----------|------------|---------|
| Production | Both (Actual + Forecast) | 120% / 130% | Critical workloads need proactive + reactive alerts |
| Dev/QA/UAT | Actual only | 120% | Variable usage, reactive alerts sufficient |
| Sandbox | Actual only | 120% | Experimental workloads, reactive monitoring |

### Benefits
- **Avoids alert fatigue**: Only alerts at meaningful thresholds
- **Actionable alerts**: 120%/130% thresholds indicate real issues
- **Proactive + Reactive**: Production gets both forecast warnings and actual spend alerts
- **Environment-appropriate**: Dev/QA doesn't need forecast alerts due to variable usage

## Notes

- Budgets are informational only - they do not prevent spending
- Start date must be the first day of a month
- End date must be after start date (or null for no end)
- At least one notification threshold must be configured
- Email notifications go to all specified addresses and role members

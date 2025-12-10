# Cost Management Budget Implementation

## Overview

Azure Consumption Budgets have been deployed at the **01-foundation** layer as part of the centralized governance strategy. This ensures all subscriptions have budget monitoring and alerts configured according to governance policies.

**NEW**: Azure Monitor Action Groups are now configured per cost center to provide better alert routing and management.

## Architecture

### Components

1. **Resource Group**: `rg-cost-monitoring-{location}` - Hosts all cost monitoring resources
2. **Action Groups** (3 total) - One per cost center for alert routing:
   - `ag-cost-alerts-infrastructure` - For platform subscriptions (Management, Connectivity, Identity)
   - `ag-cost-alerts-it-operations` - For IT-Operations subscriptions (Admin portals)
   - `ag-cost-alerts-marketing` - For Marketing subscriptions (Customer portals)
3. **Budgets** (7 total) - One per subscription with appropriate action group assignment

### Alert Flow

```
Budget Alert → Action Group (by Cost Center) → Email Recipients
```

## Budget Strategy

### Budget Definition
- **Base Amount**: $10/month per subscription (baseline, adjust based on actual usage)
- **Start Date**: 2025-01-01 (beginning of month)
- **Time Grain**: Monthly

### Alert Governance

#### Alert Triggers
- **Actual Spend Alert**: Triggered when actual spend exceeds **120%** of budget
- **Forecasted Spend Alert**: Triggered when forecast exceeds **130%** of budget (Production only)

#### Environment-Based Alerts

| Environment | Subscriptions | Alert Type | Thresholds | Reason |
|-------------|--------------|-----------|------------|---------|
| **Platform** | Management, Connectivity, Identity | Actual Only | 120% | Infrastructure costs are predictable |
| **Dev/QA** | Portals Admin Dev, Portals Customer Dev | Actual Only | 120% | Variable usage patterns, reactive alerts sufficient |
| **Production** | Portals Admin Prod, Portals Customer Prod | Both (Actual + Forecast) | 120% / 130% | Critical workloads need proactive + reactive alerts |

### Benefits
✅ **Avoids Alert Fatigue**: Only alerts at meaningful thresholds (120%/130%)
✅ **Actionable Alerts**: Indicates real cost issues requiring attention
✅ **Proactive Monitoring**: Production gets forecast warnings before overspend
✅ **Environment-Appropriate**: Dev/QA doesn't need forecast alerts due to variable usage

## Deployed Budgets

| Budget Name | Subscription | Type | Monthly Amount | Actual Alert @ | Forecast Alert @ | Action Group |
|-------------|--------------|------|----------------|----------------|------------------|--------------|
| `budget-management-monthly` | Management (`1302f...`) | Platform | $10 | $12 (120%) | - | Infrastructure |
| `budget-connectivity-monthly` | Connectivity (`c82e...`) | Platform | $10 | $12 (120%) | - | Infrastructure |
| `budget-identity-monthly` | Identity (`0578...`) | Platform | $10 | $12 (120%) | - | Infrastructure |
| `budget-portals-admin-dev-monthly` | Portals Admin Dev (`588a...`) | Dev | $10 | $12 (120%) | - | IT-Operations |
| `budget-portals-customer-dev-monthly` | Portals Customer Dev (`9a87...`) | Dev | $10 | $12 (120%) | - | Marketing |
| `budget-portals-admin-prod-monthly` | Portals Admin Prod (`95d0...`) | **Production** | $10 | $12 (120%) | $13 (130%) | IT-Operations |
| `budget-portals-customer-prod-monthly` | Portals Customer Prod (`b13c...`) | **Production** | $10 | $12 (120%) | $13 (130%) | Marketing |

## Action Groups by Cost Center

### Infrastructure Cost Center
**Action Group**: `ag-cost-alerts-infrastructure` (short name: `costinfra`)

**Subscriptions**:
- Management
- Connectivity
- Identity

**Recipients**:
- finance@acmecorporation.dev (Finance Team)
- joshd@acmecorporation.dev (Platform Team)

### IT-Operations Cost Center
**Action Group**: `ag-cost-alerts-it-operations` (short name: `costitops`)

**Subscriptions**:
- Portals Admin Dev
- Portals Admin Prod

**Recipients**:
- finance@acmecorporation.dev (Finance Team)
- joshd@acmecorporation.dev (IT Operations)

### Marketing Cost Center
**Action Group**: `ag-cost-alerts-marketing` (short name: `costmkt`)

**Subscriptions**:
- Portals Customer Dev
- Portals Customer Prod

**Recipients**:
- finance@acmecorporation.dev (Finance Team)
- joshd@acmecorporation.dev (Marketing Team)

## Alert Recipients

Budget alerts are sent to:
- **Email Notifications**:
  - finance@acmecorporation.dev
  - joshd@acmecorporation.dev
- **Azure RBAC Roles**:
  - Owner
  - Contributor

## Configuration

Budgets and action groups are configured in `01-foundation/main.tf`.

### Adding New Email Recipients to Action Groups

To add additional recipients to a specific cost center's action group, update the `email_receivers` list in `main.tf`:

```hcl
# Example: Adding a recipient to Marketing action group
module "action_group_marketing" {
  source = "../shared-modules/resource-modules/action-group"

  # ... other config ...

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
    },
    {
      name                    = "Marketing-Director"
      email_address           = "director@acmecorporation.dev"
      use_common_alert_schema = true
    }
  ]
}
```

### Adding SMS or Webhook Notifications

Action groups support multiple notification channels:

```hcl
module "action_group_infrastructure" {
  source = "../shared-modules/resource-modules/action-group"

  # ... existing email_receivers ...

  # Add SMS notifications
  sms_receivers = [
    {
      name         = "On-Call-Engineer"
      country_code = "1"
      phone_number = "5551234567"
    }
  ]

  # Add webhook (e.g., Microsoft Teams)
  webhook_receivers = [
    {
      name                    = "Teams-Channel"
      service_uri             = "https://outlook.office.com/webhook/..."
      use_common_alert_schema = true
    }
  ]
}
```

### Adjusting Budget Amounts

To change budget amounts, update values in `01-foundation/variables.tf`:

```hcl
# Platform Subscription Budgets
variable "budget_amount_management" {
  default = 10  # Change this value
}

variable "budget_amount_connectivity" {
  default = 10  # Change this value
}

# Workload Subscription Budgets
variable "budget_amount_portals_admin_prod" {
  default = 10  # Change this value
}
```

Or override in `01-foundation/terraform.tfvars`:

```hcl
budget_amount_management = 50
budget_amount_connectivity = 100
budget_amount_portals_admin_prod = 200
```

### Changing Alert Emails

Update `budget_contact_emails` in `variables.tf` or `terraform.tfvars`:

```hcl
budget_contact_emails = ["finance@example.com", "admin@example.com", "ops@example.com"]
```

## Deployment

Budgets are deployed with the foundation layer:

```powershell
cd 01-foundation
$env:ARM_SUBSCRIPTION_ID = "1302f5fd-f3b5-4eda-909c-e3ae2dfee3d6"
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Outputs

After deployment, budget and action group information is available in outputs:

```powershell
# Get all action group IDs
terraform output action_group_ids

# Get all budget IDs
terraform output budget_ids

# Get budget summary
terraform output budget_summary

# Get cost monitoring resource group name
terraform output cost_monitoring_resource_group_name
```

## Benefits of Action Groups

✅ **Centralized Management**: All recipients for a cost center managed in one place  
✅ **Multi-Channel Support**: Email, SMS, webhooks, and Azure App push notifications  
✅ **Reusability**: Same action group can be used across multiple budgets and alerts  
✅ **Common Alert Schema**: Consistent alert format across all notification channels  
✅ **Easy Updates**: Add/remove recipients without modifying individual budgets  
✅ **Integration Ready**: Works with Microsoft Teams, Slack, PagerDuty, and more via webhooks

## Important Notes

⚠️ **Budgets Are Informational Only**: Azure budgets do not prevent spending - they only send alerts when thresholds are exceeded.

💡 **Monthly Reset**: Budgets reset at the beginning of each month based on the start date.

📊 **Forecasting**: Azure uses historical usage patterns to forecast spend. New subscriptions may not have accurate forecasts initially.

## Module Documentation

For detailed information about the modules used, see:
- [Consumption Budget Module README](../shared-modules/resource-modules/consumption-budget/README.md)
- [Action Group Module README](../shared-modules/resource-modules/action-group/README.md)

## Related Resources

- [Azure Cost Management Best Practices](https://learn.microsoft.com/azure/cost-management-billing/costs/cost-mgt-best-practices)
- [Azure Consumption Budgets Documentation](https://learn.microsoft.com/azure/cost-management-billing/costs/tutorial-acm-create-budgets)
- [Azure Monitor Action Groups Documentation](https://learn.microsoft.com/azure/azure-monitor/alerts/action-groups)

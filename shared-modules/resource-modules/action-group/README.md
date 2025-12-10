# Azure Monitor Action Group Module

Creates an Azure Monitor Action Group for alerting and notifications.

## Features

- Email notifications
- SMS notifications
- Webhook integrations
- Azure App push notifications
- Common alert schema support
- Tagging support

## Usage

### Basic Email Action Group

```hcl
module "cost_alert_action_group" {
  source = "../../../shared-modules/resource-modules/action-group"

  name                = "ag-cost-alerts-infrastructure"
  resource_group_name = "rg-monitoring-prod"
  short_name          = "costinfra"

  email_receivers = [
    {
      name          = "Finance Team"
      email_address = "finance@example.com"
    },
    {
      name          = "Platform Team"
      email_address = "platform@example.com"
    }
  ]

  tags = {
    Environment = "Production"
    CostCenter  = "Infrastructure"
  }
}
```

### Multi-Channel Action Group

```hcl
module "critical_alerts" {
  source = "../../../shared-modules/resource-modules/action-group"

  name                = "ag-critical-alerts"
  resource_group_name = "rg-monitoring-prod"
  short_name          = "critical"

  email_receivers = [
    {
      name          = "Operations"
      email_address = "ops@example.com"
    }
  ]

  sms_receivers = [
    {
      name         = "On-Call"
      country_code = "1"
      phone_number = "5551234567"
    }
  ]

  webhook_receivers = [
    {
      name        = "Teams Webhook"
      service_uri = "https://outlook.office.com/webhook/..."
    }
  ]

  tags = {
    Environment = "Production"
    Criticality = "High"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | The name of the action group | `string` | n/a | yes |
| resource_group_name | The resource group name | `string` | n/a | yes |
| short_name | Short name (max 12 chars) for SMS | `string` | n/a | yes |
| enabled | Whether the action group is enabled | `bool` | `true` | no |
| email_receivers | List of email receivers | `list(object)` | `[]` | no |
| sms_receivers | List of SMS receivers | `list(object)` | `[]` | no |
| webhook_receivers | List of webhook receivers | `list(object)` | `[]` | no |
| azure_app_push_receivers | List of Azure App push receivers | `list(object)` | `[]` | no |
| tags | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the action group |
| name | The name of the action group |
| resource_group_name | The resource group name |

## Notes

- **Short Name**: Limited to 12 characters, used in SMS notifications
- **Common Alert Schema**: Enabled by default for email and webhook receivers
- **SMS Limits**: Azure has SMS rate limits and costs per message
- **Webhook Format**: Supports common alert schema for consistent payload structure

## Integration with Budgets

Action groups can be referenced in budget notifications:

```hcl
module "budget" {
  source = "../consumption-budget"

  # ... other budget config ...

  contact_groups = [module.cost_alert_action_group.id]
}
```

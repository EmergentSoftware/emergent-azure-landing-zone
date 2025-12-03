# Log Analytics Workspace Wrapper Module

Wrapper for `Azure/avm-res-operationalinsights-workspace/azurerm` to insulate from upstream changes.

## Usage

```hcl
module "log_analytics" {
  source = "../../modules/log-analytics-workspace"

  name                = "log-myworkspace-eastus"
  resource_group_name = module.rg.name
  location            = "eastus"
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = { Environment = "prod" }
}
```

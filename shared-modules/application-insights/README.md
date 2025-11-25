# Application Insights Wrapper Module

Wrapper for `Azure/avm-res-insights-component/azurerm` to insulate from upstream changes.

## Usage

```hcl
module "appinsights" {
  source = "../../modules/application-insights"

  name                = "appi-myapp-dev"
  resource_group_name = module.rg.name
  location            = "eastus"
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id
  tags                = { Environment = "dev" }
}
```

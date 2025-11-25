# App Service Plan Wrapper Module

Wrapper for `Azure/avm-res-web-serverfarm/azurerm` to insulate from upstream changes.

## Usage

```hcl
module "asp" {
  source = "../../modules/app-service-plan"

  name                = "asp-myapp-dev"
  resource_group_name = module.rg.name
  location            = "eastus"
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = { Environment = "dev" }
}
```

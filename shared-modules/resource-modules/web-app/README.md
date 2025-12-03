# Web App Wrapper Module

Wrapper for `Azure/avm-res-web-site/azurerm` to insulate from upstream changes.

## Usage

```hcl
module "webapp" {
  source = "../../modules/web-app"

  name                     = "app-myapp-dev"
  resource_group_name      = module.rg.name
  location                 = "eastus"
  service_plan_resource_id = module.asp.resource_id
  https_only               = true
  
  site_config = {
    minimum_tls_version = "1.2"
    always_on           = true
  }
  
  tags = { Environment = "dev" }
}
```

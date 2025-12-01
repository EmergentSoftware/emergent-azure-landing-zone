# Static Web App Wrapper Module

Wrapper for `azurerm_static_web_app` resource.

**Note**: There is no official AVM module for Static Web Apps yet, so this uses the native azurerm resource.

## Usage

```hcl
module "static_web_app" {
  source = "../../shared-modules/static-web-app"

  name                = "stapp-myportal-dev"
  resource_group_name = module.rg.name
  location            = "eastus2"
  sku_tier            = "Standard"
  sku_size            = "Standard"
  
  enable_managed_identity = true
  
  tags = { 
    Environment = "dev"
    Project     = "Customer Portal"
  }
}
```

## Features

- Standard tier required for private endpoints
- System-assigned managed identity support
- Automatic HTTPS
- Custom domains (Standard tier)
- GitHub/Azure DevOps integration

## Private Endpoints

Private endpoints are only supported on the **Standard tier** (~$9/month).

To add private endpoints, create them separately using the private endpoint module and reference the Static Web App ID.

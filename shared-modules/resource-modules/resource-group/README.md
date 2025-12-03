# Resource Group Wrapper Module

Wrapper for `Azure/avm-res-resources-resourcegroup/azurerm` to insulate from upstream changes.

## Usage

```hcl
module "rg" {
  source = "../../modules/resource-group"

  name     = "rg-myapp-dev-eastus"
  location = "eastus"
  tags     = {
    Environment = "dev"
  }
}
```

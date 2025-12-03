# Virtual Network Wrapper Module

Wrapper for `Azure/avm-res-network-virtualnetwork/azurerm` to insulate from upstream changes.

## Usage

```hcl
module "vnet" {
  source = "../../modules/virtual-network"

  name                = "vnet-myapp-eastus"
  resource_group_name = module.rg.name
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]
  
  subnets = {
    default = {
      address_prefixes = ["10.0.1.0/24"]
    }
    webapp = {
      address_prefixes = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Web", "Microsoft.Storage"]
    }
  }
  
  tags = { Environment = "prod" }
}
```

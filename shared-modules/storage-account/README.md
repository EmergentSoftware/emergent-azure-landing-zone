# Storage Account Wrapper Module

This module wraps the Azure Verified Module (AVM) for Storage Account with standardized configurations.

## Usage

```hcl
module "storage" {
  source = "../../shared-modules/storage-account"

  name                = "mystorageacct123"
  location            = "eastus"
  resource_group_name = module.rg.name

  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    Environment = "Production"
  }
}
```

## Features

- Wraps `Azure/avm-res-storage-storageaccount/azurerm`
- Enforces security best practices by default
- Supports all AVM storage account features
- Consistent interface across the landing zone

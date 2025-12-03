# Storage Container Module

This module provides a wrapper around `azurerm_storage_container` for creating Azure Storage Blob containers.

## Usage

```hcl
module "storage_container" {
  source = "../../shared-modules/storage-container"

  name                  = "tfstate-foundation"
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the storage container | `string` | n/a | yes |
| storage_account_id | The ID of the storage account | `string` | n/a | yes |
| container_access_type | Access level (private, blob, container) | `string` | `"private"` | no |
| metadata | Metadata to assign to the container | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the storage container |
| name | The name of the storage container |
| has_immutability_policy | Whether the container has an immutability policy |
| has_legal_hold | Whether the container has a legal hold |
| resource_manager_id | The Resource Manager ID of the storage container |

## Notes

- Container names must be 3-63 characters, lowercase letters, numbers, and hyphens only
- There is no Azure Verified Module for storage containers, so this wrapper provides consistency with the rest of the codebase

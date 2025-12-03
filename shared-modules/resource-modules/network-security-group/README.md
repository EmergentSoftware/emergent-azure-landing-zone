# Network Security Group Module

This module creates an Azure Network Security Group with optional security rules.

## Usage

```hcl
module "nsg" {
  source = "../../shared-modules/network-security-group"

  name                = "nsg-subnet-prod-eus2"
  location            = "eastus2"
  resource_group_name = "rg-network-prod-eus2"

  tags = {
    Environment = "Production"
    Purpose     = "Application Subnet NSG"
  }

  security_rules = {
    allow_https = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the Network Security Group | string | - | yes |
| location | Azure region | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| tags | Tags to apply | map(string) | {} | no |
| security_rules | Map of security rules | map(object) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | NSG resource ID |
| name | NSG name |
| location | NSG location |
| resource_group_name | NSG resource group |

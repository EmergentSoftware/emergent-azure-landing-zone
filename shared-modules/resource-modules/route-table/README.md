# Route Table Module

This module creates an Azure Route Table (User Defined Routes / UDR) with optional routes.

## Usage

```hcl
module "route_table" {
  source = "../../shared-modules/route-table"

  name                = "rt-subnet-prod-eus2"
  location            = "eastus2"
  resource_group_name = "rg-network-prod-eus2"

  disable_bgp_route_propagation = false

  tags = {
    Environment = "Production"
    Purpose     = "Application Subnet Route Table"
  }

  routes = {
    to_firewall = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    }
    to_on_premises = {
      address_prefix = "192.168.0.0/16"
      next_hop_type  = "VirtualNetworkGateway"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the Route Table | string | - | yes |
| location | Azure region | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| disable_bgp_route_propagation | Disable BGP route propagation | bool | false | no |
| tags | Tags to apply | map(string) | {} | no |
| routes | Map of routes | map(object) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Route Table resource ID |
| name | Route Table name |
| location | Route Table location |
| resource_group_name | Route Table resource group |

## Next Hop Types

Valid values for `next_hop_type`:
- `VirtualNetworkGateway` - Route to VPN/ExpressRoute gateway
- `VnetLocal` - Route within the VNet
- `Internet` - Route to Internet
- `VirtualAppliance` - Route to Network Virtual Appliance (requires next_hop_in_ip_address)
- `None` - Drop traffic

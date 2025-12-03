# Private Endpoint Module

This module creates an Azure Private Endpoint for connecting to Azure services over a private network.

## Features

- Creates private endpoints for Azure resources
- Supports private DNS zone integration
- Configurable subresource names for different Azure services
- Optional manual approval for connections

## Usage

```hcl
module "private_endpoint" {
  source = "../../shared-modules/private-endpoint"

  name                           = "pe-myresource"
  location                       = "eastus"
  resource_group_name            = "rg-example"
  subnet_id                      = "/subscriptions/.../subnets/pe-subnet"
  private_connection_resource_id = azurerm_static_web_app.example.id
  subresource_names              = ["staticSites"]
  private_dns_zone_ids           = ["/subscriptions/.../privateDnsZones/privatelink.azurestaticapps.net"]

  tags = {
    Environment = "Production"
  }
}
```

## Common Subresource Names

- Static Web Apps: `["staticSites"]`
- Storage Account (Blob): `["blob"]`
- Storage Account (File): `["file"]`
- Key Vault: `["vault"]`
- SQL Database: `["sqlServer"]`
- Cosmos DB: `["Sql"]`, `["MongoDB"]`, `["Cassandra"]`, `["Gremlin"]`, `["Table"]`

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.12.0 |
| azurerm | ~> 4.0 |

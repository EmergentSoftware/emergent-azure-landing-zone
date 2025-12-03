# Connectivity Landing Zone

This landing zone manages the connectivity subscription and provides centralized networking services for the hub-and-spoke architecture.

## Overview

The connectivity landing zone deploys:

- **Hub Virtual Network** (10.0.0.0/16) with specialized subnets:
  - GatewaySubnet (10.0.0.0/27) - For VPN/ExpressRoute Gateway
  - AzureFirewallSubnet (10.0.1.0/26) - For Azure Firewall
  - AzureBastionSubnet (10.0.2.0/26) - For Azure Bastion
  - Shared Services (10.0.10.0/24) - DNS, Domain Controllers
  - NVA (10.0.11.0/24) - Network Virtual Appliances
  - Management (10.0.12.0/24) - Management and monitoring tools

- **Private DNS Zones** for Azure Private Link services:
  - Azure Static Web Apps (`privatelink.azurestaticapps.net`)
  - Azure Storage (blob, file, table, queue)
  - Azure SQL Database (`privatelink.database.windows.net`)
  - Azure Cosmos DB (`privatelink.documents.azure.com`)
  - Azure Key Vault (`privatelink.vaultcore.azure.net`)
  - Azure App Service (`privatelink.azurewebsites.net`)
  - Azure Container Registry (`privatelink.azurecr.io`)
  - Azure Service Bus / Event Hub (`privatelink.servicebus.windows.net`)

## Architecture

```
Connectivity Subscription (c82e0943-3765-49ff-97ff-92855167f3ea)
├── Hub VNet (10.0.0.0/16)
│   ├── GatewaySubnet
│   ├── AzureFirewallSubnet
│   ├── AzureBastionSubnet
│   ├── Shared Services Subnet
│   ├── NVA Subnet
│   └── Management Subnet
│
├── Private DNS Zones
│   ├── Static Web Apps
│   ├── Storage (blob, file, table, queue)
│   ├── SQL Database
│   ├── Cosmos DB
│   ├── Key Vault
│   ├── App Service
│   ├── Container Registry
│   └── Service Bus / Event Hub
│
└── Management Group: acme-connectivity
```

## Deployment

### Prerequisites

1. Bootstrap infrastructure deployed (`00-bootstrap`)
2. ALZ Foundation deployed (`01-alz-foundation`)

### Deploy

```powershell
cd 02-landing-zones/connectivity

# Initialize with backend configuration
terraform init -backend-config="backend.tfbackend"

# Review and apply
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

**Note:** Backend configuration is stored in `backend.tfbackend` and managed by the bootstrap layer outputs.

## Outputs

- `hub_vnet_id` - Hub VNet resource ID
- `hub_vnet_name` - Hub VNet name
- `network_resource_group_name` - Network resource group name
- `private_dns_zones` - Map of all private DNS zone IDs
- `private_dns_resource_group_name` - Private DNS resource group name

## IPAM Reference

Network configuration is defined in `02-landing-zones/ipam.yaml` under the `connectivity.hub` section.

## Private DNS Integration

Spoke VNets automatically gain access to private DNS resolution once VNet peering is established with the hub. No additional DNS configuration is needed in spoke VNets.

## Next Steps

After deploying connectivity:

1. Deploy workload landing zones (portals-admin-dev, portals-customer-dev)
2. Configure VNet peering between hub and spokes
3. Deploy private endpoints in spoke VNets

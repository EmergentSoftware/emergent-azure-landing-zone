# Portals Admin Dev Landing Zone

This landing zone manages the admin portal development subscription and provides dedicated network infrastructure.

## Overview

The portals-admin-dev landing zone deploys:

- **Spoke Virtual Network** (10.100.0.0/16) with subnets:
  - Apps Subnet (10.100.1.0/24) - Admin portal applications
  - Private Endpoints Subnet (10.100.2.0/24) - Static Web App private endpoints
  - VNet Integration Subnet (10.100.3.0/24) - App Service VNet integration
  - Data Subnet (10.100.4.0/24) - Database and data services

- **Log Analytics Workspace** for monitoring and diagnostics

- **Management Group Placement** in `acme-portals`

## Architecture

```
Admin Portal Dev Subscription (588aa873-b13e-40bc-a96f-89805c56d7d0)
├── VNet (10.100.0.0/16)
│   ├── Apps Subnet (10.100.1.0/24)
│   ├── Private Endpoints Subnet (10.100.2.0/24)
│   ├── VNet Integration Subnet (10.100.3.0/24)
│   └── Data Subnet (10.100.4.0/24)
│
├── Log Analytics Workspace
│
└── Management Group: acme-portals
```

## Deployment

### Prerequisites

1. Bootstrap infrastructure deployed (`00-bootstrap`)
2. ALZ Foundation deployed (`01-alz-foundation`)
3. Connectivity landing zone deployed (for private DNS)

### Deploy

```powershell
cd 02-landing-zones/workloads/portals-admin-dev

# Initialize backend
terraform init -reconfigure `
  -backend-config="resource_group_name=acme-rg-prod-eus-vw01" `
  -backend-config="storage_account_name=acmestprodeusvw01" `
  -backend-config="container_name=tfstate-portal-dev" `
  -backend-config="key=portals-admin-dev.tfstate"

# Review and apply
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Outputs

- `portals_vnet_id` - Admin portal VNet resource ID
- `portals_vnet_name` - Admin portal VNet name
- `networking_resource_group_name` - Network resource group name
- `log_analytics_workspace_id` - Log Analytics workspace ID

## IPAM Reference

Network configuration is defined in `02-landing-zones/ipam.yaml` under the `portals-admin-dev` section.

## Network Isolation

This landing zone provides complete network isolation for the admin portal workload. It has its own dedicated:
- Virtual network (separate from customer portal)
- Private endpoints subnet
- Log Analytics workspace

## Next Steps

After deploying the landing zone:

1. Deploy admin portal workload (`03-workloads/portals/admin-portal`)
2. Configure VNet peering to hub VNet
3. Add private endpoints for Static Web App

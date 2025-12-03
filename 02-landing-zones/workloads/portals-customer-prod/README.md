# Portals Customer Dev Landing Zone

This landing zone manages the customer portal development subscription and provides dedicated network infrastructure.

## Overview

The portals-customer-dev landing zone deploys:

- **Spoke Virtual Network** (10.110.0.0/16) with subnets:
  - Apps Subnet (10.110.1.0/24) - Customer portal applications
  - Private Endpoints Subnet (10.110.2.0/24) - Static Web App private endpoints
  - VNet Integration Subnet (10.110.3.0/24) - App Service VNet integration
  - Data Subnet (10.110.4.0/24) - Database and data services

- **Log Analytics Workspace** for monitoring and diagnostics

- **Management Group Placement** in `acme-portals`

## Architecture

```
Customer Portal Dev Subscription (9a877ddf-9796-43a8-a557-f6af1df195bf)
├── VNet (10.110.0.0/16)
│   ├── Apps Subnet (10.110.1.0/24)
│   ├── Private Endpoints Subnet (10.110.2.0/24)
│   ├── VNet Integration Subnet (10.110.3.0/24)
│   └── Data Subnet (10.110.4.0/24)
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
cd 02-landing-zones/workloads/portals-customer-prod

# Initialize with backend configuration
terraform init -backend-config="backend.tfbackend"

# Review and apply
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

**Note:** Backend configuration is stored in `backend.tfbackend` and managed by the bootstrap layer outputs.

## Outputs

- `portals_vnet_id` - Customer portal VNet resource ID
- `portals_vnet_name` - Customer portal VNet name
- `networking_resource_group_name` - Network resource group name
- `log_analytics_workspace_id` - Log Analytics workspace ID

## IPAM Reference

Network configuration is defined in `02-landing-zones/ipam.yaml` under the `portals-customer-dev` section.

## Network Isolation

This landing zone provides complete network isolation for the customer portal workload. It has its own dedicated:
- Virtual network (separate from admin portal)
- Private endpoints subnet
- Log Analytics workspace

## Next Steps

After deploying the landing zone:

1. Deploy customer portal workload (`03-workloads/portals/customer-portal`)
2. Configure VNet peering to hub VNet
3. Add private endpoints for Static Web App

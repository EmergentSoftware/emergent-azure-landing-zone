# Portals Admin Prod Landing Zone

This landing zone manages the admin portal production subscription and provides dedicated network infrastructure.

## Overview

The portals-admin-prod landing zone deploys:

- **Spoke Virtual Network** (10.102.0.0/16) with subnets:
  - Apps Subnet (10.102.1.0/24) - Admin portal applications
  - Private Endpoints Subnet (10.102.2.0/24) - Static Web App private endpoints
  - VNet Integration Subnet (10.102.3.0/24) - App Service VNet integration
  - Data Subnet (10.102.4.0/24) - Database and data services

- **Log Analytics Workspace** for monitoring and diagnostics

- **Management Group Placement** in `acme-portals`

## Architecture

```
Admin Portal Prod Subscription (95d02110-3796-4dc6-af3b-f4759cda0d2f)
├── VNet (10.102.0.0/16)
│   ├── Apps Subnet (10.102.1.0/24)
│   ├── Private Endpoints Subnet (10.102.2.0/24)
│   ├── VNet Integration Subnet (10.102.3.0/24)
│   └── Data Subnet (10.102.4.0/24)
│
├── Log Analytics Workspace
│
└── Management Group: acme-portals
```

## Deployment

### Prerequisites

1. Bootstrap infrastructure deployed (`00-bootstrap`)
2. ALZ Foundation deployed (`01-foundation`)
3. Connectivity landing zone deployed (for private DNS)

### Deploy

```powershell
cd 02-landing-zones/workloads/portals-admin-prod

# Initialize with backend configuration
terraform init -backend-config="backend.tfbackend"

# Review and apply
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## What Gets Created

### Network Resources
- Virtual Network with 4 subnets
- Network Security Groups (NSGs) for each subnet
- Route Tables for each subnet

### Monitoring
- Log Analytics Workspace for centralized logging

### Management
- Subscription placed in `acme-portals` management group
- Inherits policies from management group hierarchy

## Configuration

Configuration is minimal - subscription ID and tenant ID only:

```hcl
subscription_id = "95d02110-3796-4dc6-af3b-f4759cda0d2f"
tenant_id       = "0b79ac7b-0cc7-4d9f-a549-3b8cc894ac9b"
```

All other configuration comes from:
- Variable defaults in `variables.tf`
- IPAM configuration in `../ipam.yaml`
- Pattern module defaults

## Outputs

The module outputs:
- VNet ID and name
- Subnet IDs
- Log Analytics Workspace ID
- Resource group names

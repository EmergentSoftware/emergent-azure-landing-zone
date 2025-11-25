# Azure Landing Zone Foundation

This directory contains the Terraform configuration for deploying the Azure Landing Zone (ALZ) foundation using Azure Verified Modules (AVM).

## Architecture

This deployment creates the foundational management group hierarchy and governance policies:

```
Tenant Root Group
└── alz (ACME ALZ)
    ├── platform
    │   ├── management
    │   ├── connectivity
    │   └── identity
    ├── landingzones
    │   ├── corp
    │   └── online
    ├── sandbox
    └── decommissioned
```

## What Gets Deployed

- **Management Groups**: Hierarchical organization structure (11 management groups)
- **Policy Definitions**: 157 custom Azure policies
- **Policy Set Definitions**: 48 policy initiatives
- **Policy Assignments**: 120+ policy assignments across management groups
- **Custom Role Definitions**: 6 RBAC roles
- **Policy Role Assignments**: Managed identity permissions for policies
- **Hierarchy Settings**: Default management group and authorization settings

## Prerequisites

- Azure CLI or PowerShell authenticated
- Appropriate permissions at tenant root level
- Terraform >= 1.3.0

## Deployment Steps

### 1. Configure Variables

Copy the example file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your configuration.

### 2. Initialize Terraform

```bash
cd alz-foundation
terraform init
```

### 3. Plan the Deployment

```bash
terraform plan -out=tfplan
```

Review the plan output carefully. You should see approximately 540 resources to be created.

### 4. Deploy

```bash
terraform apply tfplan
```

The deployment will take 15-30 minutes to complete.

### 5. Verify

Check the Azure Portal:
1. Navigate to Management Groups
2. Verify the hierarchy was created
3. Check policy assignments at each level

## Module Structure

This configuration uses a wrapper module pattern:

```
alz-foundation/
├── main.tf                          # Root configuration
├── variables.tf                     # Input variables
├── outputs.tf                       # Outputs
├── terraform.tfvars                 # Your configuration
└── modules/
    └── alz-wrapper/                 # Wrapper module
        ├── main.tf                  # Calls upstream AVM module
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

The wrapper module insulates your configuration from changes to the upstream Azure Verified Module.

## Customization

To modify the deployment:

1. **Change allowed regions**: Edit `allowed_locations` in `terraform.tfvars`
2. **Modify management group names**: Update `default_management_group_name` in `main.tf`
3. **Adjust policy assignments**: Modify `policy_assignments_to_modify` block in `main.tf`
4. **Update upstream module version**: Edit `version` in `modules/alz-wrapper/main.tf`

## Outputs

Key outputs after deployment:

- `management_group_ids`: Map of all management group IDs
- `policy_assignment_ids`: Map of policy assignment IDs
- `policy_definition_ids`: Custom policy definitions
- `tenant_id`: Azure tenant ID
- `subscription_id`: Subscription used for deployment

## Next Steps

After deploying the foundation:

1. **Assign subscriptions** to appropriate management groups
2. **Deploy workloads** to landing zone subscriptions (see `../workloads/web-app/`)
3. **Configure monitoring** (Log Analytics, Application Insights)
4. **Set up networking** (Hub VNets, ExpressRoute/VPN)

## Updating

To update the ALZ configuration:

```bash
terraform plan
terraform apply
```

To update the upstream AVM module version, edit `modules/alz-wrapper/main.tf` and change the `version` constraint.

## Cleanup

⚠️ **Warning**: Destroying the ALZ foundation will remove all management groups and policies. Only do this in test/demo environments.

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

**Issue**: Policy assignment errors during apply
- **Solution**: Azure has eventual consistency. Wait a few minutes and retry.

**Issue**: Permission denied errors
- **Solution**: Ensure you have Owner or User Access Administrator role at tenant root.

**Issue**: Management group already exists
- **Solution**: The module will import existing management groups. Review the plan carefully.

## Support

For issues with the upstream AVM module, see: https://github.com/Azure/terraform-azurerm-avm-ptn-alz

For ACME-specific customizations, contact the Platform Engineering team.

# Emergent Software - Azure Landing Zone Reference Implementation

> **Official Reference Implementation**  
> This repository is Emergent Software's official reference implementation for deploying Azure Landing Zones using Azure Verified Modules (AVM) and Terraform.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Azure Verified Modules](https://img.shields.io/badge/AVM-Verified-0078D4?logo=microsoft-azure)](https://azure.github.io/Azure-Verified-Modules/)

> **⚠️ IMPORTANT: Deployment Order**  
> See [DEPLOYMENT-ORDER.md](./DEPLOYMENT-ORDER.md) for the complete deployment guide.
> 
> 0. **00-bootstrap/** - Create Terraform state storage (run once)
> 1. **01-foundation/** - Deploy management groups & policies first
> 2. **02-landing-zones/** - Place subscription in landing zone second  
> 3. **03-workloads/** - Deploy application resources third

## 📖 About This Repository

This repository demonstrates deploying **Azure Landing Zones** using **Azure Verified Modules (AVM)** with Terraform. It creates a Cloud Adoption Framework (CAF)-aligned management group hierarchy and applies baseline governance policies.

**Key Features:**
- ✅ Production-ready Azure Landing Zone implementation
- ✅ Uses official Azure Verified Modules (AVM)
- ✅ Wrapper module pattern for version control and customization
- ✅ Separate corporate and online landing zones
- ✅ Complete networking and monitoring infrastructure
- ✅ Example workload deployments
- ✅ Comprehensive documentation

## 🏗️ Architecture

This deployment creates the following management group hierarchy:

```
Tenant Root
└── ALZ Root
    ├── Platform
    │   ├── Management
    │   ├── Connectivity
    │   └── Identity
    ├── Landing Zones
    │   ├── Corp
    │   └── Online
    ├── Sandbox
    └── Decommissioned
```

## 📦 Azure Verified Module Used

This demo uses the official **AVM Pattern Module for Azure Landing Zones**:

- **Module**: `Azure/avm-ptn-alz/azurerm`
- **Version**: `~> 0.14`
- **Registry**: [Terraform Registry](https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest)
- **GitHub**: [terraform-azurerm-avm-ptn-alz](https://github.com/Azure/terraform-azurerm-avm-ptn-alz)

### Key Features

✅ CAF-aligned management group hierarchy  
✅ Baseline Azure Policy definitions and assignments  
✅ Policy role assignments with managed identities  
✅ Customizable policy parameters and enforcement  
✅ Built-in retry logic for resilient deployments  

## 📋 Prerequisites

Before you begin, ensure you have:

1. **Azure Subscription** with appropriate permissions
   - Tenant Root Management Group access (Owner or Contributor)
   - `Microsoft.Management/managementGroups/*` permissions

2. **Terraform** installed (>= 1.3.0)
   ```powershell
   # Install using winget
   winget install Hashicorp.Terraform
   
   # Verify installation
   terraform version
   ```

3. **Azure CLI** installed and authenticated
   ```powershell
   # Install Azure CLI
   winget install Microsoft.AzureCLI
   
   # Login to Azure
   az login
   
   # Set your subscription
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```

4. **Required Permissions**
   - Management Group Contributor or Owner at the tenant root
   - Policy Contributor at the management group scope

## 🚀 Quick Start

### 1. Clone or Download This Repository

```powershell
git clone https://github.com/yourorg/acme-avm-alz-demo.git
cd acme-avm-alz-demo
```

### 2. Configure Variables

Copy the example variables file and customize it:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
default_location = "eastus"
security_contact_email = "security@acme.com"
allowed_locations = [
  "eastus",
  "eastus2",
  "centralus",
  "westus2"
]
```

### 3. Initialize Terraform

```powershell
terraform init
```

This will:
- Download the AVM module
- Download the ALZ provider
- Initialize the backend

### 4. Review the Plan

```powershell
terraform plan -out=tfplan
```

Review the planned changes. This will create:
- Management groups (Platform, Landing Zones, etc.)
- Policy definitions
- Policy assignments
- Policy role assignments

### 5. Apply the Configuration

```powershell
terraform apply tfplan
```

⏱️ **Deployment Time**: 10-15 minutes

### 6. Verify Deployment

Check the management groups in Azure Portal:

```powershell
# List management groups
az account management-group list --output table

# View specific management group
az account management-group show --name alz -e -r
```

## 📁 Project Structure

```
acme-avm-alz-demo/
├── main.tf                      # Main Terraform configuration with AVM module
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── terraform.tfvars.example     # Example variable values
├── .gitignore                   # Git ignore file
└── README.md                    # This file
```

## 🎯 Key Features Demonstrated

### 1. Management Group Hierarchy

The module automatically creates a CAF-aligned hierarchy:

- **Platform**: For shared platform services
  - Management: Centralized logging and monitoring
  - Connectivity: Hub networking and connectivity
  - Identity: Identity and access management
- **Landing Zones**: For application workloads
  - Corp: Corporate/on-premises connected workloads
  - Online: Internet-facing workloads
- **Sandbox**: For experimentation and testing
- **Decommissioned**: For resources being retired

### 2. Policy Governance

Baseline policies are automatically deployed:

- **Security**: Deny public IP addresses, require encryption
- **Compliance**: Allowed locations, required tags
- **Monitoring**: Enable Azure Monitor, diagnostic settings
- **Networking**: NSG rules, Azure Firewall policies

### 3. Policy Customization

The configuration demonstrates how to modify policies:

```hcl
policy_assignments_to_modify = {
  alzroot = {
    policy_assignments = {
      Deny-Public-IP = {
        enforcement_mode = "Default"
        parameters = {
          effect = jsonencode({ value = "Deny" })
        }
      }
    }
  }
}
```

## 🔧 Customization Guide

### Modify Policy Parameters

Edit `main.tf` to customize policy assignments:

```hcl
policy_assignments_to_modify = {
  landingzones = {
    policy_assignments = {
      "Your-Policy-Name" = {
        enforcement_mode = "Default"  # or "DoNotEnforce"
        parameters = {
          parameterName = jsonencode({ value = "parameterValue" })
        }
      }
    }
  }
}
```

### Add Subscription Placement

Place subscriptions into management groups:

```hcl
module "alz" {
  # ... other configuration ...
  
  subscription_placement = {
    prod_subscription = {
      subscription_id       = "00000000-0000-0000-0000-000000000000"
      management_group_name = "corp"
    }
    dev_subscription = {
      subscription_id       = "11111111-1111-1111-1111-111111111111"
      management_group_name = "online"
    }
  }
}
```

### Configure Hierarchy Settings

```hcl
management_group_hierarchy_settings = {
  default_management_group_name            = "alz"
  require_authorization_for_group_creation = true
}
```

## 📊 Outputs

After deployment, the following outputs are available:

| Output | Description |
|--------|-------------|
| `management_group_ids` | Map of management group names to resource IDs |
| `policy_assignment_ids` | Map of policy assignment names to resource IDs |
| `policy_definition_ids` | Map of custom policy definitions to resource IDs |
| `policy_set_definition_ids` | Map of policy initiatives to resource IDs |
| `policy_role_assignment_ids` | Map of policy role assignments to resource IDs |

View outputs:

```powershell
terraform output
```

## 🧹 Clean Up

To remove all resources:

```powershell
terraform destroy
```

⚠️ **Warning**: This will delete all management groups and policy assignments. Ensure you have backups and understand the impact.

## 📞 Support & Community

- **Issues**: Report bugs or request features via [GitHub Issues](../../issues)
- **Discussions**: Ask questions in [GitHub Discussions](../../discussions)
- **Contributing**: See [CONTRIBUTING.md](./CONTRIBUTING.md)
- **Security**: See [SECURITY.md](./SECURITY.md) for security policies

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/)
- Follows [Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/) best practices
- Uses [Terraform](https://www.terraform.io/) for infrastructure as code

---

**Emergent Software** - Building the future of cloud infrastructure

For more information, visit [emergentsoftware.net](https://emergentsoftware.net)

### Azure Verified Modules
- [AVM Homepage](https://azure.github.io/Azure-Verified-Modules/)
- [AVM Terraform Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/)
- [ALZ Pattern Module Documentation](https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest)

### Azure Landing Zones
- [Azure Landing Zones Overview](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [CAF Enterprise-Scale](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/)
- [Management Group Best Practices](https://learn.microsoft.com/azure/governance/management-groups/overview)

### Terraform Best Practices
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🤝 Contributing

This is a demonstration repository. For contributions to the AVM modules themselves, please visit:
- [Azure Verified Modules GitHub](https://github.com/Azure/Azure-Verified-Modules)

## 📝 License

This demo code is provided as-is under the MIT License.

## ⚠️ Important Notes

1. **`.alzlib` Directory**: The module automatically downloads the ALZ library to `.alzlib/`. This directory is excluded in `.gitignore` and should not be committed.

2. **Terraform State**: Use remote state (Azure Storage Account) for production deployments.

3. **Permissions**: Ensure you have the necessary permissions before deploying. Management group operations require elevated privileges.

4. **Validation**: Always run `terraform plan` before `terraform apply` to review changes.

5. **Testing**: Test in a non-production environment first before deploying to production tenants.

6. **Credentials**: Never commit sensitive data (subscription IDs, tenant IDs, credentials) to version control. All example files use placeholder values.

## 🔒 Security Considerations

- Review [SECURITY.md](./SECURITY.md) for security best practices
- Use Azure Key Vault for secrets management
- Enable Azure Security Center
- Implement least privilege access
- Regularly review policy compliance
- Use Terraform Cloud or Azure DevOps for secure state management

## 🆘 Troubleshooting

### "Authorization Failed" Errors

Ensure you have permissions at the tenant root level:

```powershell
az role assignment create \
  --assignee "your-user@domain.com" \
  --role "Owner" \
  --scope "/providers/Microsoft.Management/managementGroups/YOUR_TENANT_ID"
```

### "Management Group Already Exists"

If management groups already exist, the module will manage them. To import existing resources:

```powershell
terraform import 'module.alz.azapi_resource.management_groups_level_0["alz"]' \
  '/providers/Microsoft.Management/managementGroups/alz'
```

### Terraform Lock File

If you encounter lock file issues:

```powershell
Remove-Item .terraform.lock.hcl
terraform init -upgrade
```

## 📧 Support

For issues with:
- **This demo**: Open an issue in this repository
- **AVM modules**: [AVM GitHub Issues](https://github.com/Azure/terraform-azurerm-avm-ptn-alz/issues)
- **Azure**: [Azure Support](https://azure.microsoft.com/support/)

---

**Built with ❤️ using Azure Verified Modules**

# Emergent Software - Azure Landing Zone Reference Implementation

> **Official Reference Implementation**
> This repository is Emergent Software's official reference implementation for deploying Azure Landing Zones using Azure Verified Modules (AVM) and Terraform.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Azure Verified Modules](https://img.shields.io/badge/AVM-Verified-0078D4?logo=microsoft-azure)](https://azure.github.io/Azure-Verified-Modules/)

> **⚠️ IMPORTANT: Deployment Order**
> See [DEPLOYMENT-ORDER.md](./DEPLOYMENT-ORDER.md) for the complete deployment guide.
>
> 0. **00-pre-bootstrap/** - Create Azure subscriptions (run once, if needed)
> 1. **00-bootstrap/** - Create Terraform state storage (run once)
> 2. **01-foundation/** - Deploy management groups & policies first
> 3. **02-landing-zones/** - Place subscription in landing zone second
> 4. **03-workloads/** - Deploy application resources third

## 📖 About This Repository

This repository demonstrates deploying **Azure Landing Zones** using **Azure Verified Modules (AVM)** with Terraform. It creates a Cloud Adoption Framework (CAF)-aligned management group hierarchy and applies baseline governance policies.

**Key Features:**
- ✅ Production-ready Azure Landing Zone implementation
- ✅ Uses official Azure Verified Modules (AVM)
- ✅ Wrapper module pattern for version control and customization
- ✅ Simplified workloads landing zone
- ✅ Complete networking and monitoring infrastructure
- ✅ Example workload deployments
- ✅ **FinOps toolkit integration** (cost optimization, tagging policies, anomaly detection)
- ✅ Comprehensive documentation

## 🏗️ Architecture

This deployment creates the following infrastructure:

### Management Group Hierarchy
```
Tenant Root
└── ACME ALZ Root
    ├── Platform
    │   ├── Management
    │   ├── Connectivity (with hub VNet + private DNS)
    │   └── Identity
    ├── Workloads
    │   └── Portals (admin + customer portals)
    ├── Sandbox
    └── Decommissioned
```

### Network Architecture (Hub-and-Spoke)
```
Connectivity Hub (10.0.0.0/16)
├── GatewaySubnet (10.0.0.0/27)
├── AzureFirewallSubnet (10.0.1.0/26)
├── AzureBastionSubnet (10.0.2.0/26)
├── Shared Services (10.0.10.0/24)
├── NVA (10.0.11.0/24)
└── Management (10.0.12.0/24)

Private DNS Zones (Connectivity Subscription)
├── privatelink.azurestaticapps.net
├── privatelink.blob.core.windows.net
├── privatelink.database.windows.net
└── ... (see 02-landing-zones/connectivity/README.md)

Portals Admin Dev Spoke (10.100.0.0/16)
├── Apps (10.100.1.0/24)
├── Private Endpoints (10.100.2.0/24)
├── VNet Integration (10.100.3.0/24)
└── Data (10.100.4.0/24)

Portals Customer Dev Spoke (10.110.0.0/16)
├── Apps (10.110.1.0/24)
├── Private Endpoints (10.110.2.0/24)
├── VNet Integration (10.110.3.0/24)
└── Data (10.110.4.0/24)
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
git clone https://github.com/yourorg/emergent-azure-landing-zone.git
cd emergent-azure-landing-zone
```

### 2. Bootstrap - Terraform State Storage (One-Time)

```powershell
cd 00-bootstrap
terraform init
terraform apply -auto-approve
cd ..
```

This creates the Azure Storage account for remote Terraform state.

### 3. Foundation - Management Groups & Policies

```powershell
cd 01-alz-foundation
terraform init
terraform apply -auto-approve
cd ..
```

This deploys the Azure Landing Zone management group hierarchy and governance policies.

### 4. Landing Zones - Network Infrastructure

```powershell
# Deploy hub VNet with private DNS zones
cd 02-landing-zones/connectivity
terraform init -backend-config="key=tfstate-connectivity"
terraform apply -var-file="terraform.tfvars" -auto-approve

# Deploy portal spoke VNets in parallel
cd ../workloads/portals-admin-dev
terraform init -backend-config="key=tfstate-portals-admin-dev"
Start-Job { Set-Location $using:PWD; terraform apply -var-file="terraform.tfvars" -auto-approve }

cd ../portals-customer-dev
terraform init -backend-config="key=tfstate-portals-customer-dev"
Start-Job { Set-Location $using:PWD; terraform apply -var-file="terraform.tfvars" -auto-approve }

# Wait for parallel jobs
Get-Job | Wait-Job
Get-Job | Receive-Job
cd ../../..
```

### 5. Workloads - Application Deployments

```powershell
# Deploy admin portal Static Web App
cd 03-workloads/portals/admin-portal
terraform init -backend-config="key=tfstate-admin-portal-dev"
terraform apply -var-file="dev.tfvars" -auto-approve

# Deploy customer portal Static Web App
cd ../customer-portal
terraform init -backend-config="key=tfstate-customer-portal-dev"
terraform apply -var-file="dev.tfvars" -auto-approve
cd ../../..
```

### 6. Verify Deployment

```powershell
# Check management groups
az account management-group list --output table

# Check network infrastructure
az network vnet list --query "[].{Name:name, ResourceGroup:resourceGroup, AddressSpace:addressSpace.addressPrefixes[0]}" -o table

# Check private DNS zones
az network private-dns zone list --resource-group $(az group list --query "[?contains(name, 'privatedns')].name" -o tsv) -o table

# Check Static Web Apps
az staticwebapp list --query "[].{Name:name, ResourceGroup:resourceGroup, DefaultHostname:defaultHostname}" -o table
```

> **Note**: See [DEPLOYMENT-ORDER.md](DEPLOYMENT-ORDER.md) for detailed step-by-step deployment instructions including VNet peering configuration.

## 📁 Project Structure

```
emergent-azure-landing-zone/
├── 00-bootstrap/                     # Terraform state storage (deploy once)
│   ├── main.tf
│   ├── outputs.tf
│   └── README.md
│
├── 01-alz-foundation/                # ALZ management groups & policies
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
│
├── 02-landing-zones/                 # Network infrastructure per subscription
│   ├── connectivity/                 # Hub VNet + Private DNS zones
│   │   ├── main.tf
│   │   ├── network.tf               # Hub VNet (10.0.0.0/16)
│   │   ├── private-dns.tf           # Centralized private DNS
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── workloads/
│   │   ├── portals-admin-dev/       # Admin portal spoke (10.100.0.0/16)
│   │   │   ├── main.tf
│   │   │   ├── network.tf
│   │   │   └── README.md
│   │   │
│   │   └── portals-customer-dev/    # Customer portal spoke (10.110.0.0/16)
│   │       ├── main.tf
│   │       ├── network.tf
│   │       └── README.md
│   │
│   ├── ipam.yaml                    # IP address management manifest
│   └── README.md
│
├── 03-workloads/                     # Application deployments
│   └── portals/
│       ├── admin-portal/            # Admin Static Web App
│       │   ├── main.tf
│       │   ├── dev.tfvars
│       │   └── prod.tfvars
│       │
│       └── customer-portal/         # Customer Static Web App
│           ├── main.tf
│           ├── dev.tfvars
│           └── prod.tfvars
│
├── shared-modules/                   # Reusable module wrappers
│   ├── virtual-network/             # AVM VNet wrapper
│   ├── resource-group/              # AVM RG wrapper
│   ├── static-web-app/              # Custom Static Web App module
│   ├── log-analytics-workspace/
│   └── naming/                      # Azure naming convention
│
├── DEPLOYMENT-ORDER.md              # Step-by-step deployment guide
├── QUICKSTART.md                    # Quick start guide
└── README.md                        # This file
```

## 🎯 Key Features Demonstrated

### 1. Management Group Hierarchy

Azure Landing Zone management groups aligned with Cloud Adoption Framework:

- **Platform**: Shared platform services
  - Connectivity: Hub networking, private DNS zones, network security
  - Management: Centralized logging and monitoring (planned)
  - Identity: Identity and access management (planned)
- **Workloads**: For all application workloads
- **Sandbox**: Experimentation and testing (planned)
- **Decommissioned**: Resources being retired (planned)

### 2. Network Architecture

Hub-and-spoke topology with centralized private DNS:

- **Hub VNet (10.0.0.0/16)**: Centralized connectivity with Gateway, Firewall, Bastion
- **Private DNS Zones**: 11 zones for Azure Private Link services (Static Web Apps, Storage, SQL, Cosmos DB, Key Vault, etc.)
- **Spoke VNets**: Isolated networks per workload subscription
  - Admin Portal Dev (10.100.0.0/16): Admin-facing applications
  - Customer Portal Dev (10.110.0.0/16): Customer-facing applications
- **IPAM**: Programmatic IP allocation via `ipam.yaml`

### 3. Policy Governance

Baseline Azure policies deployed via ALZ module:

- **Security**: Deny public IP addresses, require encryption
- **Compliance**: Allowed locations, required tags
- **Monitoring**: Enable Azure Monitor, diagnostic settings (planned)
- **Networking**: NSG rules, Azure Firewall policies (planned)
- **FinOps Tagging**: Required cost allocation tags (CostCenter, Environment, Owner, Project)
- **Tag Inheritance**: Auto-inherit CostCenter tag from resource group to resources

### 4. FinOps Cost Management

Comprehensive cost optimization and governance:

- **Budgets & Alerts**: 7 subscription-level budgets with actual (120%) and forecasted (130%) thresholds
- **Reserved Instance Management**: RI monitoring for 5 production subscriptions with 3-tier approval workflow (<$10K, $10K-$50K, >$50K)
- **Cost Anomaly Detection**: AI-powered alerts for unusual spending patterns across 6 subscriptions
- **Azure Advisor Integration**: Cost recommendations monitoring with 6 optimization types (40-72% potential savings)
- **Tagging Policies**: Enforce cost allocation tags for chargeback/showback (CostCenter, Environment, Owner, Application)
- **Azure Policy Governance**: 80+ policies including Audit-UnusedResources, Audit-AzureHybridBenefit, Deny-UnmanagedDisk
- **Infracost CI/CD**: Cost estimation in pull requests before deployment
- **FinOps Hub (✅ Deployed)**: Advanced analytics with Power BI dashboards, centralized cost data ingestion, FOCUS schema, solves CSP subscription visibility limitations
- **Azure Optimization Engine (✅ Deployed)**: 50+ automated runbooks, VM rightsizing, unused resource detection, 11 Azure Workbooks, SQL database with recommendation history

**FinOps Hub Resources:**
- Resource Group: `acme-rg-management-finops-hub-prod-eastus`
- Data Factory: `acme-finopshub-mkkac1u6-engine-3funlapkpooie`
- Daily cost exports with automated ETL pipeline

**Azure Optimization Engine Resources:**
- Resource Group: `acme-rg-management-finops-aoe-prod-eastus`
- Automation Account: `acme-auto-finops-aoe` (50+ runbooks)
- SQL Database: `acme-sql-finops-aoe/azureoptimization`
- Log Analytics: `acme-la-finops-aoe`

**Known Limitation**: Some subscriptions (CSP/Cloud Solution Provider) show "(Not supported)" when viewing costs at management group level. This is an Azure Cost Management API limitation. Individual subscription costs are fully visible. ✅ **FinOps Hub is deployed** and provides unified cost visibility across all subscription types.

See [docs/FINOPS.md](docs/FINOPS.md) for detailed implementation guide and [docs/FINOPS-RI-APPROVAL-WORKFLOW.md](docs/FINOPS-RI-APPROVAL-WORKFLOW.md) for Reserved Instance purchase process.

### 5. Reusable Modules

Azure Verified Modules (AVM) wrappers for consistency:

- **Resource Groups**: Standardized naming and tagging
- **Virtual Networks**: Hub-and-spoke patterns with subnets
- **Static Web Apps**: Free tier with optional private endpoints
- **Log Analytics**: Centralized logging (planned)
- **Naming Convention**: Consistent Azure resource naming

### 6. Infrastructure as Code Best Practices

- **Remote State**: Azure Storage backend for team collaboration
- **Layered Deployment**: Bootstrap → Foundation → Landing Zones → Workloads
- **Modular Design**: Shared modules for reusability
- **IPAM**: Centralized IP address management
- **Parallel Deployments**: Concurrent spoke VNet deployments for speed
- **FinOps Integration**: Cost optimization and tagging governance from day one

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
      management_group_name = "acme-workloads"
    }
    dev_subscription = {
      subscription_id       = "11111111-1111-1111-1111-111111111111"
      management_group_name = "acme-workloads"
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

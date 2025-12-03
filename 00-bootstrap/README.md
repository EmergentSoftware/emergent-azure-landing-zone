# Bootstrap: Terraform State Storage

This directory contains the bootstrap configuration that creates the Azure Storage Account and containers for storing Terraform state files across all layers of the Azure Landing Zone deployment.

## 🎯 Purpose

The bootstrap creates:
- **Resource Group** for centralized state storage
- **Storage Account** with security best practices (encryption, soft delete, versioning)
- **Blob Containers** for each deployment layer:
  - `tfstate-foundation` - For 01-foundation layer
  - `tfstate-landing-zones` - For 02-landing-zones layer
  - `tfstate-workloads` - For 03-workloads layer

## ⚠️ Important Notes

- **Run this FIRST** before deploying any other layers
- **Initial deployment uses LOCAL state** - Comment out the backend block in main.tf for first run
- **After creation, migrate to REMOTE state** - Uncomment backend block and migrate state
- **One-time setup** - Rarely needs to be run again
- **Storage account name** is globally unique (random suffix added automatically)

## 🚀 Quick Start

### 1. Configure Variables

```powershell
cd 00-bootstrap
Copy-Item terraform.tfvars.example terraform.tfvars
code terraform.tfvars
```

Update `terraform.tfvars` with your values:
```hcl
subscription_id = "your-subscription-id"
location        = "eastus"
environment     = "prod"
```

### 2. Initial Deployment (Local State)

**IMPORTANT:** For the first deployment, comment out the `backend "azurerm"` block in `main.tf`

```powershell
# Initialize with local backend
terraform init

# Review plan
terraform plan -var-file="terraform.tfvars"

# Deploy (creates storage account and containers)
terraform apply -var-file="terraform.tfvars"
```

### 3. Migrate to Remote State

After the storage account and `tfstate-bootstrap` container are created:

```powershell
# Uncomment the backend "azurerm" block in main.tf

# Migrate state from local to remote
terraform init -backend-config="backend.tfbackend" -migrate-state
```

Answer `yes` when prompted to copy state to the new backend.

### 4. Save Outputs

After migration, save the backend configuration:

```powershell
# Display instructions
terraform output -raw instructions

# Save backend config for reference
terraform output -json > backend-config.json
```

## 📋 Next Steps

After bootstrap completes:

1. **Copy the backend configuration** from the output
2. **Add backend block** to each layer's `main.tf`:
   - `01-foundation/main.tf`
   - `02-landing-zones/corp/main.tf`
   - `02-landing-zones/online/main.tf`
   - `03-workloads/web-app/main.tf`

3. **Run `terraform init`** in each layer to migrate to remote state

## 🔧 Backend Configuration

After running bootstrap, add this to your Terraform layers:

### For 01-foundation:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate123456"  # From bootstrap output
    container_name       = "tfstate-foundation"
    key                  = "foundation.tfstate"
  }
}
```

### For 02-landing-zones/corp:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate123456"  # From bootstrap output
    container_name       = "tfstate-landing-zones"
    key                  = "corp.tfstate"
  }
}
```

### For 03-workloads/web-app:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate123456"  # From bootstrap output
    container_name       = "tfstate-workloads"
    key                  = "web-app.tfstate"
  }
}
```

## 🔐 Security Features

The bootstrap creates a secure storage account with:

- ✅ **TLS 1.2** minimum encryption
- ✅ **HTTPS only** traffic
- ✅ **Blob versioning** enabled
- ✅ **Soft delete** (30 days retention by default)
- ✅ **Private containers** (no public access)
- ✅ **Encryption at rest** (Azure-managed keys)

## 🗑️ Teardown

⚠️ **WARNING**: Destroying the bootstrap will delete all Terraform state files!

Only run this if you're completely tearing down the environment:

```powershell
cd 00-bootstrap
terraform destroy
```

**Better approach**: Keep the state storage and just destroy the application layers.

## 📊 Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `subscription_id` | Azure subscription ID | Required |
| `resource_group_name` | Name of RG for state storage | `rg-terraform-state` |
| `location` | Azure region | `eastus` |
| `storage_account_prefix` | Prefix for storage account | `tfstate` |
| `storage_account_replication` | Replication type (LRS/GRS/ZRS) | `LRS` |
| `soft_delete_retention_days` | Retention for deleted blobs | `30` |
| `environment` | Environment tag | `prod` |
| `additional_containers` | Extra containers to create | `[]` |

## 🔍 Troubleshooting

### Storage account name already exists
- The random suffix should make this unlikely
- If it happens, modify `storage_account_prefix` in `terraform.tfvars`

### Permission errors
- Ensure you have `Contributor` or `Owner` role on the subscription
- Check Azure CLI login: `az account show`

### State lock issues
- Bootstrap uses local state, so locks shouldn't occur
- If needed, delete `.terraform` folder and re-init

## 📚 Additional Resources

- [Terraform Azure Backend Docs](https://www.terraform.io/docs/language/settings/backends/azurerm.html)
- [Azure Storage Security Best Practices](https://learn.microsoft.com/azure/storage/blobs/security-recommendations)

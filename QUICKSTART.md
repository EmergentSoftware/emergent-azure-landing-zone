# Quick Deployment Guide

## Prerequisites Check

- [ ] Terraform >= 1.3.0 installed
- [ ] Azure CLI installed
- [ ] Logged into Azure (`az login`)
- [ ] Tenant Root Management Group permissions

## Deployment Steps

### 1️⃣ Initialize

```powershell
terraform init
```

### 2️⃣ Configure Variables

```powershell
# Copy example file
Copy-Item terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
code terraform.tfvars
```

### 3️⃣ Validate

```powershell
terraform validate
```

### 4️⃣ Plan

```powershell
terraform plan -out=tfplan
```

### 5️⃣ Apply

```powershell
terraform apply tfplan
```

## Verify Deployment

```powershell
# List management groups
az account management-group list --output table

# View outputs
terraform output

# Check policy assignments
az policy assignment list --scope "/providers/Microsoft.Management/managementGroups/alz"
```

## Destroy (if needed)

```powershell
terraform destroy
```

## Common Commands

```powershell
# View current state
terraform show

# List resources
terraform state list

# View specific output
terraform output management_group_ids

# Format configuration files
terraform fmt

# Refresh state
terraform refresh
```

## Management Group Structure Created

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

## Key Policies Applied

- ✅ Deny Public IP addresses
- ✅ Enforce allowed locations
- ✅ Require encryption at rest
- ✅ Enable diagnostic settings
- ✅ Enforce HTTPS for storage
- ✅ Require tags on resources

## Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `default_location` | Azure region for resources | `eastus` |
| `security_contact_email` | Security contact email | `security@acme.com` |
| `allowed_locations` | Allowed Azure regions | `["eastus", "eastus2", ...]` |
| `enable_telemetry` | Enable module telemetry | `true` |

## Troubleshooting

**Permission Issues:**
```powershell
# Check current user
az ad signed-in-user show

# Check role assignments
az role assignment list --assignee "your-email@domain.com"
```

**State Lock Issues:**
```powershell
# Remove lock file and re-initialize
Remove-Item .terraform.lock.hcl -Force
terraform init -upgrade
```

**Module Download Issues:**
```powershell
# Clear module cache
Remove-Item .terraform -Recurse -Force
terraform init
```

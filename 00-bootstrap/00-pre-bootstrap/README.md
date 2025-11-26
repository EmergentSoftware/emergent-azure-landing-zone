# Pre-Bootstrap: Azure Subscription Creation

This module creates Azure subscriptions required for the Azure Landing Zone deployment. It must be run **before** the bootstrap layer.

## Purpose

Creates the necessary Azure subscriptions:
- **Management Subscription** - For Terraform state storage (bootstrap)
- **Corp Subscriptions** - For corporate landing zones
- **Online Subscriptions** - For online/internet-facing landing zones

## Prerequisites

### Required Permissions

You need **one** of the following:

1. **Enterprise Agreement (EA)**
   - Enrollment Account Owner or Account Owner role
   - Obtain billing scope: `/providers/Microsoft.Billing/billingAccounts/{billingAccountId}/enrollmentAccounts/{enrollmentAccountId}`

2. **Microsoft Customer Agreement (MCA)**
   - Billing profile contributor or higher
   - Obtain billing scope: `/providers/Microsoft.Billing/billingAccounts/{billingAccountId}/billingProfiles/{billingProfileId}/invoiceSections/{invoiceSectionId}`

3. **Cloud Solution Provider (CSP)**
   - Partner Center admin or admin agent role
   - Customer tenant ID
   - No billing scope required (subscriptions created in customer tenant)

### Get Your Billing Scope

**For EA:**
```bash
# List billing accounts
az billing account list

# List enrollment accounts
az billing enrollment-account list --billing-account-name {billingAccountId}

# Construct billing scope
# Format: /providers/Microsoft.Billing/billingAccounts/{billingAccountId}/enrollmentAccounts/{enrollmentAccountId}
```

**For MCA:**
```bash
# List billing accounts
az billing account list

# List billing profiles
az billing profile list --account-name {billingAccountId}

# List invoice sections
az billing invoice section list --account-name {billingAccountId} --profile-name {billingProfileId}

# Construct billing scope
# Format: /providers/Microsoft.Billing/billingAccounts/{billingAccountId}/billingProfiles/{billingProfileId}/invoiceSections/{invoiceSectionId}
```

**For CSP:**
```bash
# Get customer tenant ID (run in Partner Center context)
az account list --query "[?tenantId=='customer-tenant-id'].{Name:name, TenantId:tenantId}"

# No billing scope needed - subscriptions are created directly in customer tenant
```

## Usage

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your billing scope and configuration
```

### 2. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### 3. Capture Outputs

```bash
terraform output -json > subscriptions.json
```

### 4. Use Outputs in Bootstrap

The subscription IDs can be used in the bootstrap layer:

```bash
# Get management subscription ID
terraform output -raw management_subscription_id

# Use in bootstrap terraform.tfvars
subscription_id = "subscription-id-from-output"
```

## Configuration

### Minimal Configuration (EA/MCA)

```hcl
billing_model              = "EA" # or "MCA"
tenant_id                  = "your-tenant-id"
management_subscription_id = "existing-subscription-id"
billing_scope_id          = "your-billing-scope"
```

### CSP Configuration

```hcl
billing_model              = "CSP"
tenant_id                  = "your-partner-tenant-id"
management_subscription_id = "existing-partner-subscription-id"
csp_customer_tenant_id    = "customer-tenant-id"
# No billing_scope_id needed for CSP
```

### Full Configuration (EA/MCA)

```hcl
billing_model = "EA" # or "MCA"

# Create management subscription
create_management_subscription = true
management_subscription_alias  = "sub-management-001"
management_subscription_name   = "Management"

# Corp subscriptions
corp_subscriptions = {
  corp_001 = {
    alias        = "sub-corp-001"
    display_name = "Corp-001"
    workload     = "Production"
  }
  corp_002 = {
    alias        = "sub-corp-002"
    display_name = "Corp-Dev"
    workload     = "DevTest"
  }
}

# Online subscriptions
online_subscriptions = {
  online_001 = {
    alias        = "sub-online-001"
    display_name = "Online-Prod"
    workload     = "Production"
  }
}
```

### PowerShell Script Examples

**For CSP:**
```powershell
.\create-subscriptions.ps1 `
  -BillingModel CSP `
  -TenantId "your-partner-tenant-id" `
  -CustomerTenantId "customer-tenant-id" `
  -CreateManagement `
  -CreateCorp 2 `
  -CreateOnline 1
```

**For EA:**
```powershell
.\create-subscriptions.ps1 `
  -BillingModel EA `
  -BillingScope "/providers/Microsoft.Billing/..." `
  -TenantId "your-tenant-id" `
  -CreateManagement `
  -CreateCorp 2 `
  -CreateOnline 1
```

## Alternative: Manual Subscription Creation

If you prefer to create subscriptions manually:

### Azure Portal
1. Navigate to **Subscriptions**
2. Click **+ Add**
3. Fill in subscription details
4. Note the subscription IDs for terraform.tfvars

### Azure CLI

```bash
# Create subscription (EA)
az account create \
  --enrollment-account-name "YOUR_ENROLLMENT_ACCOUNT" \
  --offer-type "MS-AZR-0017P" \
  --display-name "Management"

# Create subscription (MCA)
az account alias create \
  --billing-scope "/providers/Microsoft.Billing/billingAccounts/..." \
  --display-name "Management" \
  --workload "Production" \
  --name "sub-management-001"
```

## Deployment Order

```
00-pre-bootstrap (this)  → Creates subscriptions
         ↓
01-bootstrap             → Creates state storage
         ↓
02-foundation           → Creates management groups
         ↓
03-landing-zones        → Configures landing zones
         ↓
04-workloads            → Deploys applications
```

## Outputs

| Name | Description |
|------|-------------|
| management_subscription_id | Management subscription ID for bootstrap |
| corp_subscription_ids | Map of corp subscription IDs |
| online_subscription_ids | Map of online subscription IDs |
| all_subscription_ids | All created subscription IDs |

## Important Notes

1. **Subscription creation is asynchronous** - It may take a few minutes for subscriptions to be fully provisioned
2. **Billing scope is required** - You must have the appropriate billing scope and permissions
3. **Local state only** - This module uses local state since no remote backend exists yet
4. **One-time operation** - Subscriptions persist; you can destroy this module after creation

## Troubleshooting

### Error: "Insufficient permissions"
- Verify you have Enrollment Account Owner (EA) or Billing Profile Contributor (MCA) role
- Check billing scope format is correct

### Error: "Billing scope not found"
- Run the Azure CLI commands above to verify billing scope
- Ensure billing account is active

### Error: "Subscription alias already exists"
- Change the alias name in terraform.tfvars
- Or import existing subscription: `terraform import azapi_resource.management_subscription[0] /providers/Microsoft.Subscription/aliases/sub-management-001`

## Security

- Subscription creation requires elevated permissions
- Consider using a service principal with limited scope
- Review Azure RBAC after subscription creation

## References

- [Azure Subscription Aliases API](https://learn.microsoft.com/azure/cost-management-billing/manage/programmatically-create-subscription)
- [Enterprise Agreement Subscriptions](https://learn.microsoft.com/azure/cost-management-billing/manage/programmatically-create-subscription-enterprise-agreement)
- [Microsoft Customer Agreement Subscriptions](https://learn.microsoft.com/azure/cost-management-billing/manage/programmatically-create-subscription-microsoft-customer-agreement)

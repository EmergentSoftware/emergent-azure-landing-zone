# Azure Landing Zone - Deployment Order

This guide explains the correct sequence for deploying the Azure Landing Zone infrastructure and workloads.

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Step 0: Bootstrap (One-Time Setup)                         │
│ • Create Storage Account for Terraform state               │
│ • Create blob containers for each layer                    │
│ • Configure remote backend                                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 1: ALZ Foundation                                      │
│ • Management Groups                                         │
│ • Policy Definitions                                        │
│ • Policy Assignments                                        │
│ • Role Assignments                                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 2: Landing Zone Subscription Placement                │
│ • Associate subscription with management group              │
│ • Create shared Log Analytics workspace                    │
│ • Inherit policies from management group hierarchy         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 3: Workload Deployment                                │
│ • Deploy application resources                             │
│ • Use AVM wrapper modules                                  │
│ • Connect to shared monitoring                             │
└─────────────────────────────────────────────────────────────┘
```

## Step 0: Bootstrap Terraform State Storage (One-Time Setup)

**Directory**: `00-bootstrap/`

**Purpose**: Creates Azure Storage Account and containers for storing Terraform state files.

**Creates**:
- Resource group for state storage
- Storage account with versioning and soft delete
- Blob containers for foundation, landing zones, and workloads

**Commands**:
```bash
cd 00-bootstrap
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your subscription ID
terraform init
terraform plan
terraform apply
```

**Duration**: ~2-3 minutes

**Verify**:
```bash
# Save the storage account name for backend configuration
terraform output storage_account_name

# View backend configuration instructions
terraform output -raw instructions
```

**Next Steps**:
- Copy the backend configuration from output
- Add backend blocks to 01-foundation, 02-landing-zones, and 03-workloads
- See `00-bootstrap/README.md` for detailed backend setup

**Wait Time**: Complete backend configuration before Step 1

---

## Step 1: Deploy ALZ Foundation

**Directory**: `01-foundation/`

**Purpose**: Creates the management group hierarchy and applies governance policies.

**Creates**:
- Management group structure (Platform, Landing Zones, etc.)
- Policy definitions and assignments
- Role-based access control (RBAC)

**Commands**:
```bash
cd 01-foundation
terraform init
terraform plan
terraform apply
```

**Duration**: ~5-10 minutes (540 resources)

**Verify**:
```bash
# Check management groups created
terraform output management_group_ids

# View in Azure Portal
# Azure Portal → Management Groups → acme
```

**Wait Time**: None - proceed immediately to Step 2

---

## Step 2: Place Subscription in Landing Zone

**Directory**: `02-landing-zones/`

**Purpose**: Associates your subscription with the appropriate landing zone management group and creates shared monitoring resources.

**Prerequisites**:
- Step 1 completed
- Know which management group to use (`acme-landingzones-corp` or `acme-landingzones-online`)

**Configuration**:
```bash
cd ../02-landing-zones
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
subscription_id                    = "00000000-0000-0000-0000-000000000000" # Your subscription ID
tenant_id                          = "00000000-0000-0000-0000-000000000000" # Your tenant ID
workload_subscription_id           = "00000000-0000-0000-0000-000000000000" # Your subscription ID
landing_zone_name                  = "corp-web-apps"
landing_zone_management_group_name = "acme-landingzones-corp"  # ← From Step 1
create_log_analytics               = true
```

**Commands**:
```bash
terraform init
terraform plan
terraform apply
```

**Duration**: ~2-3 minutes

**Verify**:
```bash
# Get Log Analytics workspace ID (you'll need this for workloads)
terraform output -raw log_analytics_workspace_resource_id

# Check subscription placement
az account management-group show --name acme-landingzones-corp --expand
```

**Save This Value**:
```bash
# Copy the Log Analytics workspace ID
terraform output -raw log_analytics_workspace_resource_id > ../03-workloads/web-app/.log-analytics-id
```

**Wait Time**: 2-5 minutes for policy assignments to propagate

---

## Step 3: Deploy Workloads

**Directory**: `03-workloads/web-app/`

**Purpose**: Deploys application resources into the landing zone.

**Prerequisites**:
- Step 1 completed
- Step 2 completed
- Log Analytics workspace ID from Step 2

**Configuration**:
```bash
cd ../03-workloads/web-app
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
subscription_id = "00000000-0000-0000-0000-000000000000" # Your subscription ID

workload_name = "demo-web"
environment   = "dev"
location      = "eastus"

# From 02-landing-zones output (Step 2)
log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-corp-web-apps-monitoring-eastus/providers/Microsoft.OperationalInsights/workspaces/log-corp-web-apps-eastus"

app_service_os_type = "Linux"
app_service_sku_name = "B1"

enable_application_insights = true
enable_managed_identity = true
```

**Commands**:
```bash
terraform init
terraform plan
terraform apply
```

**Duration**: ~3-5 minutes

**Verify**:
```bash
# Get web app URL
terraform output -raw web_app_default_hostname

# Test the app
curl https://$(terraform output -raw web_app_default_hostname)
```

---

## Complete Deployment Script

Save this as `deploy-all.sh`:

```bash
#!/bin/bash
set -e

echo "========================================="
echo "Azure Landing Zone - Complete Deployment"
echo "========================================="

# Step 1: ALZ Foundation
echo ""
echo "Step 1/3: Deploying ALZ Foundation..."
cd alz-foundation
terraform init
terraform apply -auto-approve
echo "✓ ALZ Foundation deployed"

# Step 2: Landing Zone
echo ""
echo "Step 2/3: Placing subscription in landing zone..."
cd ../02-landing-zones
if [ ! -f terraform.tfvars ]; then
  cp terraform.tfvars.example terraform.tfvars
  echo "⚠ Please edit 02-landing-zones/terraform.tfvars and run this script again"
  exit 1
fi
terraform init
terraform apply -auto-approve
LOG_ANALYTICS_ID=$(terraform output -raw log_analytics_workspace_resource_id)
echo "✓ Landing zone configured"
echo "✓ Log Analytics Workspace: $LOG_ANALYTICS_ID"

# Wait for policies to propagate
echo ""
echo "Waiting 60 seconds for policies to propagate..."
sleep 60

# Step 3: Workload
echo ""
echo "Step 3/3: Deploying workload..."
cd ../03-workloads/web-app
if [ ! -f terraform.tfvars ]; then
  cp terraform.tfvars.example terraform.tfvars
  # Inject Log Analytics workspace ID
  echo "log_analytics_workspace_id = \"$LOG_ANALYTICS_ID\"" >> terraform.tfvars
fi
terraform init
terraform apply -auto-approve
WEB_APP_URL=$(terraform output -raw web_app_default_hostname)
echo "✓ Workload deployed"

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo "Web App URL: https://$WEB_APP_URL"
echo ""
echo "Next steps:"
echo "1. Visit https://$WEB_APP_URL to see your app"
echo "2. Check Azure Portal → Management Groups to see hierarchy"
echo "3. Check Azure Portal → Policy to see compliance status"
```

Make executable: `chmod +x deploy-all.sh`

---

## Manual Deployment Checklist

Use this checklist for manual deployments:

- [ ] **1. Review Prerequisites**
  - [ ] Azure CLI installed and logged in
  - [ ] Terraform >= 1.3.0 installed
  - [ ] Owner or Contributor role on subscription
  - [ ] User Access Administrator role for RBAC

- [ ] **2. Deploy ALZ Foundation**
  - [ ] `cd 01-foundation`
  - [ ] Review `terraform.tfvars` settings
  - [ ] `terraform init`
  - [ ] `terraform plan` (review 540 resources)
  - [ ] `terraform apply`
  - [ ] Verify management groups in Azure Portal

- [ ] **3. Deploy Landing Zone**
  - [ ] `cd ../02-landing-zones`
  - [ ] `cp terraform.tfvars.example terraform.tfvars`
  - [ ] Edit `terraform.tfvars` with correct management group name
  - [ ] `terraform init`
  - [ ] `terraform plan`
  - [ ] `terraform apply`
  - [ ] Save Log Analytics workspace ID: `terraform output -raw log_analytics_workspace_resource_id`
  - [ ] Wait 2-5 minutes for policy propagation

- [ ] **4. Deploy Workload**
  - [ ] `cd ../03-workloads/web-app`
  - [ ] `cp terraform.tfvars.example terraform.tfvars`
  - [ ] Edit `terraform.tfvars` with Log Analytics ID from Step 3
  - [ ] `terraform init`
  - [ ] `terraform plan`
  - [ ] `terraform apply`
  - [ ] Test web app: `curl https://$(terraform output -raw web_app_default_hostname)`

- [ ] **5. Verify Deployment**
  - [ ] Check management group hierarchy in Portal
  - [ ] Review policy compliance status
  - [ ] Verify web app is running
  - [ ] Check Application Insights for telemetry
  - [ ] Review Log Analytics for diagnostic logs

---

## Troubleshooting

### Step 1 Fails: ALZ Foundation

**Error**: Policy library not found
```
Solution: Verify ALZ provider configuration in 01-foundation/main.tf
Check that library_references uses platform/alz@2025.09.0
```

**Error**: Insufficient permissions
```
Solution: Verify you have Owner role on subscription
Run: az role assignment create --assignee <your-user-id> --role Owner --scope /subscriptions/<sub-id>
```

### Step 2 Fails: Landing Zone

**Error**: Management group not found
```
Solution: Wait for ALZ foundation to complete, then retry
Check: terraform output -raw management_group_ids (in 01-foundation/)
```

**Error**: Cannot move subscription
```
Solution: Verify permissions on subscription
Run: az account show --subscription <sub-id> --query "{name:name, state:state}"
```

### Step 3 Fails: Workload

**Error**: Policy violation (e.g., location not allowed)
```
Solution: Check policy assignments in Azure Portal → Policy
Verify workload location matches allowed locations in policy
```

**Error**: Cannot write to Log Analytics
```
Solution: Verify workspace ID is correct
Check: terraform output -raw log_analytics_workspace_resource_id (in 02-landing-zones/)
Ensure workspace exists and managed identity has access
```

---

## Teardown Order

To remove everything (reverse order):

```bash
# Step 1: Destroy workloads
cd 03-workloads/web-app
terraform destroy -auto-approve

# Step 2: Destroy landing zone
cd ../../02-landing-zones
terraform destroy -auto-approve

# Step 3: Destroy ALZ foundation
cd ../01-foundation
terraform destroy -auto-approve
```

**Duration**: ~10-15 minutes total

---

## Summary

| Step | Directory | Duration | Resources | Prerequisites |
|------|-----------|----------|-----------|---------------|
| 1 | `alz-foundation/` | 5-10 min | ~540 | Azure subscription |
| 2 | `02-landing-zones/` | 2-3 min | ~3 | Step 1 complete |
| 3 | `workloads/web-app/` | 3-5 min | ~5 | Step 2 complete + 2-5 min wait |

**Total Time**: ~15-20 minutes for complete deployment

**Key Outputs**:
- Step 1: Management group IDs
- Step 2: Log Analytics workspace ID
- Step 3: Web app URL

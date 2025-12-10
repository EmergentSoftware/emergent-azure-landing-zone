# FinOps Cost Export Configuration Scripts

This directory contains scripts for configuring Azure Cost Management exports to FinOps Hub.

## Files

- **Configure-FinOpsExports.ps1** - PowerShell script to create cost exports for all subscriptions
- **finops-exports-config.json.example** - Template configuration file (copy and customize)
- **finops-exports-config.json** - Your actual configuration (git-ignored, not committed)

## Setup

1. **Copy the example configuration file:**
   ```powershell
   Copy-Item finops-exports-config.json.example finops-exports-config.json
   ```

2. **Edit the configuration file:**
   - Replace `YOUR_FINOPS_HUB_STORAGE_ACCOUNT` with your FinOps Hub storage account name
   - Replace `YOUR_FINOPS_HUB_RESOURCE_GROUP` with your FinOps Hub resource group
   - Replace `YOUR_MANAGEMENT_SUBSCRIPTION_ID` with your management subscription ID
   - Update each subscription entry with actual subscription IDs

3. **Run the script:**
   
   **Option 1: Using config file (recommended)**
   ```powershell
   .\Configure-FinOpsExports.ps1
   ```
   
   **Option 2: Using custom config file**
   ```powershell
   .\Configure-FinOpsExports.ps1 -ConfigFile "custom-config.json"
   ```
   
   **Option 3: Using command-line parameters**
   ```powershell
   .\Configure-FinOpsExports.ps1 `
     -StorageAccount "acmefinopsh3funlapkpooie" `
     -ResourceGroup "acme-rg-management-finops-hub-prod-eastus" `
     -ManagementSubscriptionId "1302f5fd-..." `
     -Subscriptions @(
       @{Id="1302f5fd-..."; Name="acme-alz-management"},
       @{Id="c82e0943-..."; Name="acme-alz-connectivity"}
     )
   ```

## What It Does

The script creates daily Azure Cost Management exports for each subscription:

- **Export Name**: `finopshub-export-{subscription-name}`
- **Type**: ActualCost
- **Schedule**: Daily
- **Timeframe**: MonthToDate
- **Destination**: FinOps Hub storage account `ingestion` container
- **Recurrence**: One year (configurable in script)

## Verification

After running the script, verify the exports were created:

```powershell
# List all exports for a subscription
az costmanagement export list --scope "subscriptions/{subscription-id}"

# Show details of a specific export
az costmanagement export show --name "finopshub-export-management" --scope "subscriptions/{subscription-id}"
```

Check the FinOps Hub storage account after 24-48 hours:
```powershell
az storage blob list --account-name <storage-account> --container-name ingestion --auth-mode login
```

## Security Notes

⚠️ **IMPORTANT**: The configuration file (`finops-exports-config.json`) contains subscription IDs and is automatically excluded from Git commits via `.gitignore`. Never commit this file to source control.

✅ **Safe to commit**: Only the `.example` template file should be committed.

## Configuration File Format

```json
{
  "StorageAccount": "your-storage-account-name",
  "StorageContainer": "ingestion",
  "ResourceGroup": "your-resource-group-name",
  "ManagementSubscriptionId": "your-management-subscription-id",
  "Subscriptions": [
    {
      "Id": "subscription-guid",
      "Name": "subscription-name"
    }
  ]
}
```

## Troubleshooting

**Error: Subscription not found**
- Verify you're logged into the correct Azure account: `az account show`
- Check subscription IDs are correct: `az account list --query "[].{Name:name, Id:id}" -o table`

**Error: Storage account not found**
- Ensure the FinOps Hub has been deployed
- Verify the resource group and storage account names are correct
- Check you have permissions on the management subscription

**Export not running**
- Exports run on the next scheduled time (daily at UTC midnight)
- Check export status: `az costmanagement export show ...`
- Initial data may take 24-48 hours to appear

## Next Steps

After configuring exports:

1. Wait 24-48 hours for initial data collection
2. Verify data appears in the storage account `ingestion` container
3. Configure Power BI connection to FinOps Hub:
   - Storage URL: `https://{storage-account}.dfs.core.windows.net/ingestion`
   - Download Power BI templates: https://aka.ms/finops/hub
4. Publish FinOps Hub dashboards to your organization

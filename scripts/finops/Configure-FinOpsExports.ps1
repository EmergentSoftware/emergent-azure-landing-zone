# =============================================================================
# Configure Cost Exports for FinOps Hub
# PowerShell script using Azure CLI
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, HelpMessage = "Path to configuration file (JSON)")]
    [string]$ConfigFile = "finops-exports-config.json",

    [Parameter(Mandatory = $false, HelpMessage = "FinOps Hub storage account name")]
    [string]$StorageAccount,

    [Parameter(Mandatory = $false, HelpMessage = "Storage container name")]
    [string]$StorageContainer = "msexports",

    [Parameter(Mandatory = $false, HelpMessage = "FinOps Hub resource group name")]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $false, HelpMessage = "Management subscription ID")]
    [string]$ManagementSubscriptionId,

    [Parameter(Mandatory = $false, HelpMessage = "Array of subscription objects with Id and Name properties")]
    [array]$Subscriptions
)

# Function to load configuration from file
function Get-Configuration {
    param($ConfigPath)

    if (Test-Path $ConfigPath) {
        Write-Host "Loading configuration from: $ConfigPath" -ForegroundColor Cyan
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        return $config
    }
    return $null
}

# Load configuration from file if it exists
$config = Get-Configuration -ConfigPath $ConfigFile

# Use parameters from config file if not provided via command line
if (-not $StorageAccount -and $config.StorageAccount) {
    $StorageAccount = $config.StorageAccount
}
if (-not $ResourceGroup -and $config.ResourceGroup) {
    $ResourceGroup = $config.ResourceGroup
}
if (-not $ManagementSubscriptionId -and $config.ManagementSubscriptionId) {
    $ManagementSubscriptionId = $config.ManagementSubscriptionId
}
if (-not $Subscriptions -and $config.Subscriptions) {
    $Subscriptions = $config.Subscriptions
}

# Validate required parameters
if (-not $StorageAccount) {
    throw "StorageAccount is required. Provide via -StorageAccount parameter or in config file."
}
if (-not $ResourceGroup) {
    throw "ResourceGroup is required. Provide via -ResourceGroup parameter or in config file."
}
if (-not $ManagementSubscriptionId) {
    throw "ManagementSubscriptionId is required. Provide via -ManagementSubscriptionId parameter or in config file."
}
if (-not $Subscriptions -or $Subscriptions.Count -eq 0) {
    throw "Subscriptions array is required. Provide via -Subscriptions parameter or in config file."
}

Write-Host "=================================================="
Write-Host "FinOps Hub - Cost Export Configuration"
Write-Host "=================================================="
Write-Host ""
Write-Host "Storage Account: $StorageAccount"
Write-Host "Resource Group: $ResourceGroup"
Write-Host "Container: $StorageContainer"
Write-Host "Subscriptions to configure: $($Subscriptions.Count)"
Write-Host ""

# Get storage account resource ID
$StorageAccountId = "/subscriptions/$ManagementSubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Storage/storageAccounts/$StorageAccount"

# Create cost exports for each subscription
foreach ($Sub in $Subscriptions) {
    Write-Host ""
    Write-Host "=================================================="
    Write-Host "Configuring export for: $($Sub.Name)" -ForegroundColor Cyan
    Write-Host "=================================================="

    # Set context to subscription
    az account set --subscription $Sub.Id

    # Export name based on subscription
    $ExportName = "finopshub-export-$($Sub.Name.Replace('acme-alz-', '').Replace('acme-', '').Replace('-', ''))"

    Write-Host "Creating ActualCost export: $ExportName" -ForegroundColor Yellow

    # Execute the command directly with proper escaping for PowerShell
    # Note: Recurrence period starts tomorrow to avoid "in the past" error
    $startDate = (Get-Date).AddDays(1).ToString("yyyy-MM-ddT00:00:00Z")
    $endDate = "2026-12-31T00:00:00Z"

    $output = az costmanagement export create `
        --name "$ExportName" `
        --type ActualCost `
        --scope "/subscriptions/$($Sub.Id)" `
        --storage-account-id "$StorageAccountId" `
        --storage-container "$StorageContainer" `
        --timeframe MonthToDate `
        --recurrence Daily `
        --recurrence-period from="$startDate" to="$endDate" `
        --schedule-status Active `
        --storage-directory "$($Sub.Name)" 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Export created successfully for $($Sub.Name)" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create export for $($Sub.Name)" -ForegroundColor Red
        Write-Host "Error: $output" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=================================================="
Write-Host "Cost exports configuration complete!" -ForegroundColor Green
Write-Host "=================================================="
Write-Host ""
Write-Host "Exports will run daily and store data in:"
Write-Host "  Storage Account: $StorageAccount"
Write-Host "  Container: $StorageContainer"
Write-Host ""
Write-Host "Data will be available in FinOps Hub within 24-48 hours."
Write-Host ""
Write-Host "To verify exports:"
Write-Host "  az costmanagement export list --scope '/subscriptions/$ManagementSubscriptionId'"
Write-Host ""

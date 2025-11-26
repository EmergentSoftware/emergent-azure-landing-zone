#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Creates Azure subscriptions required for Azure Landing Zone deployment

.DESCRIPTION
    This script creates subscriptions using Azure CLI as an alternative to Terraform.
    Requires Azure CLI and appropriate billing permissions.

.PARAMETER BillingScope
    Billing scope ID (EA or MCA)

.PARAMETER TenantId
    Azure AD Tenant ID

.PARAMETER CreateManagement
    Create management subscription

.PARAMETER CreateCorp
    Number of corp subscriptions to create

.PARAMETER CreateOnline
    Number of online subscriptions to create

.EXAMPLE
    .\create-subscriptions.ps1 -BillingScope "/providers/Microsoft.Billing/..." -TenantId "..." -CreateManagement -CreateCorp 2 -CreateOnline 1
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$BillingScope = "",

    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [ValidateSet("EA", "MCA", "CSP")]
    [string]$BillingModel = "EA",

    [Parameter(Mandatory = $false)]
    [string]$CustomerTenantId = "",

    [switch]$CreateManagement,

    [int]$CreateCorp = 0,

    [int]$CreateOnline = 0,

    [string]$OutputFile = "subscriptions.json"
)

# Check if Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is not installed. Install from: https://aka.ms/installazurecli"
    exit 1
}

# Login check
Write-Host "Checking Azure CLI login status..." -ForegroundColor Cyan
$loginStatus = az account show 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not logged in. Initiating login..." -ForegroundColor Yellow
    az login --tenant $TenantId
}

# Validate parameters based on billing model
if ($BillingModel -eq "CSP") {
    if ([string]::IsNullOrEmpty($CustomerTenantId)) {
        Write-Error "CustomerTenantId is required when BillingModel is CSP"
        exit 1
    }
    Write-Host "Using CSP billing model for customer tenant: $CustomerTenantId" -ForegroundColor Cyan
}
else {
    if ([string]::IsNullOrEmpty($BillingScope)) {
        Write-Error "BillingScope is required when BillingModel is EA or MCA"
        exit 1
    }
    Write-Host "Using $BillingModel billing model with scope: $BillingScope" -ForegroundColor Cyan
}

$subscriptions = @{
    management = @()
    corp       = @()
    online     = @()
}

# Function to create subscription based on billing model
function New-AzureSubscription {
    param(
        [string]$Alias,
        [string]$DisplayName,
        [string]$Workload
    )

    if ($BillingModel -eq "CSP") {
        # CSP subscriptions
        Write-Host "Creating CSP subscription for customer..." -ForegroundColor Yellow
        
        $result = az rest --method PUT `
            --url "https://management.azure.com/providers/Microsoft.Subscription/aliases/$Alias?api-version=2021-10-01" `
            --body "{`"properties`":{`"displayName`":`"$DisplayName`",`"workload`":`"$Workload`",`"additionalProperties`":{`"subscriptionTenantId`":`"$CustomerTenantId`"}}}" `
            --output json | ConvertFrom-Json
        
        return $result
    }
    else {
        # EA or MCA subscriptions
        $result = az account alias create `
            --name $Alias `
            --billing-scope $BillingScope `
            --display-name $DisplayName `
            --workload $Workload `
            --output json | ConvertFrom-Json
        
        return $result
    }
}

# Create Management Subscription
if ($CreateManagement) {
    Write-Host "`nCreating Management subscription..." -ForegroundColor Cyan
    
    $result = New-AzureSubscription -Alias "sub-management-001" -DisplayName "Management" -Workload "Production"

    if ($LASTEXITCODE -eq 0 -or $result) {
        $subscriptions.management += @{
            alias           = "sub-management-001"
            display_name    = "Management"
            subscription_id = $result.properties.subscriptionId
        }
        Write-Host "✓ Created Management subscription: $($result.properties.subscriptionId)" -ForegroundColor Green
    }
    else {
        Write-Error "Failed to create Management subscription"
    }

    Start-Sleep -Seconds 5
}

# Create Corp Subscriptions
for ($i = 1; $i -le $CreateCorp; $i++) {
    $alias = "sub-corp-$('{0:D3}' -f $i)"
    $displayName = "Corp-$('{0:D3}' -f $i)"
    
    Write-Host "`nCreating $displayName subscription..." -ForegroundColor Cyan
    
    $result = New-AzureSubscription -Alias $alias -DisplayName $displayName -Workload "Production"

    if ($LASTEXITCODE -eq 0 -or $result) {
        $subscriptions.corp += @{
            alias           = $alias
            display_name    = $displayName
            subscription_id = $result.properties.subscriptionId
        }
        Write-Host "✓ Created $displayName subscription: $($result.properties.subscriptionId)" -ForegroundColor Green
    }
    else {
        Write-Error "Failed to create $displayName subscription"
    }

    Start-Sleep -Seconds 5
}

# Create Online Subscriptions
for ($i = 1; $i -le $CreateOnline; $i++) {
    $alias = "sub-online-$('{0:D3}' -f $i)"
    $displayName = "Online-$('{0:D3}' -f $i)"
    
    Write-Host "`nCreating $displayName subscription..." -ForegroundColor Cyan
    
    $result = New-AzureSubscription -Alias $alias -DisplayName $displayName -Workload "Production"

    if ($LASTEXITCODE -eq 0 -or $result) {
        $subscriptions.online += @{
            alias           = $alias
            display_name    = $displayName
            subscription_id = $result.properties.subscriptionId
        }
        Write-Host "✓ Created $displayName subscription: $($result.properties.subscriptionId)" -ForegroundColor Green
    }
    else {
        Write-Error "Failed to create $displayName subscription"
    }

    Start-Sleep -Seconds 5
}

# Output results
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Subscription Creation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($subscriptions.management.Count -gt 0) {
    Write-Host "`nManagement:" -ForegroundColor Yellow
    $subscriptions.management | ForEach-Object {
        Write-Host "  $($_.display_name): $($_.subscription_id)"
    }
}

if ($subscriptions.corp.Count -gt 0) {
    Write-Host "`nCorp:" -ForegroundColor Yellow
    $subscriptions.corp | ForEach-Object {
        Write-Host "  $($_.display_name): $($_.subscription_id)"
    }
}

if ($subscriptions.online.Count -gt 0) {
    Write-Host "`nOnline:" -ForegroundColor Yellow
    $subscriptions.online | ForEach-Object {
        Write-Host "  $($_.display_name): $($_.subscription_id)"
    }
}

# Save to JSON file
$subscriptions | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "`n✓ Subscription details saved to: $OutputFile" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Update 01-bootstrap/terraform.tfvars with the Management subscription ID" -ForegroundColor White
Write-Host "2. Update 02-landing-zones/*/terraform.tfvars with the respective subscription IDs" -ForegroundColor White
Write-Host "3. Run: cd 01-bootstrap && terraform init && terraform apply" -ForegroundColor White

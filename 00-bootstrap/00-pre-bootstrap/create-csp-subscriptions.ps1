#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Creates Azure subscriptions for CSP customers using Partner Center API

.DESCRIPTION
    This script creates Azure subscriptions within an existing Azure Plan for a CSP customer.
    The customer must already have an Azure Plan (offer_id: DZH318Z0BPS6) purchased.

    Uses Partner Center REST API to create individual Azure subscriptions under the customer's Azure Plan.
    Each subscription is created as an Azure entitlement within the existing plan.

.PARAMETER CustomerTenantId
    Customer tenant ID where subscriptions will be created

.PARAMETER PartnerTenantId
    Partner tenant ID (your CSP tenant)

.PARAMETER AppId
    Partner Center App ID (service principal with Admin Agent role in Partner Center)

.PARAMETER AppSecret
    Partner Center App Secret

.PARAMETER SubscriptionsFile
    Path to JSON file containing subscription names (default: subscriptions.json)

.PARAMETER OutputFile
    Path to save subscription IDs (default: "csp-subscription-ids.json")

.EXAMPLE
    .\create-csp-subscriptions-partnercenter.ps1 `
        -CustomerTenantId "customer-tenant-id" `
        -PartnerTenantId "partner-tenant-id" `
        -AppId "app-id" `
        -AppSecret "app-secret"

.NOTES
    Prerequisites:
    1. Service principal created in Partner tenant with Admin Agent role in Partner Center
    2. Customer relationship established in Partner Center
    3. **Customer must already have an Azure Plan subscription**
    4. App has delegated admin privileges (GDAP) to customer tenant
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CustomerTenantId,

    [Parameter(Mandatory = $true)]
    [string]$PartnerTenantId,

    [Parameter(Mandatory = $false)]
    [string]$AppId = $env:PARTNER_APP_ID,

    [Parameter(Mandatory = $false)]
    [string]$AppSecret = $env:PARTNER_APP_SECRET,

    [Parameter(Mandatory = $false)]
    [string]$SubscriptionsFile = "subscriptions.json",

    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "csp-subscription-ids.json"
)

# Validate credentials
if (-not $AppId -or -not $AppSecret) {
    Write-Error "Partner Center credentials required. Provide -AppId and -AppSecret or set PARTNER_APP_ID and PARTNER_APP_SECRET environment variables."
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CSP Subscription Creation (Partner Center API)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Get Partner Center access token
Write-Host "`n[1/4] Authenticating with Partner Center..." -ForegroundColor Yellow

$tokenBody = @{
    grant_type    = "client_credentials"
    client_id     = $AppId
    client_secret = $AppSecret
    resource      = "https://api.partnercenter.microsoft.com"
}

try {
    $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$PartnerTenantId/oauth2/token" `
        -Method Post `
        -Body $tokenBody `
        -ContentType "application/x-www-form-urlencoded"

    $partnerCenterToken = $tokenResponse.access_token
    Write-Host "✓ Authenticated with Partner Center" -ForegroundColor Green
}
catch {
    Write-Error "Failed to authenticate with Partner Center: $_"
    Write-Error $_.Exception.Message
    exit 1
}

# Load subscriptions from file
Write-Host "`n[2/4] Loading subscriptions from file..." -ForegroundColor Yellow

if (-not (Test-Path $SubscriptionsFile)) {
    Write-Error "Subscriptions file not found: $SubscriptionsFile"
    exit 1
}

$config = Get-Content $SubscriptionsFile | ConvertFrom-Json

if (-not $config.subscriptions -or $config.subscriptions.Count -eq 0) {
    Write-Error "No subscriptions defined in $SubscriptionsFile"
    exit 1
}

Write-Host "✓ Loaded $($config.subscriptions.Count) subscription(s) from file" -ForegroundColor Green

# Display subscription plan
Write-Host "`nSubscriptions to create:" -ForegroundColor Cyan
foreach ($sub in $config.subscriptions) {
    Write-Host "  - $sub" -ForegroundColor White
}
Write-Host "  Customer:   $CustomerTenantId" -ForegroundColor White

$totalCount = $config.subscriptions.Count
Write-Host "`nTotal: $totalCount subscriptions" -ForegroundColor Yellow

# Confirm
$confirm = Read-Host "`nProceed with subscription creation? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Cancelled by user" -ForegroundColor Yellow
    exit 0
}

# Function to get existing Azure Plan subscription ID
function Get-AzurePlanSubscriptionId {
    param(
        [string]$CustomerTenantId,
        [string]$PartnerCenterToken
    )

    try {
        $subscriptionsUri = "https://api.partnercenter.microsoft.com/v1/customers/$CustomerTenantId/subscriptions"

        $subscriptionsResponse = Invoke-RestMethod -Uri $subscriptionsUri -Method Get -Headers @{
            "Authorization"    = "Bearer $PartnerCenterToken"
            "MS-CorrelationId" = [guid]::NewGuid().ToString()
            "MS-RequestId"     = [guid]::NewGuid().ToString()
        } -ErrorAction Stop

        # Find Azure Plan subscription (offer_id = DZH318Z0BPS6)
        $azurePlan = $subscriptionsResponse.items | Where-Object { $_.offer_id -eq "DZH318Z0BPS6" } | Select-Object -First 1

        if ($azurePlan) {
            return $azurePlan.id
        }

        Write-Warning "No Azure Plan subscription found for customer"
        return $null
    }
    catch {
        Write-Error "Failed to retrieve Azure Plan subscription: $_"
        return $null
    }
}

# Function to create Azure subscription within existing Azure Plan
function New-PartnerCenterSubscription {
    param(
        [string]$SubscriptionName,
        [string]$CustomerTenantId,
        [string]$AzurePlanSubscriptionId,
        [string]$PartnerCenterToken
    )

    Write-Host "`n  Creating: $SubscriptionName..." -ForegroundColor Yellow

    # Create Azure subscription within the Azure Plan
    $subscriptionBody = @{
        displayName    = $SubscriptionName
        subscriptionId = $AzurePlanSubscriptionId
    } | ConvertTo-Json -Depth 10

    try {
        $createUri = "https://api.partnercenter.microsoft.com/v1/customers/$CustomerTenantId/subscriptions/$AzurePlanSubscriptionId/azureEntitlements"

        $createResponse = Invoke-RestMethod -Uri $createUri -Method Post -Headers @{
            "Authorization"    = "Bearer $PartnerCenterToken"
            "Content-Type"     = "application/json"
            "MS-CorrelationId" = [guid]::NewGuid().ToString()
            "MS-RequestId"     = [guid]::NewGuid().ToString()
        } -Body $subscriptionBody -ErrorAction Stop

        if ($createResponse.id) {
            Write-Host "  ✓ Azure subscription created: $($createResponse.id)" -ForegroundColor Green
            Write-Host "    Friendly Name: $($createResponse.friendlyName)" -ForegroundColor Gray

            return @{
                name         = $SubscriptionName
                id           = $createResponse.id
                friendlyName = $createResponse.friendlyName
                state        = "Succeeded"
                azurePlanId  = $AzurePlanSubscriptionId
            }
        }

        Write-Warning "Subscription ID not found in response"
        return @{
            name  = $SubscriptionName
            state = "PartialSuccess"
            note  = "Request succeeded but subscription ID not returned"
        }
    }
    catch {
        $errorDetails = if ($_.ErrorDetails.Message) { $_.ErrorDetails.Message } else { $_.Exception.Message }
        Write-Error "Failed to create subscription: $errorDetails"

        return @{
            name  = $SubscriptionName
            state = "Failed"
            error = $errorDetails
        }
    }
}

# Create subscriptions
Write-Host "`n[3/4] Getting existing Azure Plan..." -ForegroundColor Yellow

$azurePlanId = Get-AzurePlanSubscriptionId -CustomerTenantId $CustomerTenantId -PartnerCenterToken $partnerCenterToken

if (-not $azurePlanId) {
    Write-Error "Customer does not have an Azure Plan subscription. Please purchase an Azure Plan for this customer first."
    exit 1
}

Write-Host "✓ Found Azure Plan subscription: $azurePlanId" -ForegroundColor Green

Write-Host "`n[4/5] Creating subscriptions within Azure Plan..." -ForegroundColor Yellow

$results = @{
    partner_tenant_id  = $PartnerTenantId
    customer_tenant_id = $CustomerTenantId
    azure_plan_id      = $azurePlanId
    created_date       = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    subscriptions      = @()
}

foreach ($subscriptionName in $config.subscriptions) {
    $result = New-PartnerCenterSubscription `
        -SubscriptionName $subscriptionName `
        -CustomerTenantId $CustomerTenantId `
        -AzurePlanSubscriptionId $azurePlanId `
        -PartnerCenterToken $partnerCenterToken

    $results.subscriptions += $result
}

# Save results
Write-Host "`n[5/5] Saving results..." -ForegroundColor Yellow
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "✓ Results saved to: $OutputFile" -ForegroundColor Green

# Display summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Subscription Creation Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

$successCount = 0
$failCount = 0

foreach ($sub in $results.subscriptions) {
    $status = if ($sub.state -eq "Succeeded") {
        $successCount++
        "✓"
    }
    else {
        $failCount++
        "✗"
    }
    $color = if ($sub.state -eq "Succeeded") { "Green" } else { "Red" }
    Write-Host "$status $($sub.name) - $($sub.state)" -ForegroundColor $color
    if ($sub.id) {
        Write-Host "    Partner Center Subscription ID: $($sub.id)" -ForegroundColor Gray
    }
}

Write-Host "`nResults: $successCount succeeded, $failCount failed" -ForegroundColor Cyan

# Next steps
if ($successCount -gt 0) {
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "1. Azure subscriptions are being provisioned in customer tenant: $CustomerTenantId" -ForegroundColor White
    Write-Host "2. Wait 5-10 minutes for provisioning to complete" -ForegroundColor White
    Write-Host "3. Retrieve Azure subscription IDs:" -ForegroundColor White
    Write-Host "   az login --tenant $CustomerTenantId" -ForegroundColor Gray
    Write-Host "   az account list --query \"[].{ name:name, id:id }\" -o table" -ForegroundColor Gray
    Write-Host "4. Update terraform.tfvars with Azure subscription IDs" -ForegroundColor White
    Write-Host "5. Run deployment starting with 00-bootstrap" -ForegroundColor White
}

Write-Host "`n⚠ Important Notes:" -ForegroundColor Yellow
Write-Host "  - Subscriptions created within existing Azure Plan: $azurePlanId" -ForegroundColor White
Write-Host "  - Customer tenant: $CustomerTenantId" -ForegroundColor White
Write-Host "  - All subscriptions billed through the customer's Azure Plan" -ForegroundColor White
Write-Host "  - Subscription IDs saved to: $OutputFile" -ForegroundColor White
Write-Host "  - Ensure GDAP relationship is established for management access" -ForegroundColor White

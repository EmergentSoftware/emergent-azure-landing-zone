#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Creates and configures a service principal for CSP subscription management

.DESCRIPTION
    This script creates a service principal in the partner tenant with the necessary
    permissions to create and manage customer subscriptions via CSP model.

    Prerequisites:
    - Azure CLI installed
    - Application Administrator role in partner tenant (to create service principals)
    - Admin Agent role in Partner Center (for subscription creation)

.PARAMETER PartnerTenantId
    Partner tenant ID

.PARAMETER CustomerTenantId
    Customer tenant ID

.PARAMETER AppName
    Name for the service principal (default: "terraform-csp-alz")

.PARAMETER CreateGDAPRelationship
    Create GDAP relationship with customer (requires additional setup)

.PARAMETER OutputFile
    Path to save service principal credentials (default: "csp-sp-credentials.json")

.EXAMPLE
    .\setup-csp-service-principal.ps1 -PartnerTenantId "partner-id" -CustomerTenantId "customer-id"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PartnerTenantId,

    [Parameter(Mandatory = $true)]
    [string]$CustomerTenantId,

    [Parameter(Mandatory = $false)]
    [string]$AppName = "terraform-csp-alz",

    [Parameter(Mandatory = $false)]
    [switch]$CreateGDAPRelationship,

    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "csp-sp-credentials.json"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CSP Service Principal Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is not installed. Install from: https://aka.ms/installazurecli"
    exit 1
}

# Login to partner tenant
Write-Host "`n[1/7] Logging in to partner tenant..." -ForegroundColor Yellow
az login --tenant $PartnerTenantId --allow-no-subscriptions
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to login to partner tenant"
    exit 1
}

# Verify permissions
Write-Host "`n[2/7] Verifying permissions..." -ForegroundColor Yellow
$currentUser = az ad signed-in-user show | ConvertFrom-Json
Write-Host "✓ Logged in as: $($currentUser.userPrincipalName)" -ForegroundColor Green

# Check if app already exists
Write-Host "`n[3/7] Checking for existing service principal..." -ForegroundColor Yellow
$existingApp = az ad app list --display-name $AppName --query "[0]" | ConvertFrom-Json

if ($existingApp) {
    Write-Host "⚠ Service principal '$AppName' already exists" -ForegroundColor Yellow
    $useExisting = Read-Host "Use existing service principal? (Y/N)"

    if ($useExisting -eq 'Y' -or $useExisting -eq 'y') {
        $appId = $existingApp.appId
        Write-Host "✓ Using existing app: $appId" -ForegroundColor Green
    }
    else {
        Write-Host "Creating new service principal with different name..." -ForegroundColor Yellow
        $AppName = "$AppName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        $existingApp = $null
    }
}

# Create service principal if needed
if (-not $existingApp) {
    Write-Host "`n[4/7] Creating service principal..." -ForegroundColor Yellow

    $app = az ad app create `
        --display-name $AppName `
        --sign-in-audience "AzureADMultipleOrgs" `
        --query "{appId:appId, id:id}" `
        --output json | ConvertFrom-Json

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create application"
        exit 1
    }

    $appId = $app.appId

    Write-Host "✓ Created application: $appId" -ForegroundColor Green

    # Create service principal
    az ad sp create --id $appId --only-show-errors | Out-Null
    Write-Host "✓ Created service principal" -ForegroundColor Green

    # Wait for replication
    Write-Host "⏳ Waiting for replication..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
}
else {
    $appId = $existingApp.appId
    $objectId = $existingApp.id
}

# Create client secret
Write-Host "`n[5/7] Creating client secret..." -ForegroundColor Yellow
$secretName = "terraform-secret-$(Get-Date -Format 'yyyyMMdd')"
$secret = az ad app credential reset `
    --id $appId `
    --append `
    --display-name $secretName `
    --years 2 `
    --query "{clientSecret:password}" `
    --output json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create client secret"
    exit 1
}

$clientSecret = $secret.clientSecret
Write-Host "✓ Created client secret (expires in 2 years)" -ForegroundColor Green

# Assign required API permissions
Write-Host "`n[6/7] Configuring API permissions..." -ForegroundColor Yellow

# Microsoft Graph permissions
$graphResourceId = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
$permissions = @(
    "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
    "7ab1d382-f21e-4acd-a863-ba3e13f7da61" # Directory.Read.All
)

foreach ($permission in $permissions) {
    az ad app permission add `
        --id $appId `
        --api $graphResourceId `
        --api-permissions "$permission=Role" `
        --only-show-errors | Out-Null
}

# Azure Service Management permissions
$armResourceId = "797f4846-ba00-4fd7-ba43-dac1f8f63013" # Azure Service Management
az ad app permission add `
    --id $appId `
    --api $armResourceId `
    --api-permissions "41094075-9dad-400e-a0bd-54e686782033=Scope" `
    --only-show-errors | Out-Null

Write-Host "✓ Added API permissions (requires admin consent)" -ForegroundColor Green
Write-Host "⚠ Admin consent must be granted by Privileged Role Administrator" -ForegroundColor Yellow

# Get partner subscription for role assignment
Write-Host "`n[7/7] Checking for partner subscriptions..." -ForegroundColor Yellow

$subscriptions = az account list --query "[?tenantId=='$PartnerTenantId']" | ConvertFrom-Json

if ($subscriptions.Count -gt 0) {
    $subId = $subscriptions[0].id
    Write-Host "✓ Found partner subscription: $subId" -ForegroundColor Green
    Write-Host "⚠ RBAC roles must be assigned by User Access Administrator" -ForegroundColor Yellow
}
else {
    Write-Warning "No subscriptions found in partner tenant."
}

# Save credentials
$credentials = @{
    partner_tenant_id  = $PartnerTenantId
    customer_tenant_id = $CustomerTenantId
    client_id          = $appId
    client_secret      = $clientSecret
    app_name           = $AppName
    created_date       = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    secret_expiry      = (Get-Date).AddYears(2).ToString("yyyy-MM-dd")
}

$credentials | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "`n✓ Credentials saved to: $OutputFile" -ForegroundColor Green

# GDAP Relationship (optional)
if ($CreateGDAPRelationship) {
    Write-Host "`n[GDAP] Setting up Granular Delegated Admin Privileges..." -ForegroundColor Yellow
    Write-Host "⚠ GDAP setup requires Partner Center API access" -ForegroundColor Yellow
    Write-Host "Please complete GDAP setup in Partner Center:" -ForegroundColor Cyan
    Write-Host "1. Navigate to Partner Center > Customers" -ForegroundColor White
    Write-Host "2. Select customer: $CustomerTenantId" -ForegroundColor White
    Write-Host "3. Go to 'Admin relationships'" -ForegroundColor White
    Write-Host "4. Create new GDAP relationship with roles:" -ForegroundColor White
    Write-Host "   - Directory Writers (for resource creation)" -ForegroundColor White
    Write-Host "   - Privileged Role Administrator (for RBAC)" -ForegroundColor White
    Write-Host "   - Cloud Application Administrator (for service principals)" -ForegroundColor White
}

# Display summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nService Principal Created:" -ForegroundColor Yellow
Write-Host "  App Name:         $AppName"
Write-Host "  Client ID:        $appId"
Write-Host "  Partner Tenant:   $PartnerTenantId"
Write-Host "  Customer Tenant:  $CustomerTenantId"
Write-Host "  Secret Expires:   $($credentials.secret_expiry)"

Write-Host "`n⚠ Manual Steps Required:" -ForegroundColor Yellow
Write-Host "  1. Admin consent not granted (needs Privileged Role Administrator)" -ForegroundColor White
Write-Host "  2. RBAC roles not assigned (needs User Access Administrator)" -ForegroundColor White
Write-Host "  3. See 'Next Steps' below for commands" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Cyan

Write-Host "`n1. Grant Admin Consent (requires Privileged Role Administrator):" -ForegroundColor Yellow
Write-Host "   az login --tenant $PartnerTenantId" -ForegroundColor Gray
Write-Host "   az ad app permission admin-consent --id $appId" -ForegroundColor Gray
Write-Host "   OR use Azure Portal:" -ForegroundColor Gray
Write-Host "   https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/$appId" -ForegroundColor Gray

if ($subscriptions.Count -gt 0) {
    Write-Host "`n2. Assign RBAC Roles (requires User Access Administrator):" -ForegroundColor Yellow
    Write-Host "   az role assignment create --assignee $appId --role 'Contributor' --scope '/subscriptions/$subId'" -ForegroundColor Gray
    Write-Host "   az role assignment create --assignee $appId --role 'User Access Administrator' --scope '/subscriptions/$subId'" -ForegroundColor Gray
}

Write-Host "`n3. Verify Admin Agent role in Partner Center" -ForegroundColor Yellow

Write-Host "`n4. Establish GDAP relationship with customer (if not done)" -ForegroundColor Yellow

Write-Host "`n5. Set environment variables for Terraform:" -ForegroundColor Yellow
Write-Host "   export ARM_CLIENT_ID='$appId'" -ForegroundColor Gray
Write-Host "   export ARM_CLIENT_SECRET='$clientSecret'" -ForegroundColor Gray
Write-Host "   export ARM_TENANT_ID='$PartnerTenantId'" -ForegroundColor Gray

Write-Host "`n6. Update 00-pre-bootstrap/terraform.tfvars:" -ForegroundColor Yellow
Write-Host "   billing_model = `"CSP`"" -ForegroundColor Gray
Write-Host "   tenant_id = `"$PartnerTenantId`"" -ForegroundColor Gray
Write-Host "   csp_customer_tenant_id = `"$CustomerTenantId`"" -ForegroundColor Gray

Write-Host "`n⚠ Security Reminder:" -ForegroundColor Yellow
Write-Host "- Store credentials securely (Azure Key Vault recommended)" -ForegroundColor White
Write-Host "- Delete $OutputFile after setting up secrets management" -ForegroundColor White
Write-Host "- Rotate client secret before expiry ($($credentials.secret_expiry))" -ForegroundColor White

Write-Host "`nRequired Roles:" -ForegroundColor Cyan
Write-Host "  Application Administrator - Creates service principal (✓ used by this script)" -ForegroundColor White
Write-Host "  Privileged Role Administrator - Grants admin consent (⚠ manual step required)" -ForegroundColor White
Write-Host "  User Access Administrator - Assigns RBAC roles (⚠ manual step required)" -ForegroundColor White
Write-Host "  Admin Agent (Partner Center) - Creates CSP subscriptions (⚠ verify manually)" -ForegroundColor White

Write-Host "`nTerraform Authentication:" -ForegroundColor Cyan
Write-Host "Use service principal authentication in provider block:" -ForegroundColor White
Write-Host "provider `"azurerm`" {" -ForegroundColor Gray
Write-Host "  features {}" -ForegroundColor Gray
Write-Host "  client_id       = `"$appId`"" -ForegroundColor Gray
Write-Host "  client_secret   = `"<from-key-vault>`"" -ForegroundColor Gray
Write-Host "  tenant_id       = `"$PartnerTenantId`"" -ForegroundColor Gray
Write-Host "  subscription_id = `"<partner-subscription-id>`"" -ForegroundColor Gray
Write-Host "}" -ForegroundColor Gray

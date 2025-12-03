#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Sets up Azure OIDC authentication for GitHub Actions
.DESCRIPTION
    Creates an Azure AD App Registration with federated credentials for GitHub Actions OIDC,
    assigns necessary permissions, and outputs the values to add as GitHub secrets.
.PARAMETER AppName
    Name for the Azure AD App Registration (default: github-actions-emergent-alz)
.PARAMETER SubscriptionId
    Azure subscription ID (default: 1302f5fd-f3b5-4eda-909c-e3ae2dfee3d6)
.PARAMETER TenantId
    Azure tenant ID (default: 0b79ac7b-0cc7-4d9f-a549-3b8cc894ac9b)
.PARAMETER GitHubOrg
    GitHub organization name (default: emergentsoftware)
.PARAMETER GitHubRepo
    GitHub repository name (default: emergent-azure-landing-zone)
.PARAMETER Branch
    Git branch for OIDC federation (default: main)
.EXAMPLE
    .\setup-github-oidc.ps1
.EXAMPLE
    .\setup-github-oidc.ps1 -Branch "develop"
#>

param(
    [string]$AppName = "github-actions-emergent-alz",
    [string]$SubscriptionId = "00000000-0000-0000-0000-000000000000",
    [string]$TenantId = "00000000-0000-0000-0000-000000000000",
    [string]$GitHubOrg = "emergentsoftware",
    [string]$GitHubRepo = "emergent-azure-landing-zone",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Actions OIDC Setup for Azure" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
Write-Host "Checking Azure CLI installation..." -ForegroundColor Yellow
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✓ Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
}
catch {
    Write-Host "✗ Azure CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "  Install from: https://docs.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Red
    exit 1
}

# Check if logged in
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "✓ Logged in as: $($account.user.name)" -ForegroundColor Green
    Write-Host "  Subscription: $($account.name) ($($account.id))" -ForegroundColor Gray
}
catch {
    Write-Host "✗ Not logged into Azure CLI" -ForegroundColor Red
    Write-Host "  Run 'az login' first" -ForegroundColor Red
    exit 1
}

# Set subscription context
Write-Host "`nSetting subscription context..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId
Write-Host "✓ Using subscription: $SubscriptionId" -ForegroundColor Green

# Check if app already exists
Write-Host "`nChecking for existing app registration..." -ForegroundColor Yellow
$existingApp = az ad app list --display-name $AppName --output json | ConvertFrom-Json
if ($existingApp -and $existingApp.Count -gt 0) {
    Write-Host "✓ Found existing app: $AppName" -ForegroundColor Green
    $appId = $existingApp[0].appId
    Write-Host "  App ID: $appId" -ForegroundColor Gray
}
else {
    # Create app registration
    Write-Host "`nCreating Azure AD App Registration..." -ForegroundColor Yellow
    $app = az ad app create --display-name $AppName --output json | ConvertFrom-Json
    $appId = $app.appId
    Write-Host "✓ Created app: $AppName" -ForegroundColor Green
    Write-Host "  App ID: $appId" -ForegroundColor Gray

    Start-Sleep -Seconds 5
}

# Check if service principal exists
Write-Host "`nChecking for service principal..." -ForegroundColor Yellow
$existingSp = az ad sp list --filter "appId eq '$appId'" --output json | ConvertFrom-Json
if ($existingSp -and $existingSp.Count -gt 0) {
    Write-Host "✓ Found existing service principal" -ForegroundColor Green
    $spObjectId = $existingSp[0].id
}
else {
    # Create service principal
    Write-Host "`nCreating service principal..." -ForegroundColor Yellow
    $sp = az ad sp create --id $appId --output json | ConvertFrom-Json
    $spObjectId = $sp.id
    Write-Host "✓ Created service principal" -ForegroundColor Green
    Write-Host "  Object ID: $spObjectId" -ForegroundColor Gray

    Start-Sleep -Seconds 5
}

# Assign Contributor role
Write-Host "`nAssigning Contributor role at subscription scope..." -ForegroundColor Yellow
$scope = "/subscriptions/$SubscriptionId"
try {
    az role assignment create `
        --assignee $appId `
        --role "Contributor" `
        --scope $scope `
        --output none 2>$null
    Write-Host "✓ Assigned Contributor role at subscription scope" -ForegroundColor Green
}
catch {
    Write-Host "  Role may already be assigned (this is fine)" -ForegroundColor Gray
}

# Assign Owner role at management group
Write-Host "`nAssigning Owner role at management group scope..." -ForegroundColor Yellow
$mgScope = "/providers/Microsoft.Management/managementGroups/acme-alz"
try {
    az role assignment create `
        --assignee $appId `
        --role "Owner" `
        --scope $mgScope `
        --output none 2>$null
    Write-Host "✓ Assigned Owner role at management group: acme-alz" -ForegroundColor Green
}
catch {
    Write-Host "  Role may already be assigned (this is fine)" -ForegroundColor Gray
}

# Configure OIDC federated credentials
Write-Host "`nConfiguring OIDC federated credentials..." -ForegroundColor Yellow

# Get existing credentials
$existingCreds = az ad app federated-credential list --id $appId --output json | ConvertFrom-Json

# Credential 1: Main branch
$credentialName1 = "github-$GitHubRepo-$Branch"
$subject1 = "repo:$GitHubOrg/${GitHubRepo}:ref:refs/heads/$Branch"
$existingCred1 = $existingCreds | Where-Object { $_.subject -eq $subject1 }

if ($existingCred1) {
    Write-Host "✓ Federated credential already exists for branch: $Branch" -ForegroundColor Green
}
else {
    $credentialJson = @{
        name      = $credentialName1
        issuer    = "https://token.actions.githubusercontent.com"
        subject   = $subject1
        audiences = @("api://AzureADTokenExchange")
    } | ConvertTo-Json

    $tempFile = [System.IO.Path]::GetTempFileName()
    $credentialJson | Out-File -FilePath $tempFile -Encoding utf8
    az ad app federated-credential create --id $appId --parameters $tempFile --output none
    Remove-Item $tempFile
    Write-Host "✓ Created federated credential for branch: $Branch" -ForegroundColor Green
}

# Credential 2: Pull requests
$credentialName2 = "github-$GitHubRepo-pr"
$subject2 = "repo:$GitHubOrg/${GitHubRepo}:pull_request"
$existingCred2 = $existingCreds | Where-Object { $_.subject -eq $subject2 }

if ($existingCred2) {
    Write-Host "✓ Federated credential already exists for pull requests" -ForegroundColor Green
}
else {
    $credentialJson = @{
        name      = $credentialName2
        issuer    = "https://token.actions.githubusercontent.com"
        subject   = $subject2
        audiences = @("api://AzureADTokenExchange")
    } | ConvertTo-Json

    $tempFile = [System.IO.Path]::GetTempFileName()
    $credentialJson | Out-File -FilePath $tempFile -Encoding utf8
    az ad app federated-credential create --id $appId --parameters $tempFile --output none
    Remove-Item $tempFile
    Write-Host "✓ Created federated credential for pull requests" -ForegroundColor Green
}

# Display summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add these secrets to your GitHub repository:" -ForegroundColor Yellow
Write-Host "https://github.com/$GitHubOrg/$GitHubRepo/settings/secrets/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "Secret Name                Value" -ForegroundColor White
Write-Host "----------------------------  ------------------------------------" -ForegroundColor Gray
Write-Host "AZURE_CLIENT_ID            " -NoNewline -ForegroundColor White
Write-Host $appId -ForegroundColor Green
Write-Host "AZURE_TENANT_ID            " -NoNewline -ForegroundColor White
Write-Host $TenantId -ForegroundColor Green
Write-Host "AZURE_SUBSCRIPTION_ID      " -NoNewline -ForegroundColor White
Write-Host $SubscriptionId -ForegroundColor Green
Write-Host ""
Write-Host "Copy commands to set secrets via GitHub CLI:" -ForegroundColor Yellow
Write-Host ""
Write-Host "gh secret set AZURE_CLIENT_ID --body `"$appId`" --repo $GitHubOrg/$GitHubRepo" -ForegroundColor Cyan
Write-Host "gh secret set AZURE_TENANT_ID --body `"$TenantId`" --repo $GitHubOrg/$GitHubRepo" -ForegroundColor Cyan
Write-Host "gh secret set AZURE_SUBSCRIPTION_ID --body `"$SubscriptionId`" --repo $GitHubOrg/$GitHubRepo" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

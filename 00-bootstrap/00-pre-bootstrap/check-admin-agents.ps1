#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Checks which users and service principals have Admin Agent role in Partner Center

.DESCRIPTION
    Uses Azure AD to show users in AdminAgents group and all service principals in the tenant.
    Note: Partner Center-specific role assignments for SPNs are not visible via Azure AD APIs.
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$PartnerTenantId = "25ee13ae-a8a5-4bc2-bb23-aea90536fb0c"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Partner Center Admin Agent Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Ensure logged in to correct tenant
Write-Host "`nEnsuring Azure CLI is logged into partner tenant..." -ForegroundColor Yellow
az login --tenant $PartnerTenantId --allow-no-subscriptions

Write-Host "`n[1/2] Checking AdminAgents Group (Users)..." -ForegroundColor Yellow

# Get AdminAgents group
$adminAgentsGroup = az ad group list --filter "displayName eq 'AdminAgents'" --query "[0]" | ConvertFrom-Json

if ($adminAgentsGroup) {
    Write-Host "✓ Found AdminAgents group: $($adminAgentsGroup.id)" -ForegroundColor Green
    
    # Get members
    $members = az ad group member list --group $adminAgentsGroup.id | ConvertFrom-Json
    
    if ($members.Count -gt 0) {
        Write-Host "`nUsers with Admin Agent role:" -ForegroundColor Cyan
        $members | ForEach-Object {
            Write-Host "  ✓ $($_.displayName) ($($_.userPrincipalName))" -ForegroundColor White
        }
    } else {
        Write-Host "  No users in AdminAgents group" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ AdminAgents group not found" -ForegroundColor Red
}

Write-Host "`n[2/2] Listing All Service Principals..." -ForegroundColor Yellow
Write-Host "(Note: Partner Center role assignments for SPNs are not visible here)" -ForegroundColor Gray

$servicePrincipals = az ad sp list --all --query "[?appOwnerOrganizationId=='$PartnerTenantId'].{DisplayName:displayName, AppId:appId, Id:id}" | ConvertFrom-Json

if ($servicePrincipals.Count -gt 0) {
    Write-Host "`nService Principals in Partner Tenant:" -ForegroundColor Cyan
    $servicePrincipals | ForEach-Object {
        Write-Host "  • $($_.DisplayName)" -ForegroundColor White
        Write-Host "    App ID: $($_.AppId)" -ForegroundColor Gray
        Write-Host "    Object ID: $($_.Id)" -ForegroundColor Gray
    }
    Write-Host "`nTotal: $($servicePrincipals.Count) service principal(s)" -ForegroundColor Yellow
} else {
    Write-Host "  No service principals found" -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Important Notes:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "• AdminAgents group shows USERS with delegated admin access" -ForegroundColor White
Write-Host "• Service principal Admin Agent role is assigned in Partner Center Portal" -ForegroundColor White
Write-Host "• SPN roles are NOT visible via Azure AD APIs or PowerShell" -ForegroundColor White
Write-Host "• To verify SPN roles, check Partner Center Portal manually" -ForegroundColor White
Write-Host "`nPartner Center: https://partner.microsoft.com/" -ForegroundColor Gray
Write-Host "  Settings → Account settings → look for app management section" -ForegroundColor Gray

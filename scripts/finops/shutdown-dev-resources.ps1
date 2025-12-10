<#
.SYNOPSIS
    Automated shutdown of development resources during off-hours to save costs.

.DESCRIPTION
    This script demonstrates FinOps resource lifecycle automation by shutting down
    non-production resources during nights and weekends. This is a common cost
    optimization practice that can save 50-70% on compute costs for dev/test environments.

.PARAMETER Environment
    Target environment (Dev, Test). Production resources are never shut down.

.PARAMETER ResourceGroupPattern
    Pattern to match resource group names (default: *-dev-*, *-test-*)

.PARAMETER WhatIf
    Show what would be shut down without actually doing it

.EXAMPLE
    .\shutdown-dev-resources.ps1 -Environment Dev -WhatIf
    Shows which dev resources would be shut down

.EXAMPLE
    .\shutdown-dev-resources.ps1 -Environment Dev
    Shuts down all dev environment resources

.NOTES
    This is a DEMO script. In production, use:
    - Azure Automation Runbooks with schedules
    - Azure DevTest Labs auto-shutdown
    - Azure Resource Scheduler (3rd party)
    - Start/Stop VMs v2 solution
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Dev', 'Test')]
    [string]$Environment = 'Dev',

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupPattern = "*-$Environment-*",

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Cost savings tracking
$script:shutdownCount = 0
$script:estimatedMonthlySavings = 0

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FinOps Resource Lifecycle Automation" -ForegroundColor Cyan
Write-Host "Auto-Shutdown for $Environment Environment" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Get all resource groups matching the environment pattern
Write-Host "Finding resource groups matching: $ResourceGroupPattern..." -ForegroundColor Yellow
$resourceGroups = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like $ResourceGroupPattern }

if ($resourceGroups.Count -eq 0) {
    Write-Host "No resource groups found matching pattern: $ResourceGroupPattern" -ForegroundColor Red
    exit
}

Write-Host "Found $($resourceGroups.Count) resource group(s)`n" -ForegroundColor Green

foreach ($rg in $resourceGroups) {
    Write-Host "Processing Resource Group: $($rg.ResourceGroupName)" -ForegroundColor Cyan

    # =============================================================================
    # Shut down Virtual Machines
    # =============================================================================
    $vms = Get-AzVM -ResourceGroupName $rg.ResourceGroupName -Status

    foreach ($vm in $vms) {
        $vmStatus = ($vm.Statuses | Where-Object { $_.Code -like 'PowerState/*' }).Code

        if ($vmStatus -eq 'PowerState/running') {
            $script:shutdownCount++

            # Estimate monthly savings (assumes 16 hours/day shutdown * 22 workdays)
            # Average VM cost: $100/month -> Save ~$67/month per VM
            $script:estimatedMonthlySavings += 67

            if ($WhatIf) {
                Write-Host "  [WHATIF] Would shut down VM: $($vm.Name)" -ForegroundColor Yellow
            }
            else {
                Write-Host "  Shutting down VM: $($vm.Name)..." -ForegroundColor Green
                Stop-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name -Force -NoWait | Out-Null
            }
        }
        else {
            Write-Host "  VM already stopped: $($vm.Name)" -ForegroundColor Gray
        }
    }

    # =============================================================================
    # Stop App Service Plans (scale to F1 or B1)
    # =============================================================================
    $appServicePlans = Get-AzAppServicePlan -ResourceGroupName $rg.ResourceGroupName

    foreach ($plan in $appServicePlans) {
        if ($plan.Sku.Tier -notin @('Free', 'Shared', 'Basic')) {
            $script:shutdownCount++
            $script:estimatedMonthlySavings += 30 # Estimated savings per plan

            if ($WhatIf) {
                Write-Host "  [WHATIF] Would scale down App Service Plan: $($plan.Name) (Current: $($plan.Sku.Tier))" -ForegroundColor Yellow
            }
            else {
                Write-Host "  Scaling down App Service Plan: $($plan.Name) to Basic B1..." -ForegroundColor Green
                Set-AzAppServicePlan -ResourceGroupName $rg.ResourceGroupName -Name $plan.Name -Tier 'Basic' -NumberofWorkers 1 -WorkerSize 'Small' | Out-Null
            }
        }
    }

    # =============================================================================
    # Pause Azure SQL Databases (serverless databases auto-pause)
    # =============================================================================
    $sqlServers = Get-AzSqlServer -ResourceGroupName $rg.ResourceGroupName

    foreach ($server in $sqlServers) {
        $databases = Get-AzSqlDatabase -ResourceGroupName $rg.ResourceGroupName -ServerName $server.ServerName | Where-Object { $_.DatabaseName -ne 'master' }

        foreach ($db in $databases) {
            if ($db.Status -eq 'Online' -and $db.Sku.Tier -notin @('Free', 'Basic', 'Serverless')) {
                $script:shutdownCount++
                $script:estimatedMonthlySavings += 15 # Estimated savings per database

                if ($WhatIf) {
                    Write-Host "  [WHATIF] Would pause SQL Database: $($db.DatabaseName)" -ForegroundColor Yellow
                }
                else {
                    Write-Host "  Pausing SQL Database: $($db.DatabaseName)..." -ForegroundColor Green
                    Suspend-AzSqlDatabase -ResourceGroupName $rg.ResourceGroupName -ServerName $server.ServerName -DatabaseName $db.DatabaseName | Out-Null
                }
            }
        }
    }

    Write-Host ""
}

# =============================================================================
# Summary Report
# =============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Shutdown Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resources processed: $script:shutdownCount" -ForegroundColor Green
Write-Host "Estimated monthly savings: `$$script:estimatedMonthlySavings USD" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "`nThis was a test run. No resources were actually shut down." -ForegroundColor Yellow
    Write-Host "Remove -WhatIf to perform actual shutdown." -ForegroundColor Yellow
}
else {
    Write-Host "`nResources are being shut down (async)." -ForegroundColor Green
    Write-Host "Check Azure Portal for status in a few minutes." -ForegroundColor Green
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Create an Azure Automation Runbook with this script" -ForegroundColor White
Write-Host "2. Schedule it to run daily at 7 PM" -ForegroundColor White
Write-Host "3. Create a startup script for 7 AM" -ForegroundColor White
Write-Host "4. Monitor cost savings in Azure Cost Management" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

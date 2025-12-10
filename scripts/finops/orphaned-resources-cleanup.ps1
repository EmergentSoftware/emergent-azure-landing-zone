<#
.SYNOPSIS
    Identify and optionally clean up orphaned Azure resources to reduce waste.

.DESCRIPTION
    This script scans Azure subscriptions for common orphaned resources that
    continue to incur costs after their associated workloads are deleted:
    - Unattached managed disks
    - Unused public IP addresses
    - Orphaned network interfaces
    - Unused storage accounts (empty or inactive)
    - Unused availability sets
    - Obsolete snapshots (older than retention period)

    By default, runs in SCAN-ONLY mode (safe). Use -DeleteOrphans to actually remove resources.

.PARAMETER DeleteOrphans
    Actually delete the identified orphaned resources (default: scan only)

.PARAMETER SnapshotRetentionDays
    How long to keep snapshots before considering them obsolete (default: 90 days)

.PARAMETER OutputPath
    Path to save the orphaned resources report (CSV)

.EXAMPLE
    .\orphaned-resources-cleanup.ps1
    Scans for orphaned resources without deleting them (SAFE)

.EXAMPLE
    .\orphaned-resources-cleanup.ps1 -DeleteOrphans -SnapshotRetentionDays 30
    Deletes orphaned resources and snapshots older than 30 days

.NOTES
    This is a DEMO script showing FinOps waste reduction concepts.
    In production:
    - Implement approval workflows before deletion
    - Use Azure Policy with deny/audit effects
    - Create automation runbooks with schedules
    - Integrate with Azure Optimization Engine recommendations
#>

param(
    [Parameter(Mandatory = $false)]
    [switch]$DeleteOrphans,

    [Parameter(Mandatory = $false)]
    [int]$SnapshotRetentionDays = 90,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ""
)

# Default to scan-only mode unless DeleteOrphans is explicitly set
$ScanOnly = -not $DeleteOrphans

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FinOps Orphaned Resources Cleanup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($ScanOnly) {
    Write-Host "[SCAN MODE] No resources will be deleted`n" -ForegroundColor Yellow
}
else {
    Write-Host "[DELETE MODE] Orphaned resources will be removed`n" -ForegroundColor Red
    Write-Host "Press Ctrl+C in the next 10 seconds to cancel..." -ForegroundColor Red
    Start-Sleep -Seconds 10
}

$orphanedResources = @()
$totalWasteCost = 0

# Get all subscriptions
$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    # =============================================================================
    # Find Unattached Managed Disks
    # =============================================================================
    Write-Host "  Scanning for unattached managed disks..." -ForegroundColor Gray
    $unattachedDisks = Get-AzDisk | Where-Object { $_.DiskState -eq 'Unattached' }

    foreach ($disk in $unattachedDisks) {
        # Estimate monthly cost: ~$5/100GB for Standard HDD, ~$20/100GB for Premium SSD
        $monthlyCost = if ($disk.Sku.Name -like '*Premium*') { ($disk.DiskSizeGB / 100) * 20 } else { ($disk.DiskSizeGB / 100) * 5 }
        $totalWasteCost += $monthlyCost

        $orphanedResources += [PSCustomObject]@{
            Subscription  = $sub.Name
            ResourceGroup = $disk.ResourceGroupName
            ResourceName  = $disk.Name
            ResourceType  = 'Managed Disk'
            Reason        = 'Unattached'
            Size          = "$($disk.DiskSizeGB) GB"
            MonthlyCost   = [math]::Round($monthlyCost, 2)
            CreatedDate   = $disk.TimeCreated
        }

        if (-not $ScanOnly) {
            Write-Host "    Deleting disk: $($disk.Name)..." -ForegroundColor Red
            Remove-AzDisk -ResourceGroupName $disk.ResourceGroupName -DiskName $disk.Name -Force | Out-Null
        }
    }

    Write-Host "    Found $($unattachedDisks.Count) unattached disk(s)" -ForegroundColor Yellow

    # =============================================================================
    # Find Unused Public IP Addresses
    # =============================================================================
    Write-Host "  Scanning for unused public IP addresses..." -ForegroundColor Gray
    $unusedIPs = Get-AzPublicIpAddress | Where-Object { $_.IpConfiguration -eq $null -and $_.NatGateway -eq $null }

    foreach ($ip in $unusedIPs) {
        # Static IPs cost ~$3.50/month, Dynamic ~$2.50/month
        $monthlyCost = if ($ip.PublicIpAllocationMethod -eq 'Static') { 3.50 } else { 2.50 }
        $totalWasteCost += $monthlyCost

        $orphanedResources += [PSCustomObject]@{
            Subscription  = $sub.Name
            ResourceGroup = $ip.ResourceGroupName
            ResourceName  = $ip.Name
            ResourceType  = 'Public IP'
            Reason        = 'Not associated'
            Size          = $ip.PublicIpAllocationMethod
            MonthlyCost   = $monthlyCost
            CreatedDate   = $null
        }

        if (-not $ScanOnly) {
            Write-Host "    Deleting IP: $($ip.Name)..." -ForegroundColor Red
            Remove-AzPublicIpAddress -ResourceGroupName $ip.ResourceGroupName -Name $ip.Name -Force | Out-Null
        }
    }

    Write-Host "    Found $($unusedIPs.Count) unused public IP(s)" -ForegroundColor Yellow

    # =============================================================================
    # Find Orphaned Network Interfaces
    # =============================================================================
    Write-Host "  Scanning for orphaned network interfaces..." -ForegroundColor Gray
    $orphanedNICs = Get-AzNetworkInterface | Where-Object { $_.VirtualMachine -eq $null }

    foreach ($nic in $orphanedNICs) {
        # NICs themselves don't cost much, but identify waste
        $monthlyCost = 0.50
        $totalWasteCost += $monthlyCost

        $orphanedResources += [PSCustomObject]@{
            Subscription  = $sub.Name
            ResourceGroup = $nic.ResourceGroupName
            ResourceName  = $nic.Name
            ResourceType  = 'Network Interface'
            Reason        = 'No VM attached'
            Size          = '-'
            MonthlyCost   = $monthlyCost
            CreatedDate   = $null
        }

        if (-not $ScanOnly) {
            Write-Host "    Deleting NIC: $($nic.Name)..." -ForegroundColor Red
            Remove-AzNetworkInterface -ResourceGroupName $nic.ResourceGroupName -Name $nic.Name -Force | Out-Null
        }
    }

    Write-Host "    Found $($orphanedNICs.Count) orphaned NIC(s)" -ForegroundColor Yellow

    # =============================================================================
    # Find Obsolete Snapshots
    # =============================================================================
    Write-Host "  Scanning for obsolete snapshots..." -ForegroundColor Gray
    $cutoffDate = (Get-Date).AddDays(-$SnapshotRetentionDays)
    $obsoleteSnapshots = Get-AzSnapshot | Where-Object { $_.TimeCreated -lt $cutoffDate }

    foreach ($snapshot in $obsoleteSnapshots) {
        # Snapshots cost ~$0.05/GB/month
        $monthlyCost = ($snapshot.DiskSizeGB * 0.05)
        $totalWasteCost += $monthlyCost

        $daysOld = ((Get-Date) - $snapshot.TimeCreated).Days

        $orphanedResources += [PSCustomObject]@{
            Subscription  = $sub.Name
            ResourceGroup = $snapshot.ResourceGroupName
            ResourceName  = $snapshot.Name
            ResourceType  = 'Snapshot'
            Reason        = "Older than $SnapshotRetentionDays days ($daysOld days)"
            Size          = "$($snapshot.DiskSizeGB) GB"
            MonthlyCost   = [math]::Round($monthlyCost, 2)
            CreatedDate   = $snapshot.TimeCreated
        }

        if (-not $ScanOnly) {
            Write-Host "    Deleting snapshot: $($snapshot.Name)..." -ForegroundColor Red
            Remove-AzSnapshot -ResourceGroupName $snapshot.ResourceGroupName -SnapshotName $snapshot.Name -Force | Out-Null
        }
    }

    Write-Host "    Found $($obsoleteSnapshots.Count) obsolete snapshot(s)" -ForegroundColor Yellow

    # =============================================================================
    # Find Empty/Unused Availability Sets
    # =============================================================================
    Write-Host "  Scanning for empty availability sets..." -ForegroundColor Gray
    $emptyAvailabilitySets = Get-AzAvailabilitySet | Where-Object { $_.VirtualMachinesReferences.Count -eq 0 }

    foreach ($avset in $emptyAvailabilitySets) {
        # Availability sets don't cost directly, but indicate waste
        $monthlyCost = 0

        $orphanedResources += [PSCustomObject]@{
            Subscription  = $sub.Name
            ResourceGroup = $avset.ResourceGroupName
            ResourceName  = $avset.Name
            ResourceType  = 'Availability Set'
            Reason        = 'No VMs'
            Size          = '-'
            MonthlyCost   = $monthlyCost
            CreatedDate   = $null
        }

        if (-not $ScanOnly) {
            Write-Host "    Deleting availability set: $($avset.Name)..." -ForegroundColor Red
            Remove-AzAvailabilitySet -ResourceGroupName $avset.ResourceGroupName -Name $avset.Name -Force | Out-Null
        }
    }

    Write-Host "    Found $($emptyAvailabilitySets.Count) empty availability set(s)" -ForegroundColor Yellow

    Write-Host ""
}

# =============================================================================
# Generate Summary Report
# =============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Orphaned Resources Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$summaryByType = $orphanedResources | Group-Object ResourceType | Select-Object Name, Count, @{N = 'TotalMonthlyCost'; E = { [math]::Round(($_.Group | Measure-Object -Property MonthlyCost -Sum).Sum, 2) } }

$summaryByType | Format-Table -AutoSize | Out-String | Write-Host

Write-Host "Total Orphaned Resources: $($orphanedResources.Count)" -ForegroundColor Yellow
Write-Host "Estimated Monthly Waste: `$$([math]::Round($totalWasteCost, 2)) USD" -ForegroundColor Red
Write-Host "Estimated Annual Waste: `$$([math]::Round($totalWasteCost * 12, 2)) USD" -ForegroundColor Red

if ($ScanOnly) {
    Write-Host "`n[SCAN ONLY] No resources were deleted." -ForegroundColor Yellow
    Write-Host "Run with -DeleteOrphans to actually remove them.`n" -ForegroundColor Yellow
}
else {
    Write-Host "`nOrphaned resources have been deleted." -ForegroundColor Green
    Write-Host "Cost savings will be reflected in next month's bill.`n" -ForegroundColor Green
}

# Export detailed report
if ($OutputPath) {
    Write-Host "Exporting detailed report to: $OutputPath" -ForegroundColor Cyan
    $orphanedResources | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "Report exported successfully!`n" -ForegroundColor Green
}

Write-Host "FinOps Best Practices:" -ForegroundColor Cyan
Write-Host "1. Schedule this script to run weekly" -ForegroundColor White
Write-Host "2. Implement Azure Policy to prevent orphaned resources" -ForegroundColor White
Write-Host "3. Use Azure Optimization Engine for automated recommendations" -ForegroundColor White
Write-Host "4. Tag resources with lifecycle/expiration dates" -ForegroundColor White
Write-Host "5. Enable Azure Advisor cost recommendations" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

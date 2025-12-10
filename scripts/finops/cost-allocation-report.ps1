<#
.SYNOPSIS
    Generate a cost allocation report by CostCenter, Project, and Environment tags.

.DESCRIPTION
    This script demonstrates how to use Azure Cost Management API to generate
    cost allocation reports for FinOps chargeback/showback purposes. It groups
    costs by the required FinOps tags and exports to CSV/JSON.

.PARAMETER BillingPeriod
    Billing period to analyze (YYYYMM format, default: current month)

.PARAMETER OutputFormat
    Output format: CSV, JSON, or Console (default: Console)

.PARAMETER OutputPath
    Path to save the report file

.EXAMPLE
    .\cost-allocation-report.ps1
    Displays current month cost allocation in console

.EXAMPLE
    .\cost-allocation-report.ps1 -BillingPeriod 202412 -OutputFormat CSV -OutputPath "C:\Reports\costs.csv"
    Generates CSV report for December 2024

.NOTES
    This is a DEMO script showing FinOps cost allocation concepts.
    In production, use:
    - Azure Cost Management Power BI Connector
    - Azure Cost Management REST API with Azure Functions
    - FinOps Hub for advanced analytics
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$BillingPeriod = (Get-Date -Format 'yyyyMM'),

    [Parameter(Mandatory = $false)]
    [ValidateSet('Console', 'CSV', 'JSON')]
    [string]$OutputFormat = 'Console',

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FinOps Cost Allocation Report" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Parse billing period
$year = $BillingPeriod.Substring(0, 4)
$month = $BillingPeriod.Substring(4, 2)
$startDate = Get-Date -Year $year -Month $month -Day 1 -Hour 0 -Minute 0 -Second 0
$endDate = $startDate.AddMonths(1).AddDays(-1)

Write-Host "Billing Period: $($startDate.ToString('yyyy-MM-dd')) to $($endDate.ToString('yyyy-MM-dd'))`n" -ForegroundColor Yellow

# Get all subscriptions in the tenant
Write-Host "Fetching subscription data..." -ForegroundColor Yellow
$subscriptions = Get-AzSubscription

$allCosts = @()

foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Gray
    
    Set-AzContext -SubscriptionId $sub.Id | Out-Null
    
    # Query Azure Resource Graph for resource costs (simulated - real implementation would use Cost Management API)
    $query = @"
        resources
        | where type != 'microsoft.advisor/recommendations'
        | extend costCenter = tostring(tags['CostCenter'])
        | extend environment = tostring(tags['Environment'])
        | extend owner = tostring(tags['Owner'])
        | extend project = tostring(tags['Project'])
        | project name, type, resourceGroup, costCenter, environment, owner, project, subscriptionId
"@
    
    $resources = Search-AzGraph -Query $query -Subscription $sub.Id
    
    # Simulate cost data (in production, use Cost Management API)
    foreach ($resource in $resources) {
        $estimatedCost = Get-Random -Minimum 5 -Maximum 500
        
        $allCosts += [PSCustomObject]@{
            Subscription  = $sub.Name
            ResourceGroup = $resource.resourceGroup
            ResourceName  = $resource.name
            ResourceType  = $resource.type
            CostCenter    = $resource.costCenter ?? 'Untagged'
            Environment   = $resource.environment ?? 'Untagged'
            Owner         = $resource.owner ?? 'Untagged'
            Project       = $resource.project ?? 'Untagged'
            Cost          = $estimatedCost
        }
    }
}

# =============================================================================
# Generate Summary Report
# =============================================================================
Write-Host "`nGenerating cost allocation summary...`n" -ForegroundColor Yellow

$summary = @{
    ByCostCenter  = $allCosts | Group-Object CostCenter | Select-Object Name, @{N = 'TotalCost'; E = { ($_.Group | Measure-Object -Property Cost -Sum).Sum } } | Sort-Object TotalCost -Descending
    ByEnvironment = $allCosts | Group-Object Environment | Select-Object Name, @{N = 'TotalCost'; E = { ($_.Group | Measure-Object -Property Cost -Sum).Sum } } | Sort-Object TotalCost -Descending
    ByProject     = $allCosts | Group-Object Project | Select-Object Name, @{N = 'TotalCost'; E = { ($_.Group | Measure-Object -Property Cost -Sum).Sum } } | Sort-Object TotalCost -Descending
    ByOwner       = $allCosts | Group-Object Owner | Select-Object Name, @{N = 'TotalCost'; E = { ($_.Group | Measure-Object -Property Cost -Sum).Sum } } | Sort-Object TotalCost -Descending
}

$totalCost = ($allCosts | Measure-Object -Property Cost -Sum).Sum
$untaggedCost = ($allCosts | Where-Object { $_.CostCenter -eq 'Untagged' } | Measure-Object -Property Cost -Sum).Sum
$taggedPercentage = [math]::Round((($totalCost - $untaggedCost) / $totalCost) * 100, 2)

# =============================================================================
# Display Report
# =============================================================================
if ($OutputFormat -eq 'Console' -or $OutputFormat -eq 'CSV') {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Cost Allocation by Cost Center" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    $summary.ByCostCenter | Format-Table -AutoSize | Out-String | Write-Host
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Cost Allocation by Environment" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    $summary.ByEnvironment | Format-Table -AutoSize | Out-String | Write-Host
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Cost Allocation by Project" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    $summary.ByProject | Format-Table -AutoSize | Out-String | Write-Host
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Total Cost: `$$([math]::Round($totalCost, 2)) USD" -ForegroundColor Green
    Write-Host "Untagged Cost: `$$([math]::Round($untaggedCost, 2)) USD" -ForegroundColor Red
    Write-Host "Tagged Coverage: $taggedPercentage%" -ForegroundColor $(if ($taggedPercentage -gt 80) { 'Green' } else { 'Yellow' })
    Write-Host "========================================`n" -ForegroundColor Cyan
}

# =============================================================================
# Export Report
# =============================================================================
if ($OutputFormat -eq 'CSV' -and $OutputPath) {
    Write-Host "Exporting to CSV: $OutputPath" -ForegroundColor Yellow
    $allCosts | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "Report exported successfully!`n" -ForegroundColor Green
}
elseif ($OutputFormat -eq 'JSON' -and $OutputPath) {
    Write-Host "Exporting to JSON: $OutputPath" -ForegroundColor Yellow
    @{
        BillingPeriod = $BillingPeriod
        Summary       = $summary
        TotalCost     = $totalCost
        Details       = $allCosts
    } | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath
    Write-Host "Report exported successfully!`n" -ForegroundColor Green
}

Write-Host "Next Steps for FinOps Cost Allocation:" -ForegroundColor Cyan
Write-Host "1. Review untagged resources and apply required tags" -ForegroundColor White
Write-Host "2. Implement chargeback/showback to business units" -ForegroundColor White
Write-Host "3. Create monthly cost allocation reports" -ForegroundColor White
Write-Host "4. Use Azure Cost Management for detailed analysis" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

# ==============================================================================
# Azure Landing Zone Deployment Script
# ==============================================================================
# This script helps deploy all infrastructure layers in the correct order
# Run from repository root directory
# ==============================================================================

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('bootstrap', 'foundation', 'connectivity', 'identity', 'management', 'workload-lzs', 'workloads', 'all')]
    [string]$Layer = 'all',

    [Parameter(Mandatory = $false)]
    [ValidateSet('plan', 'apply', 'destroy', 'output')]
    [string]$Action = 'plan',

    [switch]$AutoApprove
)

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Azure Landing Zone Deployment" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Ensure we're in the repository root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Load environment variables from .env file if it exists
if (Test-Path ".env") {
    Write-Host "Loading environment variables from .env file..." -ForegroundColor Yellow
    Get-Content .env | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value, 'Process')
            Write-Host "  Set $key" -ForegroundColor Gray
        }
    }
    Write-Host ""
}
else {
    Write-Host "WARNING: .env file not found. Backend authentication may fail." -ForegroundColor Yellow
    Write-Host "Copy .env.example to .env and set your ARM_SUBSCRIPTION_ID" -ForegroundColor Yellow
    Write-Host ""
}

# Helper function to read subscription ID from terraform.tfvars
function Get-SubscriptionFromTfvars {
    param([string]$Path)

    $tfvarsPath = Join-Path $Path "terraform.tfvars"
    if (Test-Path $tfvarsPath) {
        $content = Get-Content $tfvarsPath -Raw
        if ($content -match 'subscription_id\s*=\s*"([^"]+)"') {
            return $matches[1]
        }
    }
    return $null
}

# Define all layers in deployment order
$allLayers = @()

# Bootstrap layer
$bootstrapLayer = @{
    Name         = "Bootstrap"
    Path         = "00-bootstrap"
    Subscription = Get-SubscriptionFromTfvars "00-bootstrap"
}

# Foundation layer
$foundationLayer = @{
    Name         = "Foundation"
    Path         = "01-foundation"
    Subscription = Get-SubscriptionFromTfvars "01-foundation"
}

# Platform landing zones
$platformLandingZones = @(
    @{Name = "Connectivity"; Path = "02-landing-zones\connectivity"; Subscription = Get-SubscriptionFromTfvars "02-landing-zones\connectivity" }
    @{Name = "Identity"; Path = "02-landing-zones\identity"; Subscription = Get-SubscriptionFromTfvars "02-landing-zones\identity" }
    @{Name = "Management"; Path = "02-landing-zones\management"; Subscription = Get-SubscriptionFromTfvars "02-landing-zones\management" }
)

# Automatically discover workload landing zones
$workloadLandingZones = @()
if (Test-Path "02-landing-zones\workloads") {
    Get-ChildItem "02-landing-zones\workloads" -Directory | ForEach-Object {
        $lzName = $_.Name
        $lzPath = "02-landing-zones\workloads\$lzName"
        $subscriptionId = Get-SubscriptionFromTfvars $lzPath

        if ($subscriptionId) {
            $workloadLandingZones += @{
                Name         = $lzName
                Path         = $lzPath
                Subscription = $subscriptionId
            }
        }
    }
}

# Automatically discover workloads (03-workloads)
$workloads = @()
if (Test-Path "03-workloads") {
    Get-ChildItem "03-workloads" -Directory | ForEach-Object {
        $workloadType = $_.Name
        Get-ChildItem "03-workloads\$workloadType" -Directory | ForEach-Object {
            $workloadName = $_.Name
            $workloadPath = "03-workloads\$workloadType\$workloadName"
            $subscriptionId = Get-SubscriptionFromTfvars $workloadPath

            if ($subscriptionId) {
                $workloads += @{
                    Name         = "$workloadType-$workloadName"
                    Path         = $workloadPath
                    Subscription = $subscriptionId
                }
            }
        }
    }
}

# Determine which layers to deploy based on user selection
$layersToDeploy = @()
switch ($Layer) {
    'bootstrap' { $layersToDeploy = @($bootstrapLayer) }
    'foundation' { $layersToDeploy = @($foundationLayer) }
    'connectivity' { $layersToDeploy = $platformLandingZones | Where-Object { $_.Name -eq 'Connectivity' } }
    'identity' { $layersToDeploy = $platformLandingZones | Where-Object { $_.Name -eq 'Identity' } }
    'management' { $layersToDeploy = $platformLandingZones | Where-Object { $_.Name -eq 'Management' } }
    'workload-lzs' { $layersToDeploy = $workloadLandingZones }
    'workloads' { $layersToDeploy = $workloads }
    'all' {
        $layersToDeploy = @($bootstrapLayer) + @($foundationLayer) + $platformLandingZones + $workloadLandingZones + $workloads
    }
}

Write-Host "Found $($layersToDeploy.Count) layer(s) to $Action" -ForegroundColor Yellow
Write-Host ""

# Results tracking
$results = @{}

# Function to run Terraform command for a layer
function Invoke-TerraformCommand {
    param(
        [hashtable]$Layer,
        [string]$Command
    )

    $layerName = $Layer.Name
    $layerPath = $Layer.Path
    $subscription = $Layer.Subscription

    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "Layer: $layerName" -ForegroundColor Cyan
    Write-Host "Path: $layerPath" -ForegroundColor Cyan
    Write-Host "Action: $Command" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""

    # Check if directory exists
    if (-not (Test-Path $layerPath)) {
        Write-Host "❌ Directory not found: $layerPath" -ForegroundColor Red
        return $false
    }

    Push-Location $layerPath

    try {
        # Set Azure subscription if it's a subscription ID (GUID format)
        if ($subscription -match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
            Write-Host "Setting Azure subscription: $subscription" -ForegroundColor Yellow
            az account set --subscription $subscription
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ Failed to set Azure subscription" -ForegroundColor Red
                return $false
            }
            $currentSub = az account show --query name -o tsv
            Write-Host "✓ Using subscription: $currentSub" -ForegroundColor Green
            Write-Host ""
        }

        # Verify ARM_SUBSCRIPTION_ID is set for backend storage account access
        if (-not $env:ARM_SUBSCRIPTION_ID) {
            Write-Host "ERROR: ARM_SUBSCRIPTION_ID environment variable is not set." -ForegroundColor Red
            Write-Host "This is required to access the Terraform backend storage account." -ForegroundColor Red
            Write-Host "Please create a .env file from .env.example and set your management subscription ID." -ForegroundColor Yellow
            exit 1
        }

        # Initialize
        Write-Host "Initializing Terraform for $layerName..." -ForegroundColor Yellow
        Write-Host "  Backend subscription: $env:ARM_SUBSCRIPTION_ID" -ForegroundColor Gray

        if (Test-Path "backend.tfbackend") {
            terraform init -backend-config="backend.tfbackend" -reconfigure
        }
        else {
            terraform init
        }        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Terraform init failed for $layerName" -ForegroundColor Red
            return $false
        }

        Write-Host "✓ Initialized successfully" -ForegroundColor Green
        Write-Host ""

        # Execute command
        $success = $true
        switch ($Command) {
            'plan' {
                Write-Host "Running terraform plan for $layerName..." -ForegroundColor Yellow
                Write-Host ""
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
                terraform plan -var-file="terraform.tfvars" -out=tfplan
                $success = $LASTEXITCODE -eq 0
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
            }
            'apply' {
                Write-Host "Running terraform apply for $layerName..." -ForegroundColor Yellow
                Write-Host ""
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
                if ($AutoApprove) {
                    terraform apply -var-file="terraform.tfvars" -auto-approve
                }
                else {
                    terraform apply -var-file="terraform.tfvars"
                }
                $success = $LASTEXITCODE -eq 0
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
            }
            'destroy' {
                Write-Host "Running terraform destroy for $layerName..." -ForegroundColor Yellow
                Write-Host "⚠️  WARNING: This will destroy all resources in $layerName!" -ForegroundColor Red
                Write-Host ""
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
                if ($AutoApprove) {
                    terraform destroy -var-file="terraform.tfvars" -auto-approve
                }
                else {
                    terraform destroy -var-file="terraform.tfvars"
                }
                $success = $LASTEXITCODE -eq 0
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
            }
            'output' {
                Write-Host "Terraform outputs for ${layerName}:" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
                terraform output
                $success = $LASTEXITCODE -eq 0
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
            }
        }

        if (-not $success) {
            Write-Host "❌ Terraform $Command failed for $layerName" -ForegroundColor Red
            return $false
        }

        Write-Host ""
        Write-Host "✓ $Command completed successfully for $layerName" -ForegroundColor Green
        Write-Host ""

        return $true
    }
    finally {
        Pop-Location
    }
}

# Run for each layer
foreach ($lyr in $layersToDeploy) {
    $success = Invoke-TerraformCommand -Layer $lyr -Command $Action
    $results[$lyr.Name] = $success

    if (-not $success -and $Layer -ne 'all') {
        # If running single layer and it fails, exit
        Write-Host "Deployment failed. Stopping." -ForegroundColor Red
        exit 1
    }

    # Small pause between layers
    if ($layersToDeploy.Count -gt 1) {
        Start-Sleep -Seconds 2
    }
}

# Summary
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Deployment Summary" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($lyr in $layersToDeploy) {
    $status = if ($results[$lyr.Name]) {
        $successCount++
        "✓ Success"
    }
    else {
        $failCount++
        "❌ Failed"
    }
    $color = if ($results[$lyr.Name]) { "Green" } else { "Red" }
    Write-Host "$($lyr.Name): $status" -ForegroundColor $color
}

Write-Host ""
Write-Host "Total: $successCount succeeded, $failCount failed" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Examples
Write-Host "Examples:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  # Plan bootstrap layer" -ForegroundColor Gray
Write-Host "  .\deploy.ps1 -Layer bootstrap -Action plan" -ForegroundColor White
Write-Host ""
Write-Host "  # Apply foundation layer" -ForegroundColor Gray
Write-Host "  .\deploy.ps1 -Layer foundation -Action apply -AutoApprove" -ForegroundColor White
Write-Host ""
Write-Host "  # Plan connectivity landing zone" -ForegroundColor Gray
Write-Host "  .\deploy.ps1 -Layer connectivity -Action plan" -ForegroundColor White
Write-Host ""
Write-Host "  # Apply all workload landing zones" -ForegroundColor Gray
Write-Host "  .\deploy.ps1 -Layer workload-lzs -Action apply -AutoApprove" -ForegroundColor White
Write-Host ""
Write-Host "  # Apply all workloads (03-workloads)" -ForegroundColor Gray
Write-Host "  .\deploy.ps1 -Layer workloads -Action apply -AutoApprove" -ForegroundColor White
Write-Host ""
Write-Host "  # Deploy everything in correct order" -ForegroundColor Gray
Write-Host "  .\deploy.ps1 -Layer all -Action apply -AutoApprove" -ForegroundColor White
Write-Host ""
Write-Host "  # View outputs for management" -ForegroundColor Gray
Write-Host "  .\deploy.ps1 -Layer management -Action output" -ForegroundColor White
Write-Host ""

# Exit with appropriate code
if ($failCount -gt 0) {
    exit 1
}

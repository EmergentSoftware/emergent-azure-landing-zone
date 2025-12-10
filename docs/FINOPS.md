# FinOps Toolkit Deployment

## Overview

The Microsoft FinOps Toolkit provides advanced cost management and optimization capabilities beyond basic Azure Cost Management budgets. This layer deploys FinOps Toolkit components to enable comprehensive cost governance.

## Available Components

### 1. Azure Optimization Engine (AOE) - **Recommended**

**What it does:**
- Automated cost optimization recommendations
- Resource rightsizing analysis
- Unused resource identification
- Azure Advisor integration
- Custom optimization rules

**Resources created:**
- Azure Automation Account with runbooks
- SQL Database for optimization data
- Storage Account for data export
- Log Analytics Workspace (or reuse existing)

**Cost:** ~$20-50/month (depends on scale)

### 2. FinOps Hub

**What it does:**
- Centralized cost data ingestion
- Advanced cost reporting
- Cost anomaly detection
- Integration with Azure Data Explorer or Microsoft Fabric

**Resources created:**
- Azure Data Factory for data ingestion
- Azure Data Explorer cluster OR Microsoft Fabric lakehouse
- Storage Account for cost exports

**Cost:** $100+/month (Azure Data Explorer) or Fabric pricing

## Deployment Strategy

For the ACME Landing Zone, we recommend starting with the **Azure Optimization Engine (AOE)** because:
- Lower cost ($20-50/month vs $100+)
- Immediate actionable recommendations
- Complements existing budget alerts
- Automated optimization workflows

## Prerequisites

1. ✅ Bootstrap infrastructure deployed (`00-bootstrap`)
2. ✅ Foundation layer with budgets deployed (`01-foundation`)
3. ✅ Management subscription available
4. Global Reader role assignment capability (optional, for enhanced features)

## Deployment Options

### Option 1: Quick Deploy via PowerShell (Recommended)

```powershell
# Clone FinOps Toolkit
cd c:\Code\ACME
git clone https://github.com/microsoft/finops-toolkit.git

# Deploy Azure Optimization Engine
cd finops-toolkit\src\optimization-engine
.\Deploy-AzureOptimizationEngine.ps1
```

**Interactive prompts will ask for:**
- Subscription to deploy to (use Management subscription)
- Resource group name (suggestion: `rg-finops-optimization-eastus2`)
- Azure region (suggestion: `eastus2`)
- SQL authentication method (recommendation: **Managed Identity**)
- Log Analytics workspace (can reuse from 02-landing-zones/management)

### Option 2: Terraform/Bicep Integration (Future)

We can integrate the AOE deployment into the Terraform codebase by:
1. Creating a Terraform module that wraps the Bicep deployment
2. Adding to `01-foundation` or new `04-finops-toolkit` layer

### Option 3: Manual Azure Portal Deploy

1. Go to [FinOps Toolkit deployment page](https://aka.ms/AzureOptimizationEngine/deployment)
2. Click "Deploy to Azure"
3. Fill in parameters
4. Deploy to Management subscription

## Recommended Configuration

| Parameter | Recommended Value | Reason |
|-----------|------------------|---------|
| **Subscription** | Management (`1302f5fd-f3b5-4eda-909c-e3ae2dfee3d6`) | Central governance location |
| **Resource Group** | `rg-finops-optimization-eastus2` | Consistent naming |
| **Region** | `eastus2` | Match ALZ region |
| **SQL Auth** | Managed Identity | No password management |
| **Log Analytics** | Reuse existing from management landing zone | Cost savings |
| **Resource Tags** | `{ "Purpose": "FinOps", "ManagedBy": "Terraform", "CostCenter": "Infrastructure" }` | Governance |

## Post-Deployment

After deployment:

1. **Review Recommendations** (available after first run, ~24 hours)
   ```powershell
   # Connect to SQL Database
   # Query recommendations table
   SELECT * FROM [RecommendationsView] WHERE RecommendationSubType = 'Shutdown'
   ```

2. **Configure Automation** (optional)
   - Enable auto-remediation for specific recommendation types
   - Set up email notifications via Action Groups
   - Integrate with existing cost alert action groups from 01-foundation

3. **Monitor Costs**
   - Add budget for FinOps Toolkit resources (~$30/month)
   - Track cost savings from implemented recommendations

## Integration with Existing Budgets

The FinOps Toolkit **complements** the existing budget system:

| Component | Purpose | When Triggered |
|-----------|---------|----------------|
| **Budgets** (01-foundation) | Reactive spending alerts | When costs exceed thresholds |
| **Azure Optimization Engine** | Proactive cost optimization | Continuous scanning for savings |

**Workflow:**
1. Budget alert fires when threshold exceeded
2. Finance team reviews AOE recommendations
3. Implement rightsizing/shutdown recommendations
4. Costs decrease, staying within budget

## Next Steps

1. **Deploy AOE** using Option 1 (PowerShell)
2. Wait 24-48 hours for first recommendations
3. Review recommendations with finance team
4. Implement quick wins (shutdown unused resources)
5. (Optional) Add Terraform module for infrastructure-as-code

## Cost Estimate

| Resource | Estimated Monthly Cost | Notes |
|----------|----------------------|--------|
| Automation Account | $0-2 | Free tier + minimal job hours |
| SQL Database (Basic) | $5 | Small optimization database |
| Storage Account | $1-3 | Blob storage for exports |
| Log Analytics (if new) | $10-20 | Data ingestion + retention |
| **Total** | **$16-30/month** | Can offset with savings found |

## Documentation

- [FinOps Toolkit Overview](https://aka.ms/finops/toolkit)
- [Azure Optimization Engine Deployment](https://aka.ms/AzureOptimizationEngine/deployment)
- [FinOps Framework](https://www.finops.org/framework/)

## Support

- GitHub Issues: https://github.com/microsoft/finops-toolkit/issues
- Microsoft Q&A: Search for "FinOps toolkit"

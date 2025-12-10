# FinOps Implementation Guide

## Overview

The ACME Landing Zone implements a comprehensive FinOps framework focused on cost visibility, governance, and optimization. This document outlines the deployed components, cost management strategies, and integration with Azure Cost Management.

## Greenfield Deployment Guidance

### Should You Deploy All FinOps Components on Day 1?

**Short Answer:** No. Use a **phased approach** based on workload maturity and spending levels.

### Recommended Deployment Strategy

#### ✅ Phase 1: Foundation (Day 1 - Deploy with Landing Zone)

Deploy these **always** as part of initial foundation deployment:

| Component | Cost | Why Deploy Early | Risk of Waiting |
|-----------|------|-----------------|----------------|
| **Budgets & Alerts** | $0 | Prevent cost surprises from day 1 | Uncontrolled spending, no guardrails |
| **Azure Policy (Tagging)** | $0 | Tags are hard to retrofit later | Impossible to track costs by project/owner |
| **Azure Advisor** | $0 | Built-in optimization recommendations | Miss easy cost savings |
| **Cost Anomaly Detection** | $0 | AI catches unusual spending patterns | Cost spikes go unnoticed |
| **Infracost CI/CD** | $0 | Prevent expensive mistakes in PRs | Deploy costly resources by accident |

**Deployment:**
```bash
cd 01-foundation
# Enable in terraform.tfvars:
enable_budgets = true
enable_cost_anomaly_detection = true
enable_finops_tagging_policies = true
```

**When to Deploy:** Immediately with foundation layer  
**Cost:** $0/month  
**Time Investment:** 30 minutes configuration

---

#### ⏳ Phase 2: Analytics & Optimization (Month 1-3 - After Workloads Running)

Deploy when you have **actual spending and resources to optimize**:

| Component | Cost | Deploy When | Prerequisites |
|-----------|------|-------------|--------------|
| **FinOps Hub** | $100-200/month | Monthly spend >$1,000 | 2+ subscriptions, cost data exists |
| **Azure Optimization Engine** | $20-50/month | 20+ VMs/resources deployed | Stable workloads running |
| **Log Analytics Workspace** | $30-50/month | Need RI alert automation | Part of FinOps Hub/AOE |

**Why Wait:**
- Don't pay $120-250/month for analytics when you have no data to analyze
- AOE needs resources to generate recommendations (empty environment = no value)
- FinOps Hub cost exports need actual spending to be useful

**Deployment:**
```bash
cd 02-landing-zones/management
# Enable in terraform.tfvars:
enable_finops_hub = true
enable_azure_optimization_engine = true
terraform apply
```

**When to Deploy:** After 1-2 months of production workloads  
**Cost:** $120-250/month  
**ROI Threshold:** Need >$500/month spend to justify costs  
**Time Investment:** 2-3 hours deployment + Power BI setup

---

#### 🎯 Phase 3: Advanced Optimization (Month 3-6 - Stable Workloads)

Deploy when **savings potential exceeds infrastructure costs**:

| Component | Cost | Deploy When | Expected Savings |
|-----------|------|-------------|------------------|
| **Reserved Instances** | Varies | 6+ months stable usage | 40-72% on committed workloads |
| **Power BI Dashboards** | $10/user | Executive reporting needed | N/A (visibility tool) |
| **RI Alert Automation** | $0 (uses Log Analytics) | After first RI purchase | Prevent utilization waste |

**Why Wait:**
- RIs require **long-term commitment** (1-3 years) - need usage pattern confidence
- Need 6+ months of utilization data to identify stable workloads
- Power BI dashboards are only valuable when stakeholders need them

**Deployment:**
```bash
# After analyzing FinOps Hub data:
# 1. Identify workloads with >80% consistent utilization
# 2. Follow RI approval workflow (docs/FINOPS-RI-APPROVAL-WORKFLOW.md)
# 3. Purchase RIs via Azure Portal or CLI
# 4. Enable RI monitoring alerts in Log Analytics
```

**When to Deploy:** After 3-6 months of stable workloads  
**Prerequisites:** FinOps Hub deployed, 6+ months usage data  
**Expected ROI:** $300-1,800/month net benefit (after infrastructure costs)

---

### Decision Matrix: Should I Deploy This Component?

| Monthly Azure Spend | Phase 1 (Always) | Phase 2 (Analytics) | Phase 3 (RIs) |
|---------------------|------------------|---------------------|---------------|
| **$0 - $500** | ✅ Budgets, Tags, Advisor, Anomaly | ❌ Too early (no data) | ❌ Too early |
| **$500 - $1,000** | ✅ Budgets, Tags, Advisor, Anomaly | ⚠️ Consider if >50 resources | ❌ Not enough spend |
| **$1,000 - $5,000** | ✅ Budgets, Tags, Advisor, Anomaly | ✅ Deploy FinOps Hub + AOE | ⚠️ Evaluate RIs after 6 months |
| **$5,000+** | ✅ Budgets, Tags, Advisor, Anomaly | ✅ Deploy FinOps Hub + AOE | ✅ Strong RI candidate |

---

### Example Timeline: Customer Greenfield Deployment

```
Month 1 (Foundation Deployment):
├── Deploy: Budgets, Tags, Advisor, Anomaly Detection, Infracost
├── Cost: $0/month
└── Action: Set $500/month budget per subscription

Month 2 (Workloads Deployed):
├── 15 VMs deployed, $800/month actual spend
├── Azure Advisor identifies $120/month savings (VM rightsizing)
└── Action: Implement Advisor recommendations

Month 3 (Analytics Deployment):
├── Spend stabilized at $1,200/month
├── Deploy: FinOps Hub ($100-200/month) + AOE ($20-50/month)
├── Cost: $120-250/month infrastructure
└── Action: Weekly AOE workbook review process

Month 6 (RI Evaluation):
├── 6 months usage data available
├── AOE identifies 10 VMs with >85% consistent utilization
├── Projected savings: $480/month (40% on committed VMs)
└── Action: Purchase first RIs, enable RI alert automation

Month 12 (Optimization Mature):
├── 60-80% RI coverage achieved
├── Total monthly savings: $600-800/month
├── Infrastructure cost: $120-250/month
└── Net benefit: +$350-680/month
```

---

### About the ACME Demo Environment

**Note:** The ACME Landing Zone repository has **all FinOps components deployed** (including FinOps Hub and Azure Optimization Engine) to serve as a **complete reference implementation** and **demo environment**.

For **production greenfield deployments**, follow the phased approach above rather than deploying everything on day 1.

---

## Known Issues & Workarounds

### Cost Management Visibility for Certain Subscriptions

**Issue:** When viewing costs at the Management Group level in Azure Cost Management, some subscriptions display "(Not supported)" instead of cost data.

**Root Cause:**
- CSP (Cloud Solution Provider) subscriptions have limited API support at management group scope
- Azure Cost Management APIs restrict cost aggregation for certain subscription billing types
- This is a platform limitation, not a configuration issue

**Impact:**
- Costs cannot be viewed in aggregate at `acme-alz` management group level
- Individual subscription cost data IS available when navigating directly to subscriptions

**Workarounds:**

1. **Immediate (For Presentations/Reports):**
   - Navigate to **Subscriptions** → Select specific subscription → **Cost Management**
   - Cost Analysis works correctly at individual subscription scope
   - Export cost data per subscription and aggregate manually if needed

2. **Recommended Long-Term Solution - Deploy FinOps Hub:**
   ```powershell
   cd c:\Code\ACME\emergent-alz\02-landing-zones\management
   # Deploy finops-hub.tf module
   terraform plan
   terraform apply
   ```
   
   **Benefits:**
   - ✅ Aggregates costs from ALL subscription types (CSP, EA, Pay-As-You-Go)
   - ✅ Centralized Log Analytics workspace with KQL query support
   - ✅ Power BI unified view across all 7 ACME subscriptions
   - ✅ Enables automated RI alert queries
   - ✅ Works around management group API limitations
   - ✅ Industry-standard FOCUS schema for multi-cloud compatibility

3. **Alternative - Use Azure CLI:**
   ```powershell
   # Get costs per subscription and aggregate
   $subscriptions = @(
     "acme-alz-management",
     "acme-alz-connectivity",
     "acme-alz-identity",
     "acme-portals-admin-prod",
     "acme-portals-admin-dev",
     "acme-portals-customer-prod",
     "acme-portals-customer-dev"
   )
   
   foreach ($sub in $subscriptions) {
     az consumption usage list --subscription $sub --start-date 2025-12-01 --end-date 2025-12-10
   }
   ```

## Current Implementation Status

### ✅ Deployed Components (01-foundation)

1. **Budgets & Budget Alerts**
   - 7 subscription-level budgets
   - Actual threshold (120%) and Forecasted threshold (130%) alerts
   - Action group integration for notifications
   - Terraform-managed via `terraform.tfvars`

2. **Cost Anomaly Detection**
   - AI-powered anomaly detection across 6 subscriptions
   - Automatic sensitivity tuning
   - 24-hour detection latency
   - Integration with existing action groups

3. **Azure Advisor Integration**
   - Cost recommendations monitoring across all 7 subscriptions
   - 6 recommendation types (VM right-sizing, RIs, idle resources, storage, databases, hybrid benefit)
   - Automated daily refresh
   - CLI commands for weekly reviews

4. **Reserved Instance & Savings Plan Management**
   - Monitoring configuration for 5 production subscriptions
   - 80% utilization threshold tracking
   - 3-tier approval workflow (<$10K, $10K-$50K, >$50K)
   - KQL queries for automated alerts (ready for Log Analytics deployment)
   - Power BI Rate Optimization integration
   - 40-72% potential savings on committed workloads

5. **Azure Policy for Cost Governance**
   - 80+ policy assignments including cost-focused policies
   - Tag governance (Environment, CostCenter, Application, Owner)
   - Audit-UnusedResources, Audit-AzureHybridBenefit, Deny-UnmanagedDisk
   - Enforcement at management group level with inheritance

6. **FinOps Hub (02-landing-zones/management)**
   - ✅ Deployed: Data Factory, Storage Account, Event Grid
   - Centralized cost data ingestion from all subscriptions
   - Power BI integration for advanced cost reporting
   - **Solves CSP subscription visibility limitations** (see Known Issues)
   - Enables automated RI alert KQL queries via Log Analytics
   - Daily cost export pipeline with FOCUS schema

7. **Azure Optimization Engine (02-landing-zones/management)**
   - ✅ Deployed: Automation Account, SQL Database, Storage, Log Analytics
   - 50+ automated runbooks for cost optimization recommendations
   - Resource rightsizing analysis (VMs, SQL, Storage, App Services)
   - Unused resource identification (disks, NICs, Load Balancers, App Gateways)
   - 11 Azure Workbooks for interactive analysis
   - Daily scheduled optimization scans
   - Integration with FinOps Hub and Azure Advisor

### 🔄 Planned Components

No additional components planned. All core FinOps capabilities are deployed.

## Deployment Status

All core FinOps components are fully deployed:

1. ✅ **FinOps Hub (Deployed)**
   - Resource Group: `acme-rg-management-finops-hub-prod-eastus`
   - Components: Data Factory (`acme-finopshub-mkkac1u6-engine-3funlapkpooie`), Storage Account, Event Grid
   - Status: Operational, ingesting cost data daily
   - Solves CSP subscription visibility issues
   - Power BI dashboards available for deployment

2. ✅ **Azure Optimization Engine (Deployed)**
   - Resource Group: `acme-rg-management-finops-aoe-prod-eastus`
   - Components: Automation Account (`acme-auto-finops-aoe`), SQL Database (`acme-sql-finops-aoe`), Log Analytics (`acme-la-finops-aoe`)
   - 50+ runbooks operational, 11 Azure Workbooks deployed
   - Status: Generating daily optimization recommendations

## Accessing Deployed FinOps Components

### FinOps Hub (Deployed)

**Resource Group:** `acme-rg-management-finops-hub-prod-eastus`

**Key Resources:**
- Data Factory: `acme-finopshub-mkkac1u6-engine-3funlapkpooie`
- Storage Account: `acmefinopsh3funlapkpooie`
- Event Grid: Automated trigger on cost export arrival

**Access Cost Data:**
```powershell
# View storage account containers
az storage container list --account-name acmefinopsh3funlapkpooie --auth-mode login --output table

# View Data Factory pipelines
az datafactory pipeline list --resource-group acme-rg-management-finops-hub-prod-eastus --factory-name acme-finopshub-mkkac1u6-engine-3funlapkpooie --output table
```

**Deploy Power BI Reports:**
1. Download FinOps Toolkit: https://aka.ms/finops/toolkit
2. Open Power BI Desktop → File → Open → `RateOptimization.storage.pbit`
3. Connect to: `https://acmefinopsh3funlapkpooie.dfs.core.windows.net/ingestion`
4. Publish to Power BI Service for sharing

### Azure Optimization Engine (Deployed)

**Resource Group:** `acme-rg-management-finops-aoe-prod-eastus`

**Key Resources:**
- Automation Account: `acme-auto-finops-aoe` (50+ runbooks)
- SQL Database: `acme-sql-finops-aoe/azureoptimization`
- Log Analytics: `acme-la-finops-aoe`
- Azure Workbooks: 11 interactive dashboards

**Access Optimization Recommendations:**
```powershell
# View workbooks in Azure Portal
az monitor app-insights workbook list --resource-group acme-rg-management-finops-aoe-prod-eastus --output table

# Query recommendations from Log Analytics
az monitor log-analytics query --workspace acme-la-finops-aoe --analytics-query "AzureOptimizationRecommendationsV1_CL | where TimeGenerated > ago(7d) | summarize count() by RecommendationSubType_s" --output table

# View SQL Database recommendations
# Azure Portal → SQL Database → acme-sql-finops-aoe → Query Editor
# SELECT TOP 100 * FROM [dbo].[Recommendations] ORDER BY GeneratedDate DESC
```

**Azure Workbooks:**
1. Azure Portal → `acme-rg-management-finops-aoe-prod-eastus` → Workbooks
2. Available dashboards:
   - **VM Rightsizing** - Underutilized VMs and recommendations
   - **Unattached Disks** - Orphaned storage costs
   - **Storage Optimization** - Tier and capacity recommendations
   - **SQL Optimization** - Database rightsizing
   - **App Service Plans** - Underutilized plans
   - **Network Optimization** - Idle Load Balancers, App Gateways
   - **High Availability** - VMs without availability sets
   - **ARM Optimizations** - Template best practices
   - **Cost Analysis** - Consumption trends
   - **Advisor Integration** - Consolidated recommendations
   - **Reservations** - RI utilization and coverage

### Enable RI Alert KQL Queries

With Log Analytics now deployed, enable automated RI alerts:

```powershell
# Get alert configuration with 3 KQL queries
cd c:\Code\ACME\emergent-alz\01-foundation
terraform output ri_alert_configuration

# Create alerts in Azure Portal
# Azure Portal → Log Analytics → acme-la-finops-aoe → Logs
# Create Alert Rules for:
# 1. Low Utilization (<80% for 7 days)
# 2. Expiring Soon (90 days warning)
# 3. Low Coverage (<60% of eligible workloads)
```

## Current FinOps Configuration

### Budgets (01-foundation/terraform.tfvars)

| Subscription | Budget Amount | Actual Threshold | Forecasted Threshold | Notes |
|--------------|--------------|------------------|---------------------|-------|
| portals-admin-prod | $10/month | 120% | 130% | Production with forecasted alerts |
| portals-admin-dev | $10/month | 120% | None | Dev without forecasted |
| portals-customer-prod | $10/month | 120% | 130% | Production with forecasted alerts |
| portals-customer-dev | $10/month | 120% | None | Dev without forecasted |
| management | $10/month | 120% | 130% | Platform subscription |
| connectivity | $10/month | 120% | 130% | Platform subscription |
| identity | $10/month | 120% | 130% | Platform subscription |

**Alert Logic:**
- **Actual Threshold (120%):** Triggers when real spending exceeds budget (e.g., $12 spent on $10 budget)
- **Forecasted Threshold (130%):** Triggers when Azure AI predicts spending will exceed threshold by month-end based on burn rate

### Reserved Instance Configuration

| Parameter | Current Value | Notes |
|-----------|--------------|-------|
| **Monitored Subscriptions** | 5 (production only) | Excludes dev subscriptions |
| **Utilization Threshold** | 80% | Alert if below for 7 days |
| **Coverage Target** | 60-80% | Of stable production workloads |
| **Approval Tiers** | 3 levels | <$10K, $10K-$50K, >$50K |
| **Resource Types** | 6 types | VMs, SQL, Cosmos DB, App Service, Synapse, Storage |
| **Expected Savings** | 40-72% | Depending on commitment term (1Y/3Y) |

## Daily Operations

### Weekly FinOps Review (Every Monday 10am)

1. **Azure Advisor Recommendations**
   ```powershell
   az advisor recommendation list --category Cost --output table
   ```
   - Focus on High impact recommendations
   - Validate with resource owners before implementation
   - Track savings in spreadsheet

2. **Azure Optimization Engine Workbooks**
   - Azure Portal → `acme-rg-management-finops-aoe-prod-eastus` → Workbooks
   - Review **VM Rightsizing** workbook (top priority)
   - Check **Unattached Disks** workbook (quick wins)
   - Review **Storage Optimization** (tier recommendations)
   - Log any high-value recommendations (>$100/month savings)

3. **Budget Alert Review**
   - Check for any budget threshold breaches (>80%, >100%, >120%)
   - Investigate forecasted alerts (130% threshold)
   - Take proactive action to reduce spend

4. **Anomaly Detection Review**
   - Azure Portal → Cost Management → Cost Alerts → Filter: Anomaly
   - Investigate any cost spikes
   - Identify root cause (scale-up, new deployment, config change)

5. **RI Utilization Monitoring**
   - Power BI → FinOps Hub Rate Optimization tab
   - Verify utilization >80% on all reservations
   - Review recommendations for new RI purchases
   - Check Azure Optimization Engine **Reservations** workbook

### Monthly FinOps Meeting

1. **Cost Trend Analysis**
   - Month-over-month cost comparison
   - Forecast vs actual variance
   - Top 3 cost drivers
   - Review FinOps Hub Power BI dashboard

2. **Optimization Wins**
   - Azure Optimization Engine implemented recommendations
   - Cost savings achieved (target: $100-500/month)
   - Top 5 pending recommendations by savings potential
   - Comparison: Advisor vs AOE vs actual implementations

3. **RI Portfolio Review**
   - Utilization metrics (target: ≥80%)
   - Coverage percentage (target: 60-80%)
   - Upcoming expirations (90-day warning)
   - Review FinOps Hub Rate Optimization workbook

4. **Policy Compliance**
   - Tag compliance percentage (target: 95%)
   - Unused resource count
   - Azure Hybrid Benefit adoption
   - Policy violations requiring remediation

5. **Savings Tracking**
   - Advisor recommendations implemented
   - AOE recommendations implemented
   - Estimated cost avoidance from RIs
   - Idle resource cleanup savings
   - Year-to-date cumulative savings

## Integration Between Components

The FinOps framework uses layered defense for cost management:

| Component | Purpose | When Triggered | Action |
|-----------|---------|----------------|--------|
| **Azure Policy** | Preventive | At resource deployment | Block expensive resources, enforce tags |
| **Azure Advisor** | Discovery | Daily scan | Identify optimization opportunities |
| **Azure Optimization Engine** | Deep Analysis | Daily automated runbooks | VM rightsizing, storage tier, unused resources |
| **Budgets - Forecasted** | Proactive | Predicted overspend | Take action before month-end |
| **Anomaly Detection** | Real-time | Unusual spending pattern | Investigate cost spikes |
| **Budgets - Actual** | Reactive | Threshold exceeded | Urgent investigation |
| **RI Monitoring** | Optimization | Low utilization detected | Adjust scope or exchange |
| **FinOps Hub** | Reporting | On-demand & scheduled | Executive dashboards, RI analysis |

**Example Workflow:**
1. **Week 1:** Azure Optimization Engine identifies 10 underutilized VMs (15% potential savings, $450/month)
2. **Week 2:** Azure Advisor validates similar recommendations with 12% savings estimate
3. **Week 3:** FinOps team validates with app owners using AOE SQL database and workbooks
4. **Week 4:** VMs right-sized via Terraform (Standard_D4 → Standard_D2)
5. **Month 2:** Budget forecasted alert no longer triggered (spending under control)
6. **Month 3:** FinOps Hub shows $480 actual savings in Power BI dashboard
7. **Month 4:** Evaluate stable right-sized workload for RI purchase (40-60% additional savings)

## Implementation Roadmap

### ✅ Completed (December 2025)

- [x] Budgets with actual + forecasted thresholds
- [x] Cost anomaly detection
- [x] Azure Advisor integration
- [x] Reserved Instance monitoring configuration
- [x] RI approval workflow documentation
- [x] Azure Policy for cost governance
- [x] Tag enforcement (Environment, CostCenter, Application, Owner)
- [x] Infracost CI/CD integration (cost estimation in PRs)
- [x] Branch protection with cost validation
- [x] **FinOps Hub deployed** (Data Factory, Storage, Event Grid)
- [x] **Azure Optimization Engine deployed** (Automation, SQL, Log Analytics, 50+ runbooks)

### 🔄 In Progress (Next 30 Days)

- [ ] Configure automated RI alert KQL queries in Log Analytics
- [ ] Deploy Power BI dashboards (FinOps Hub Rate Optimization, AOE Workbooks)
- [ ] Tag compliance remediation (target: 95%)
- [ ] Weekly Azure Advisor + AOE review process
- [ ] First RI purchase evaluation

### 📋 Planned (Month 1-3)

- [ ] Purchase first RIs (4-6 VM reservations)
- [ ] Achieve 80% RI utilization target
- [ ] Implement chargeback model by cost center
- [ ] Monthly cost optimization reports to leadership
- [ ] Export AOE recommendations to Power BI

### 🎯 Long-Term Goals (Month 6-12)

- [ ] 60-80% RI coverage on stable workloads
- [ ] 15-30% overall cost reduction vs baseline
- [ ] Quarterly RI portfolio optimization reviews
- [ ] Expand to Savings Plans for flexible compute
- [ ] Zero unplanned budget overruns

## Cost Estimate

| Component | Estimated Monthly Cost | Status | Notes |
|-----------|----------------------|--------|-------|
| **Current Deployment** | | | |
| Budgets | $0 | ✅ Deployed | Free Azure feature |
| Cost Anomaly Detection | $0 | ✅ Deployed | Free Azure feature |
| Azure Advisor | $0 | ✅ Deployed | Free Azure feature |
| Policy Assignments | $0 | ✅ Deployed | Free Azure feature |
| Infracost CI/CD | $0 | ✅ Deployed | Open source |
| FinOps Hub Storage | $50-100 | ✅ Deployed | Premium blob + retention |
| FinOps Hub Data Factory | $20-50 | ✅ Deployed | Daily pipeline executions |
| Log Analytics Workspace | $30-50 | ✅ Deployed | Data ingestion + retention |
| Azure Optimization Engine | $20-50 | ✅ Deployed | SQL + Automation + Storage |
| **Total Current Cost** | **$120-250/month** | | |
| **Planned Add-Ons** | | | |
| Power BI Pro licenses | $10/user | 🔄 Optional | Per user/month for dashboards |
| **Expected Savings** | **$500-2,000/month** | | 15-30% reduction from AOE + RI |
| **Net Benefit** | **+$250-1,880/month** | | Strong positive ROI |

## Key Outputs for Demo/Reporting

```powershell
cd c:\Code\ACME\emergent-alz\01-foundation

# Budget configuration
terraform output budget_summary

# Anomaly detection setup
terraform output cost_anomaly_detection

# Azure Advisor integration
terraform output advisor_cost_recommendations

# Reserved Instance monitoring
terraform output ri_savings_plan_monitoring

# RI alert configuration (3 KQL queries)
terraform output ri_alert_configuration

# RI documentation references
terraform output ri_management_documentation
```

## Related Documentation

### Internal Docs
- [FINOPS-ARCHITECTURE.md](./FINOPS-ARCHITECTURE.md) - FinOps Hub data flow and architecture
- [FINOPS-RI-APPROVAL-WORKFLOW.md](./FINOPS-RI-APPROVAL-WORKFLOW.md) - Reserved Instance purchase approval process
- [PRESENTATION-DEMO-GUIDE.md](./PRESENTATION-DEMO-GUIDE.md) - Comprehensive demo walkthrough

### Microsoft Resources
- [FinOps Toolkit Overview](https://aka.ms/finops/toolkit)
- [FinOps Hub Documentation](https://aka.ms/finops/hubs)
- [Azure Optimization Engine](https://aka.ms/AzureOptimizationEngine/deployment)
- [Azure Cost Management Best Practices](https://learn.microsoft.com/azure/cost-management-billing/costs/cost-mgt-best-practices)
- [Reserved Instances Overview](https://learn.microsoft.com/azure/cost-management-billing/reservations/save-compute-costs-reservations)
- [FinOps Framework](https://www.finops.org/framework/)

### CLI References
```powershell
# Azure Advisor
az advisor recommendation list --category Cost --output table

# Cost Management
az consumption usage list --subscription <SUB> --start-date 2025-12-01 --end-date 2025-12-10

# Reserved Instances
az reservations reservation list --output table
az consumption reservation recommendation list --scope /subscriptions/<ID> --term P1Y

# Anomaly Alerts
az monitor alert list --query "[?contains(name, 'anomaly')]"
```

## Support & Contact

- **FinOps Team Lead:** infrastructure@company.com
- **Slack Channel:** #finops-approvals (for RI purchase requests)
- **Weekly Meeting:** Mondays 10am (Azure Advisor review)
- **GitHub Issues:** https://github.com/microsoft/finops-toolkit/issues
- **Microsoft Q&A:** Search for "FinOps toolkit" or "Azure Cost Management"

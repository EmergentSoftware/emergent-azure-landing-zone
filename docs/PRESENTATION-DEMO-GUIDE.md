# FinOps & Enterprise-Scale Landing Zone Demo Guide

**Date:** December 10, 2025  
**Duration:** 60 minutes  
**Audience:** Leadership & Technical Teams

---

## Pre-Demo Checklist

### Azure Portal Tabs (Open Before Demo)
- [ ] **Cost Management** → Cost Analysis
- [ ] **Cost Management** → Budgets
- [ ] **Cost Management** → Cost Alerts (Anomaly view)
- [ ] **Policy** → Assignments (filtered to `acme-alz` management group)
- [ ] **Cost Management + Billing** → Reservations
- [ ] **Cost Management + Billing** → Recommendations

### VS Code Setup
- [ ] Open workspace: `c:\Code\ACME\emergent-alz`
- [ ] Navigate to: `01-foundation/` directory
- [ ] Preview open: `docs/FINOPS-RI-APPROVAL-WORKFLOW.md`
- [ ] Preview open: `docs/FINOPS-ARCHITECTURE.md`
- [ ] File open: `01-foundation/finops-ri-savings-plans.tf`
- [ ] File open: `01-foundation/finops-advisor.tf`

### Terminal Preparation
```powershell
# Authenticate to Azure
az login
az account show

# Test terraform outputs
cd c:\Code\ACME\emergent-alz\01-foundation
terraform output budget_summary
terraform output cost_anomaly_detection
terraform output ri_savings_plan_monitoring

# Test Azure Advisor CLI
az advisor recommendation list --category Cost --output table
```

### Power BI
- [ ] Open FinOps Hub report
- [ ] Navigate to **Rate Optimization** tab
- [ ] Ensure data is refreshed (last 24 hours)

### GitHub Repository
- [ ] Open: `https://github.com/emergentsoftware/emergent-azure-landing-zone`
- [ ] Navigate to Actions tab (show CI/CD workflows)
- [ ] Navigate to Branch protection rules

---

## Presentation Flow (60 minutes)

### 1. Executive Overview (5 min)

**Key Messages:**
- **Problem**: Azure costs growing 15-20% monthly without visibility or optimization
- **Solution**: Enterprise-scale FinOps governance framework integrated with Azure Landing Zones
- **Impact**: 
  - Real-time cost visibility across 7 subscriptions
  - Proactive anomaly detection (AI-powered)
  - Reserved Instance optimization potential: **40-72% savings**
  - Infrastructure as Code for consistency and auditability

**Slide Topics:**
- Current state: Manual cost reviews, reactive spending
- Future state: Automated governance, proactive optimization
- ROI projection: $X savings in Year 1

---

### 2. Azure Portal - Cost Management Overview (10 min)

**Navigation:** Azure Portal → Cost Management + Billing → Cost Management

#### 2.1 Cost Analysis
**Steps:**
1. Select scope: **Management Group** → `acme-alz`
2. Date range: **Last 30 days**
3. Group by: **Subscription**
   - Show 7 subscriptions
   - Identify top 3 cost drivers
4. Change group by: **Service name**
   - Virtual Machines, Storage, SQL Database, etc.
5. Add filter: **Tag** → `Environment=Production`
   - Isolate production costs from dev/sandbox

**Key Points:**
- Total monthly spend: $X,XXX
- Month-over-month trend: +X%
- Forecast for month-end: $X,XXX
- Top services consuming budget

#### 2.2 Cost Breakdown Demo
**Steps:**
1. Click **View details** on highest-cost subscription
2. Drill down to **Resource Group** level
3. Show daily cost trend chart
4. Click **Download** → Export to CSV

**Talking Points:**
- Granular visibility from management group → subscription → resource group → resource
- Trend analysis identifies gradual cost creep
- Export capability for offline analysis and reporting

#### 2.3 Accumulated Costs vs Forecast
**Steps:**
1. View chart: Actual vs Forecast
2. Highlight forecast line (AI prediction based on historical spend)
3. Show variance: "We're trending X% over/under budget"

**Key Insight:**
> "Forecasting helps us take action *before* month-end surprises"

---

### 3. Budgets & Budget Alerts (12 min)

**Navigation:** Cost Management → Budgets

#### 3.1 Budget Configuration Overview
**Steps:**
1. Show list of 7 budgets (one per subscription)
2. Click on budget: `budget-portals-admin-prod-monthly`
3. Review configuration:
   - **Amount**: $10/month (demo environment)
   - **Time grain**: Monthly
   - **Reset period**: Monthly billing cycle
   - **Start date**: January 1, 2025

#### 3.2 Alert Conditions Explained
**Click Edit → Alert Conditions**

**Show 2 Alert Types:**

1. **Actual Threshold: 120%**
   - Triggers when **actual spending** reaches $12 (120% of $10 budget)
   - "Real money has been spent"
   - Action: Immediate investigation required

2. **Forecasted Threshold: 130%**
   - Triggers when Azure **predicts** spending will reach $13 by month-end
   - Based on current burn rate and historical patterns
   - Action: Proactive cost reduction (scale down resources, optimize queries)

**Diagram on Whiteboard:**
```
Budget: $10
├── 80% ($8)  → Warning notification
├── 100% ($10) → Alert to engineering team
├── 120% ($12) → ACTUAL threshold → Finance + IT Ops alerted
└── 130% ($13) → FORECASTED threshold → Proactive action needed
```

#### 3.3 Action Groups Integration
**Click Alert Conditions → Action Group**

**Show:**
- Action Group: `ag-cost-alerts-infrastructure`
- Recipients: infrastructure@company.com
- Notification methods: Email, SMS, webhook to Slack
- Different action groups for different teams:
  - `ag-cost-alerts-infrastructure` → Platform teams
  - `ag-cost-alerts-it-operations` → Application teams
  - `ag-cost-alerts-marketing` → Business units (chargeback)

#### 3.4 Terraform-Managed Budgets
**Switch to VS Code Terminal**

```powershell
cd c:\Code\ACME\emergent-alz\01-foundation
terraform output budget_summary
```

**Highlight Output:**
```hcl
budget_summary = {
  "portals_admin_prod" = {
    name                  = "budget-portals-admin-prod-monthly"
    subscription_id       = "95d02110-..."
    amount                = 10
    actual_threshold      = 120
    forecasted_threshold  = 130  # Production gets forecasted alerts
    action_group_enabled  = false
    time_grain            = "Monthly"
  }
  # ... 6 more budgets
}
```

**Talking Points:**
- All budgets deployed via Infrastructure as Code (Terraform)
- Consistent configuration across subscriptions
- Easy to modify thresholds in `terraform.tfvars`
- Version controlled and auditable

**Best Practice Callout:**
> ✅ **Set forecasted alerts at 80-90%** to take action before overspend  
> ✅ **Set actual alerts at 100-120%** for urgent notification  
> ✅ **Separate action groups** for operational vs financial teams  
> ✅ **Production subscriptions** get both actual + forecasted alerts

---

### 4. Cost Anomaly Detection (8 min)

**Navigation:** Cost Management → Cost Alerts → Filter by "Anomaly"

#### 4.1 Portal Demo - Anomaly Alerts
**Steps:**
1. Click on any anomaly alert (if available)
2. Show details:
   - Service affected (e.g., Virtual Machines)
   - Cost spike: $X → $Y (increase of Z%)
   - Time detected: Within 24 hours of occurrence
   - Probable cause: Resource scale-up, new deployment, configuration change

**Anomaly Types Detected:**
- ☁️ Sudden resource scale-ups (VM size changes: Standard_D2 → Standard_D16)
- 🚀 Unexpected service deployments (new AKS cluster, SQL databases)
- ⚙️ Configuration changes (storage tier: Hot → Premium)
- 🌍 Regional pricing differences (workload moved to expensive region)

#### 4.2 Terraform-Deployed Anomalies
**Switch to VS Code Terminal**

```powershell
terraform output cost_anomaly_detection
```

**Highlight Output:**
```hcl
cost_anomaly_detection = {
  enabled = true
  configuration = {
    coverage          = "All 6 subscriptions"
    sensitivity       = "Automatic (AI-based detection)"
    notification_method = "Email via action groups"
  }
  alerts = {
    "connectivity"         = { display_name = "ACME Cost Anomaly - Connectivity..." }
    "management"           = { display_name = "ACME Cost Anomaly - Management..." }
    "portals_admin_dev"    = { ... }
    "portals_admin_prod"   = { ... }
    "portals_customer_dev" = { ... }
    "portals_customer_prod" = { ... }
  }
}
```

**Talking Points:**
- Enabled for all 6 production subscriptions
- AI learns spending patterns over 30 days
- Automatic sensitivity tuning (reduces alert fatigue)
- Catches issues budgets miss (sudden spikes within budget limits)

#### 4.3 Anomaly Detection vs Budgets
**Comparison Table (on screen):**

| Feature | Budgets | Anomaly Detection |
|---------|---------|-------------------|
| **Trigger** | Threshold reached (e.g., 120% of budget) | Unusual spending pattern detected |
| **Prediction** | Forecasted overspend | Unexpected variance from baseline |
| **Use Case** | Monthly cost control | Real-time spike detection |
| **Configuration** | Manual threshold | AI learns automatically |
| **Notification** | When threshold crossed | Within 24 hours of anomaly |

**Key Insight:**
> "Budgets protect against overspend. Anomalies catch unexpected waste. **Use both together.**"

**Best Practice Callout:**
> ✅ Anomaly detection complements budgets (catches spikes early)  
> ✅ AI baseline learning takes 30 days for accuracy  
> ✅ Review anomaly alerts daily (first 2 weeks), then weekly  

---

### 5. Azure Policy for Cost Governance (7 min)

**Navigation:** Azure Portal → Policy → Assignments → Filter Management Group: `acme-alz`

#### 5.1 Cost-Related Policies
**Scroll to find and click on these policies:**

1. **Audit-UnusedResources**
   - **Effect**: Audit (report non-compliance)
   - **Scope**: All subscriptions under `acme-alz`
   - **Purpose**: Identifies idle resources consuming budget
     - Unused disks (not attached to VMs)
     - Unused public IPs
     - Unused NICs (network interfaces)
     - Idle app service plans (no apps deployed)
   - **Action**: Weekly review and cleanup

2. **Audit-AzureHybridBenefit**
   - **Effect**: Audit
   - **Purpose**: Ensures Windows Server and SQL Server licenses use hybrid benefit
   - **Savings**: Up to 40% on Windows/SQL licensing costs
   - **Action**: Enable hybrid benefit on non-compliant VMs

3. **Deny-UnmanagedDisk**
   - **Effect**: Deny (prevent deployment)
   - **Purpose**: Blocks creation of unmanaged disks (legacy, expensive, poor performance)
   - **Savings**: Managed disks are cheaper and offer better features
   - **Action**: Prevents waste at deployment time

#### 5.2 Policy Effects for Cost
**Explain 3 Policy Effects:**

| Effect | Description | Cost Use Case |
|--------|-------------|---------------|
| **Audit** | Report non-compliance | Discover unused resources, missing tags |
| **Deny** | Block deployment | Prevent expensive VM SKUs, unmanaged disks |
| **Append** | Add required configuration | Auto-tag resources with CostCenter, Environment |

#### 5.3 Terraform Policy Output
**Switch to VS Code Terminal**

```powershell
terraform output policy_assignment_ids | Select-String -Pattern "Unused|Hybrid|Classic"
```

**Highlight Assignments:**
```
"acme-alz/Audit-UnusedResources"
"acme-alz/Audit-AzureHybridBenefit"
"acme-alz/Deny-Classic-Resources"
"acme-alz/Deny-UnmanagedDisk"
```

**Talking Points:**
- 80+ policy assignments deployed via Terraform
- Cost-focused policies prevent waste at source
- Audit policies identify cleanup opportunities
- Deny policies enforce standards (no expensive legacy resources)

**Tag Governance for Cost Allocation**
**Click on any resource → Tags**

**Required Tags (enforced by policy):**
- `Environment`: Production, Development, Sandbox
- `CostCenter`: Finance code for chargeback
- `Application`: Application name for tracking
- `Owner`: Team responsible for costs

**Best Practice Callout:**
> ✅ Use **Audit policies** for discovery, **Deny policies** for prevention  
> ✅ Tag governance enables cost allocation and chargeback models  
> ✅ Azure Hybrid Benefit saves 40% on Windows/SQL licensing  
> ✅ Review policy compliance weekly, remediate non-compliant resources  

---

### 6. Enterprise-Scale Landing Zone Best Practices (8 min)

**Navigation:** VS Code → `docs/FINOPS-ARCHITECTURE.md` (preview)

#### 6.1 Management Group Hierarchy
**Show Diagram:**

```
acme-alz (Root Management Group)
├── acme-platform (Shared Services)
│   ├── acme-management (FinOps Hub, Log Analytics, Monitoring)
│   ├── acme-connectivity (Hub VNet, Firewall, VPN Gateway)
│   └── acme-identity (Active Directory, Key Vault)
├── acme-workloads (Application Workloads)
│   └── acme-portals (Customer & Admin Portals)
│       ├── portals-admin-prod
│       ├── portals-admin-dev
│       ├── portals-customer-prod
│       └── portals-customer-dev
├── acme-sandbox (Experimentation, Auto-delete after 30 days)
└── acme-decommissioned (Cleanup, Delete-only mode)
```

**Explain Cost Impact:**

1. **Platform Subscriptions** (acme-platform):
   - Centralized shared services costs
   - Hub networking, monitoring, security
   - Allocated across workloads (showback model)
   - Budgets: $10-50/month per subscription

2. **Workload Subscriptions** (acme-workloads):
   - Application-specific costs
   - Direct chargeback to business units
   - Budgets: $50-500/month per subscription
   - Clear cost ownership

3. **Sandbox Subscriptions** (acme-sandbox):
   - Isolated experimentation budgets
   - Strict budgets: $5-10/month
   - Policy: Auto-delete resources after 30 days
   - Prevents "forgotten experiments" waste

4. **Decommissioned Subscriptions** (acme-decommissioned):
   - Policy: Deny all resource creation
   - Allow only deletions
   - 90-day retention for compliance
   - Then subscription canceled

#### 6.2 FinOps Governance at Scale
**Switch to Azure Portal → Management Groups**

**Show Policy Inheritance:**
1. Click on `acme-alz` (root)
   - Show policies applied: 15 policy assignments
   - These cascade to all child management groups
2. Click on `acme-workloads`
   - Inherits root policies + adds 20 workload-specific policies
   - Total: 35 effective policies
3. Click on `acme-sandbox`
   - Inherits root + adds restrictive policies (budget caps, auto-delete)
   - Total: 40 effective policies

**Cost Benefits of Hierarchy:**
- ✅ **Consistent governance** across all subscriptions
- ✅ **Policy inheritance** reduces duplication
- ✅ **Centralized budgets** at management group level
- ✅ **Workload isolation** limits blast radius of overspend
- ✅ **Subscription vending** automates new subscription creation with budgets/policies pre-configured

#### 6.3 Enterprise-Scale Cost Patterns
**Best Practices Implemented:**

1. **Hub-Spoke Networking**:
   - Centralized egress costs in hub subscription (connectivity)
   - Spoke subscriptions only pay for workload resources
   - Shared firewall, VPN gateway costs allocated via showback

2. **Shared Services Centralization**:
   - Log Analytics workspace: Single workspace in management subscription
   - Azure Monitor: Centralized alerts and dashboards
   - Security services: Microsoft Defender, Sentinel costs centralized
   - Benefit: Reduced per-subscription overhead

3. **Workload Isolation**:
   - Each application gets dedicated subscription
   - Blast radius containment: Budget overrun affects only one app
   - Clear cost ownership: No shared costs between apps

4. **Subscription Vending Machine** (future):
   - Automated subscription creation via Service Catalog
   - Pre-configured with:
     - Budget ($X based on request)
     - Policy assignments (inherit from parent MG)
     - Tags (CostCenter, Application, Owner)
     - RBAC (requestor gets Contributor role)
   - Time to provision: <5 minutes

#### 6.4 Cost Allocation Strategy
**Show in Cost Management → Cost Analysis**

**Group by Tag: `CostCenter`**
- Finance (cost center 1000): $X,XXX
- Engineering (cost center 2000): $X,XXX
- Marketing (cost center 3000): $X,XXX

**Group by Tag: `Environment`**
- Production: 70% of costs
- Development: 20% of costs
- Sandbox: 10% of costs

**Chargeback Model:**
```
Monthly Invoice per Cost Center:
┌─────────────────────────────────────────────────┐
│ Cost Center 2000 (Engineering)                  │
├─────────────────────────────────────────────────┤
│ Direct Costs (workload subscriptions): $X,XXX   │
│ Allocated Costs (shared services):     $XXX     │
│   - Networking (hub): $XX                       │
│   - Monitoring: $XX                             │
│   - Security: $XX                               │
├─────────────────────────────────────────────────┤
│ Total: $X,XXX                                   │
└─────────────────────────────────────────────────┘
```

**Best Practice Callout:**
> ✅ Management group hierarchy enables governance at scale  
> ✅ Budget per subscription = granular cost control  
> ✅ Tag enforcement enables chargeback/showback models  
> ✅ Centralized shared services reduce overhead  
> ✅ Sandbox subscriptions prevent "forgotten experiments" waste  

---

### 7. Azure Advisor Integration (5 min)

**Navigation:** VS Code → `01-foundation/finops-advisor.tf`

#### 7.1 Advisor Overview
**Explain Azure Advisor:**
- Built-in Azure service (no cost, always on)
- AI-powered recommendations across 5 categories:
  1. Cost
  2. Security
  3. Reliability
  4. Performance
  5. Operational Excellence

**Focus on Cost Recommendations (6 types):**

1. **VM Right-sizing** (10-20% savings):
   - Identifies underutilized VMs
   - Recommends smaller SKU (e.g., Standard_D4 → Standard_D2)
   - Based on CPU, memory, network utilization (last 7-30 days)

2. **Reserved Instances** (40-72% savings):
   - Analyzes workload stability
   - Recommends 1-year or 3-year commitments
   - Calculates ROI and breakeven period

3. **Idle Resources** (5-10% savings):
   - Unused VPN gateways
   - Unattached NICs (network interfaces)
   - Orphaned public IPs
   - Empty App Service plans

4. **Storage Optimization** (5-15% savings):
   - Delete unused storage accounts
   - Migrate infrequently accessed blobs to Cool/Archive tier
   - Enable lifecycle management policies

5. **Database Right-sizing** (10-30% savings):
   - Reduce DTU/vCore for underutilized SQL databases
   - Migrate to elastic pools (shared resources)

6. **Azure Hybrid Benefit** (40% savings):
   - Apply existing Windows Server licenses
   - Apply existing SQL Server licenses
   - Reduce licensing costs on VMs and databases

#### 7.2 CLI Demo - Advisor Recommendations
**Switch to Terminal**

```powershell
# List all cost recommendations
az advisor recommendation list --category Cost --output table

# Get recommendations for specific subscription
az advisor recommendation list \
  --category Cost \
  --subscription "portals-admin-prod" \
  --query "[].{Impact:impact, Resource:resourceMetadata.resourceId, Recommendation:shortDescription.solution}" \
  --output table
```

**Expected Output:**
```
Impact  Resource                                           Recommendation
------  -------------------------------------------------  --------------------------------
High    /subscriptions/.../vm-web-01                       Right-size virtual machine
Medium  /subscriptions/.../pip-unused                      Delete unused public IP
High    /subscriptions/.../sqldb-reporting                 Consider Reserved Capacity
Low     /subscriptions/.../storage-logs                    Move to Cool tier
```

#### 7.3 Terraform-Deployed Advisor Configuration
**Show in VS Code:** `01-foundation/finops-advisor.tf`

**Key Output:** `advisor_cost_recommendations`
```hcl
output "advisor_cost_recommendations" {
  value = {
    enabled = true
    coverage = "All 7 subscriptions monitored"
    
    recommendation_types = {
      vm_right_sizing        = { typical_savings = "10-20%", ... }
      reserved_instances     = { typical_savings = "40-72%", ... }
      idle_resources         = { typical_savings = "5-10%", ... }
      storage_optimization   = { typical_savings = "5-15%", ... }
      database_right_sizing  = { typical_savings = "10-30%", ... }
      hybrid_benefit         = { typical_savings = "40%", ... }
    }
    
    viewing_instructions = <<-EOT
      1. Azure Portal → Advisor → Recommendations → Filter: Cost
      2. Review High impact recommendations first
      3. Validate with resource owners before implementation
      4. Track savings in Cost Management
    EOT
    
    automation = "Recommendations auto-refresh every 24 hours"
  }
}
```

#### 7.4 Advisor Integration Workflow
**Process (show on screen):**

```mermaid
Weekly Advisor Review (Every Monday 10am)
    ↓
1. Run: az advisor recommendation list --category Cost
    ↓
2. Prioritize: Focus on High impact recommendations
    ↓
3. Validate: Confirm with resource owners (Slack, email)
    ↓
4. Implement: 
   - Right-size VMs (scale down)
   - Delete idle resources
   - Purchase RIs (follow approval workflow)
   - Enable Hybrid Benefit
    ↓
5. Track Savings: Monitor in Cost Management (before/after)
    ↓
6. Report: Monthly summary to leadership
```

**Expected Savings:**
> Typical organizations save **15-30%** by implementing Advisor recommendations:
> - VM Right-sizing: 10-20% savings
> - Reserved Instances: 40-72% savings (on committed workloads)
> - Idle Resource Cleanup: 5-10% savings
> - Storage Optimization: 5-15% savings

**Best Practice Callout:**
> ✅ Review Advisor recommendations **weekly** (Monday morning ritual)  
> ✅ Start with **High impact** recommendations first  
> ✅ **Validate with owners** before making changes (avoid breaking workloads)  
> ✅ **Track savings** in Cost Management (prove ROI)  
> ✅ Automate remediation where possible (Azure Policy for hybrid benefit)  

---

### 8. Reserved Instance Management ⭐ (12 min)

**Navigation:** Cost Management + Billing → Reservations

#### 8.1 Portal RI View
**Steps:**
1. Click **Reservations** (left menu)
2. Show reservation list (if any exist)
3. Click **Utilization** tab
   - Show utilization percentage (target: >80%)
   - Daily utilization trend chart
4. Click **Recommendations** tab
   - Azure-generated RI purchase recommendations
   - Based on last 30 days usage
   - Calculated savings and ROI

**If no reservations exist:**
> "We haven't purchased any RIs yet. Let me show you how we'll manage them using our Terraform configuration."

#### 8.2 Terraform RI Monitoring Configuration
**Switch to VS Code → `01-foundation/finops-ri-savings-plans.tf`**

**Scroll to output:** `ri_savings_plan_monitoring`

```powershell
# Terminal command
terraform output ri_savings_plan_monitoring
```

**Highlight Key Sections:**

1. **Monitored Subscriptions:**
   ```hcl
   monitored_subscriptions = 5  # Production only (excludes dev)
   
   # Specific subscriptions:
   - portals-admin-prod
   - portals-customer-prod
   - management
   - connectivity
   - identity
   ```

2. **Utilization Threshold:**
   ```hcl
   utilization_threshold = "80%"
   # Alert if utilization drops below 80% for 7 consecutive days
   ```

3. **Power BI Integration:**
   ```hcl
   power_bi_integration = {
     report_name = "FinOps Hub - Rate Optimization"
     data_sources = [
       "Reservation Details",
       "Reservation Recommendations",
       "Reservation Transactions",
       "Reservation Summaries"
     ]
     refresh_frequency = "Daily (automatic)"
   }
   ```

4. **CLI Commands (6 commands):**
   ```bash
   # List all reservations
   az reservations reservation list --output table
   
   # Show daily utilization
   az consumption reservation summary list \
     --grain daily \
     --reservation-order-id <ORDER_ID>
   
   # Get 1-year recommendations
   az consumption reservation recommendation list \
     --scope /subscriptions/<ID> \
     --term P1Y
   
   # Get 3-year recommendations
   az consumption reservation recommendation list \
     --scope /subscriptions/<ID> \
     --term P3Y
   
   # Calculate savings
   az consumption reservation recommendation list \
     --query '[].{NetSavings:properties.netSavings}'
   
   # Export transactions
   az consumption reservation transaction list \
     --output json > ri-transactions.json
   ```

5. **Resource Types Supported (6 types with specific savings):**
   ```hcl
   virtual_machines = {
     eligible = true
     typical_savings_1y = "40-60%"
     typical_savings_3y = "60-72%"
     recommendation = "Best for stable VM workloads"
   }
   
   sql_database = {
     eligible = true
     typical_savings_1y = "40-55%"
     typical_savings_3y = "55-65%"
     recommendation = "vCore model - reserve compute capacity"
   }
   
   cosmos_db = {
     eligible = true
     typical_savings_1y = "35-50%"
     typical_savings_3y = "50-65%"
     recommendation = "Reserve throughput (RU/s)"
   }
   
   # + 3 more (app_service, synapse_analytics, storage)
   ```

#### 8.3 CLI Demo - RI Recommendations
**Switch to Terminal**

```powershell
# Get RI recommendations for production subscription
az consumption reservation recommendation list \
  --scope /subscriptions/95d02110-3796-4dc6-af3b-f4759cda0d2f \
  --term P1Y \
  --look-back-period Last30Days \
  --query "[].{ResourceType:properties.resourceType, Quantity:properties.recommendedQuantity, AnnualCost:properties.totalCostWithReservedInstances, Savings:properties.netSavings}" \
  --output table
```

**Expected Output:**
```
ResourceType                    Quantity  AnnualCost  Savings
------------------------------  --------  ----------  -------
Microsoft.Compute/virtualMachines  4      $8,500      $4,200
Microsoft.Sql/servers/databases    2      $5,200      $2,100
```

**Explain Recommendation:**
> "Azure recommends purchasing 4 VM reservations and 2 SQL Database reservations. This would save us $6,300 annually (40% reduction)."

#### 8.4 Alert Configuration with KQL Queries
**Switch to VS Code → `01-foundation/finops-ri-alerts.tf`**

```powershell
terraform output ri_alert_configuration
```

**Show 3 Alert Types:**

1. **Low Utilization Alert**:
   - **Threshold**: <80% utilization over 7 days
   - **Frequency**: Daily check
   - **Severity**: Warning (2)
   - **Action**: Review sizing or scope (subscription vs resource group)
   - **KQL Query** (show in file):
     ```kql
     AzureCost_CL
     | where ReservationId_s != ""
     | where TimeGenerated >= ago(7d)
     | summarize UtilizationPercent = (count() / sum(Quantity_d)) * 100
       by ReservationName_s
     | where UtilizationPercent < 80
     ```

2. **Expiring Soon Alert**:
   - **Threshold**: 90 days before expiration
   - **Frequency**: Weekly check
   - **Severity**: Error (1)
   - **Action**: Evaluate renewal, exchange, or let expire
   - **KQL Query** (show in file):
     ```kql
     AzureCost_CL
     | where ReservationId_s != ""
     | extend ExpirationDate = todatetime(ReservationEndDate_s)
     | where ExpirationDate <= now() + 90d
     | project ReservationName_s, ExpirationDate, DaysUntilExpiration
     ```

3. **Coverage Low Alert**:
   - **Threshold**: <60% of eligible resources covered
   - **Frequency**: Weekly check
   - **Severity**: Informational (4)
   - **Action**: Review Advisor recommendations for new purchases
   - **KQL Query** (show in file):
     ```kql
     AzureCost_CL
     | summarize
         RICost = sumif(CostInBillingCurrency_d, PricingModel_s == "Reservation"),
         TotalCost = sum(CostInBillingCurrency_d)
     | extend RICoveragePercent = (RICost / TotalCost) * 100
     | where RICoveragePercent < 60
     ```

**Note:**
> "These KQL queries will run automatically once we deploy FinOps Hub Log Analytics workspace. For now, they're documented and ready to activate."

#### 8.5 Approval Workflow
**Switch to VS Code → `docs/FINOPS-RI-APPROVAL-WORKFLOW.md` (preview)**

**Show 3-Tier Approval Matrix:**

| Purchase Amount | Approval Required | Response Time |
|----------------|-------------------|---------------|
| **Under $10,000** | FinOps Team Lead | 1 business day |
| **$10,000 - $50,000** | Director of Engineering + CFO | 3 business days |
| **Over $50,000** | CTO + CFO | 5 business days |

**5-Phase Approval Process:**

1. **Identification** (FinOps team):
   - Review Azure Advisor recommendations
   - Run Savings Calculator analysis
   - Analyze resource consumption patterns (30-90 days)

2. **Analysis** (Engineering + FinOps):
   - ROI calculations (breakeven period, 3-year savings)
   - Workload stability assessment (has it been running 6+ months?)
   - Utilization projections (will we use 80%+ of capacity?)
   - Scope selection (subscription vs resource group)
   - Commitment duration (1-year vs 3-year ROI comparison)

3. **Approval Request** (FinOps team → Slack):
   - Post in **#finops-approvals** channel
   - Use structured template (show in doc):
     ```markdown
     **RI Purchase Request**
     - Resource Type: Virtual Machines (Standard_D4s_v3)
     - Quantity: 4 instances
     - Term: 1 year
     - Estimated Cost: $8,500/year
     - Expected Savings: $4,200/year (49% discount)
     - Breakeven: 7.3 months
     - Workload: Customer Portal (stable, 12 months uptime)
     - Subscription: portals-customer-prod
     - Requested By: @finops-lead
     ```

4. **Purchase** (Finance team):
   - Finance executes approved purchase
   - FinOps team configures monitoring (Power BI, alerts)
   - Document in RI inventory spreadsheet

5. **Monitoring** (Ongoing):
   - **Weekly**: FinOps team reviews utilization, responds to alerts
   - **Monthly**: Leadership reviews RI portfolio health, ROI validation
   - **Quarterly**: Optimization planning (exchanges, scope changes, renewals)

**8-Point Analysis Checklist** (before purchase):
- ✅ Workload Stability: 6+ months proven runtime
- ✅ Utilization History: Consistent usage patterns (no spikes/troughs)
- ✅ Commitment Duration: 1Y vs 3Y ROI comparison
- ✅ Scope Selection: Subscription vs resource group trade-offs
- ✅ ROI Calculations: Breakeven period, 3-year total savings
- ✅ Budget Alignment: Commitment fits approved budgets
- ✅ Capacity Planning: Growth/reduction plans next 1-3 years
- ✅ Business Justification: Strategic value, workload criticality

#### 8.6 Target Metrics & Review Cadence
**Show in doc:**

**Key Metrics:**
- **Target RI Utilization**: ≥80% (alert if below for 7 days)
- **Target Coverage**: 60-80% of stable production workloads
- **Minimum ROI**: Breakeven within 12 months

**Review Cadence:**
- **Weekly** (Operational): Utilization tracking, alert response, new recommendations
- **Monthly** (Tactical): Portfolio health, ROI validation, upcoming expirations (90 days)
- **Quarterly** (Strategic): Scope optimization, exchange opportunities, renewal planning

**Best Practice Callout:**
> ✅ Start with **1-year RIs** to minimize risk, move to 3-year after validation  
> ✅ Purchase RIs for **stable workloads only** (>6 months proven runtime)  
> ✅ Monitor utilization **weekly** to catch sizing/scope issues early  
> ✅ Set **renewal reminders 90 days** before expiration  
> ✅ Consider **Savings Plans** for flexible compute (VMs, App Service, Functions)  

---

### 9. Power BI Dashboard (4 min)

**Navigation:** Open Power BI → FinOps Hub Report

#### 9.1 Rate Optimization Tab
**Steps:**
1. Click **Rate Optimization** tab
2. Show key visuals:
   - **Current Reservations**: Active RI/SP inventory
   - **Utilization Trends**: Daily usage vs capacity (line chart)
   - **Coverage Analysis**: % of resources covered by commitments
   - **Recommendations**: Suggested new purchases (from Advisor)
   - **Savings Impact**: Cost avoidance from RIs/SPs (month-over-month)

**Highlight Metrics:**
- Total Active Reservations: X
- Average Utilization: Y% (target: ≥80%)
- Coverage: Z% (target: 60-80%)
- Annual Savings: $X,XXX

#### 9.2 Cost Trends Tab
**Steps:**
1. Click **Cost Trends** tab
2. Show visuals:
   - Monthly spend trend (last 12 months)
   - Top 10 services by cost
   - Cost by subscription
   - Cost by tag (CostCenter, Environment)

#### 9.3 Anomaly Detection Tab
**Steps:**
1. Click **Anomalies** tab
2. Show recent anomalies (if any)
3. Explain anomaly details: Service, cost spike, probable cause

**Talking Points:**
- Power BI refreshes daily (automatic)
- Data source: Cost Management exports to storage account
- Executive-friendly dashboards (no technical jargon)
- Drill-down capability (management group → subscription → resource)

**Best Practice Callout:**
> ✅ Power BI provides executive visibility without Azure Portal access  
> ✅ Schedule reports to email leadership monthly  
> ✅ Customize visuals for your organization's KPIs  

---

### 10. CI/CD & Infrastructure as Code (4 min)

**Navigation:** GitHub → `emergentsoftware/emergent-azure-landing-zone`

#### 10.1 Branch Protection Rules
**Steps:**
1. Navigate to **Settings** → **Branches** → **Branch protection rules**
2. Show rule for `main` branch:
   - ✅ Require pull request reviews (1 approval)
   - ✅ Require status checks to pass:
     - `terraform-validate` (syntax check)
     - `security-scan` (Checkov policy validation)
     - `infracost` (cost estimation)
   - ✅ Require conversation resolution
   - ✅ Enforce admins (no bypassing, even for admins)

**Benefits:**
- No direct pushes to main (all changes via PR)
- Peer review catches errors before deployment
- Automated validation prevents bad configurations
- Cost estimates visible before merge

#### 10.2 GitHub Actions Workflows
**Navigate to:** `.github/workflows/`

**Show Key Workflows:**

1. **terraform-validate.yml**:
   - Runs on: Every PR to `main`
   - Steps:
     1. Checkout code
     2. Setup Terraform
     3. `terraform fmt -check` (formatting)
     4. `terraform validate` (syntax)
     5. `terraform plan` (preview changes)
   - Status: Must pass for PR merge

2. **security-scan.yml**:
   - Runs on: Every PR to `main`
   - Tool: Checkov (policy-as-code scanner)
   - Checks:
     - No public IPs allowed
     - Encryption enabled on storage
     - HTTPS-only on web apps
     - NSGs attached to subnets
   - Status: Must pass for PR merge

3. **infracost.yml** ⭐:
   - Runs on: Every PR to `main`
   - Tool: Infracost (cost estimation)
   - Output: Comment on PR with cost breakdown
   - Example:
     ```
     Project: 01-foundation
     
     Name                           Monthly Qty  Unit   Monthly Cost
     
     azurerm_log_analytics_workspace.finops
     ├─ Capacity reservation (100 GB)  100  GB         $200.00
     └─ Data ingestion                 500  GB         $150.00
     
     azurerm_monitor_scheduled_query_rules_alert_v2.ri_low_utilization
     └─ Alert rule                       1   alerts      $0.50
     
     TOTAL (monthly)                                    $350.50
     
     Change from main: +$10.50 (+3%)
     ```
   - **Key Benefit**: Cost visibility BEFORE deployment
   - Decision point: Is this cost increase justified?

**Show PR with Infracost Comment:**
**Navigate to:** Pull Requests → Any merged PR

**Point out:**
- Infracost comment shows cost breakdown
- Change from previous deployment highlighted
- Reviewers can approve/reject based on cost impact
- Prevents "surprise" cost increases after deployment

#### 10.3 Deployment Order
**Show in:** `DEPLOYMENT-ORDER.md`

**Explain Sequence:**
```
1. 00-bootstrap (GitHub OIDC, state storage)
   ↓
2. 01-foundation (Management groups, policies, budgets)
   ↓
3. 02-landing-zones
   ├─ connectivity (Hub VNet)
   ├─ identity (AD)
   └─ management (Log Analytics, FinOps Hub)
   ↓
4. 03-workloads (Application subscriptions)
```

**Why This Order?**
- Bootstrap creates Terraform backend (state storage)
- Foundation creates governance framework (policies, budgets)
- Landing zones create shared infrastructure (networking, monitoring)
- Workloads depend on all previous layers

**Terraform Apply Process:**
```powershell
# 1. Navigate to layer
cd 01-foundation

# 2. Plan (preview changes)
terraform plan -out=tfplan

# 3. Review output (check for unexpected changes)

# 4. Apply (execute changes)
terraform apply tfplan

# 5. Verify outputs
terraform output
```

**Best Practice Callout:**
> ✅ All infrastructure deployed via **Terraform** (no manual Portal changes)  
> ✅ **Branch protection** enforces peer review and validation  
> ✅ **Infracost** provides cost visibility before deployment  
> ✅ **State backend** in Azure Storage enables team collaboration  
> ✅ **Deployment order** ensures dependencies are met  

---

### 11. Q&A & Implementation Roadmap (5 min)

**Immediate Actions (Week 1-2):**
- [ ] **Start weekly Advisor reviews** (every Monday 10am)
  - Run: `az advisor recommendation list --category Cost`
  - Prioritize High impact recommendations
  - Track savings in spreadsheet

- [ ] **Configure budget alert recipients**
  - Verify action group email addresses
  - Add SMS notifications for critical alerts (>120% threshold)
  - Test alert delivery

- [ ] **Review anomaly alerts daily** (first 2 weeks)
  - Cost Management → Cost Alerts → Anomaly view
  - Investigate root cause (VM scale-up, new deployments)
  - Adjust resources to prevent recurrence

**Short-Term Goals (Month 1-3):**
- [ ] **Deploy FinOps Hub Log Analytics workspace**
  - Enables automated RI alerts (KQL queries)
  - Centralizes cost data for Power BI
  - Terraform module: `02-landing-zones/management/finops-hub.tf`

- [ ] **Implement tag governance policies**
  - Enforce CostCenter, Environment, Application tags
  - Enable cost allocation and chargeback
  - Terraform: Add policy assignments to `01-foundation/finops-policies.tf`

- [ ] **Begin RI purchase evaluation**
  - Review Advisor RI recommendations weekly
  - Identify top 3 candidates (stable workloads, >6 months runtime)
  - Calculate ROI using Savings Calculator
  - Submit first approval request in #finops-approvals

**Mid-Term Goals (Month 3-6):**
- [ ] **Purchase first RIs** (following approval workflow)
  - Start with 1-year commitments (minimize risk)
  - Target: 4-6 VM reservations
  - Monitor utilization weekly (target: ≥80%)

- [ ] **Achieve 80% RI utilization target**
  - Review utilization in Power BI (Rate Optimization tab)
  - Adjust scope if utilization <80% (subscription → resource group)
  - Consider exchanges for underutilized RIs

- [ ] **Implement chargeback model**
  - Monthly cost reports per cost center
  - Tag compliance: 95% of resources tagged
  - Allocate shared services costs (hub networking, monitoring)

**Long-Term Goals (Month 6-12):**
- [ ] **60-80% RI coverage** on stable production workloads
  - VMs, SQL Databases, Cosmos DB, Storage
  - Balance: Cost savings vs flexibility

- [ ] **Quarterly cost optimization reviews**
  - Review RI portfolio health
  - Evaluate exchanges (underutilized → better fit)
  - Plan renewals (90 days before expiration)

- [ ] **Expand to Savings Plans** for flexibility
  - Azure Compute Savings Plans (VMs, App Service, Functions)
  - Similar discounts to RIs, but more flexible
  - Better for dynamic workloads (auto-scaling)

**Success Metrics (12-Month Targets):**
- 📉 **15-30% cost reduction** (vs baseline)
  - Advisor quick wins: 10-15%
  - Reserved Instances: 5-10% (additional)
  - Idle resource cleanup: 5%

- 📊 **95% tag compliance** (all resources tagged)
  - Enables accurate cost allocation
  - Supports chargeback model

- 🎯 **80%+ RI utilization** (no waste)
  - Weekly monitoring and optimization
  - Proactive exchange/refund for low utilization

- ⚠️ **Zero budget overruns** (without approval)
  - Forecasted alerts enable proactive action
  - Anomaly detection catches spikes early

- 📈 **Executive visibility** (monthly cost reviews)
  - Power BI dashboards
  - Automated reports to leadership

---

## Key Talking Points Summary

### Problem Statement
> "Our Azure costs have grown 15-20% monthly without clear visibility. We need proactive governance to optimize spend and prevent waste."

### Solution Overview
> "We've implemented an enterprise-scale FinOps framework with 4 pillars:
> 1. **Visibility**: Cost Management, budgets, anomaly detection
> 2. **Governance**: Policies, tags, approval workflows
> 3. **Optimization**: Azure Advisor, Reserved Instances (40-72% savings)
> 4. **Scale**: Infrastructure as Code, CI/CD with cost estimation"

### ROI Projection
> "Based on industry benchmarks, we expect:
> - **Year 1**: 15-30% cost reduction ($X,XXX savings)
> - **Year 2-3**: Additional 10-20% from RI optimization
> - **Total 3-year savings**: $XXX,XXX"

### Next Steps
> "We'll start with Advisor quick wins (weeks 1-2), deploy FinOps Hub (months 1-3), and purchase our first RIs (months 3-6). Weekly reviews ensure we stay on track."

---

## Demo Tips

### ⭐ **Lead with Value**
- Start every section with "This saves us $X" or "This prevents $X waste"
- Use real numbers from your environment (when available)
- Relate costs to business impact ("$10K/month = 2 FTEs")

### 📊 **Show, Don't Tell**
- Live CLI commands > Screenshots
- Real Azure Portal navigation > Slides
- Actual Terraform outputs > Hypothetical examples

### 🔄 **Emphasize the Workflow**
```
Discovery → Analysis → Approval → Implementation → Monitoring
(Advisor)   (KQL)      (Slack)     (Terraform)      (Alerts)
```

### ⚡ **Highlight Automation**
- "Before: Manual cost reviews monthly"
- "After: Automated anomaly detection daily"
- "Result: Catch issues 30 days earlier"

### 🎯 **Address Objections Proactively**

**Q: "RIs lock us in for 1-3 years. What if we need flexibility?"**
> A: "We start with 1-year terms on proven stable workloads (6+ months runtime). For dynamic workloads, we'll use Savings Plans (similar savings, more flexibility). Exchanges and refunds are available if needs change."

**Q: "How much time will FinOps operations require?"**
> A: "Initial setup: 2-4 weeks (mostly completed). Ongoing: 2-4 hours/week (Advisor reviews, alert triage, optimization). Automation reduces manual work over time."

**Q: "What if teams resist tag enforcement?"**
> A: "We'll phase it in: Audit mode (weeks 1-4), warnings (weeks 5-8), enforcement (month 3+). Policy prevents untagged resource creation. Training and documentation provided."

**Q: "Can we override policies in emergencies?"**
> A: "Yes. Break-glass process: Submit exemption request → Director approval → 30-day time-limited exemption → Review and remediate. Ensures compliance while allowing flexibility."

---

## Post-Demo Follow-Up

### Email to Attendees (Same Day):
**Subject:** FinOps Demo - Resources & Next Steps

**Body:**
```
Hi Team,

Thank you for attending today's FinOps & Enterprise-Scale Landing Zone demo.

📎 **Resources:**
- GitHub Repository: https://github.com/emergentsoftware/emergent-azure-landing-zone
- Documentation: /docs/FINOPS-ARCHITECTURE.md
- Approval Workflow: /docs/FINOPS-RI-APPROVAL-WORKFLOW.md
- Presentation Slides: [Link]

✅ **Immediate Actions:**
1. Review Advisor recommendations (Monday 10am weekly)
2. Verify budget alert recipients
3. Monitor anomaly alerts daily (first 2 weeks)

📅 **Next Meetings:**
- Week 2: FinOps Hub deployment planning
- Month 1: Tag governance implementation kickoff
- Month 3: First RI purchase review

❓ **Questions?** Reply to this email or post in #finops Slack channel.

Thanks,
[Your Name]
FinOps Team Lead
```

### Internal Retrospective (Next Day):
**What Went Well:**
- [ ] Demo flowed smoothly (timing, transitions)
- [ ] Live CLI commands executed successfully
- [ ] Audience engaged (questions, discussion)

**What to Improve:**
- [ ] Deeper dive into [specific topic]
- [ ] More real-world cost examples
- [ ] Simplify technical jargon for non-technical audience

**Action Items:**
- [ ] Record demo for future reference
- [ ] Create FAQ document based on Q&A
- [ ] Schedule follow-up sessions (hands-on workshops)

---

## Backup Slides / FAQs

### What is FinOps?
> FinOps (Financial Operations) is a cultural practice that brings financial accountability to the variable spend model of cloud. It's about making money work for cloud, not cloud work for money.

### Why Enterprise-Scale Landing Zones?
> Enterprise-Scale Landing Zones provide a proven architecture for Azure governance at scale. They include management groups, policies, budgets, and security controls pre-configured to Microsoft best practices.

### What is Infrastructure as Code (IaC)?
> IaC means defining infrastructure (VMs, networks, policies) in code files (Terraform) rather than manual Portal clicks. Benefits: Version control, peer review, automation, consistency, disaster recovery.

### What is Infracost?
> Infracost estimates cloud costs from Terraform code. It runs in CI/CD pipelines and comments on pull requests with cost breakdowns *before* deployment. This prevents "surprise" cost increases.

### Reserved Instances vs Savings Plans?
> - **Reserved Instances**: Specific VM size/region, 40-72% savings, less flexible
> - **Savings Plans**: Any VM size/region (compute family), similar savings, more flexible
> - **When to use**: RIs for stable predictable workloads, Savings Plans for dynamic workloads

### How do we handle dev/test costs?
> Dev/test environments use:
> - Separate subscriptions (isolated budgets)
> - Lower budgets ($5-10/month)
> - Auto-shutdown policies (VMs stop at 6pm, weekends)
> - Azure Dev/Test pricing (discounted rates)
> - Sandbox management group (strict policies)

---

**Good luck with your presentation!** 🎉

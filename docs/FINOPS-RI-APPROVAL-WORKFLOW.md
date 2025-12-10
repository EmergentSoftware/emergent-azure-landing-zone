# Reserved Instance & Savings Plan Approval Workflow

## Overview

This document defines the approval process for purchasing Azure Reserved Instances (RIs) and Savings Plans to ensure proper governance, financial accountability, and optimal return on investment for committed cloud spending.

## Purpose

- **Maximize Savings**: Ensure RI/SP purchases deliver expected 40-72% cost reductions
- **Minimize Risk**: Prevent over-commitment on unstable or temporary workloads
- **Financial Control**: Maintain appropriate approval chains for multi-year financial commitments
- **Operational Excellence**: Document decisions and track utilization post-purchase

## Approval Thresholds

| Annual Commitment Amount | Required Approvers | SLA |
|--------------------------|-------------------|-----|
| < $10,000 | FinOps Team Lead | 2 business days |
| $10,000 - $50,000 | Director of Engineering + CFO | 5 business days |
| > $50,000 | CTO + CFO | 10 business days |

### Threshold Calculation

- **1-Year RI**: Use annual cost (monthly × 12)
- **3-Year RI**: Use total 3-year cost for threshold determination
- **Multiple Purchases**: If buying multiple RIs in same month, aggregate for threshold

## Process Workflow

### Phase 1: Identification

**Weekly FinOps Team Activity:**
1. Review FinOps Hub Power BI Report → Rate Optimization tab
2. Check Azure Advisor Cost Recommendations
3. Analyze resource usage trends (6+ months for 1Y, 2+ years for 3Y)
4. Document workload owner requests via #finops-requests Slack channel

**Triggers:**
- Azure Advisor recommendation appears
- Workload owner requests RI for new production service
- Quarterly RI portfolio review identifies gaps

### Phase 2: Analysis & Business Case

**FinOps Team Responsibility:**

Complete the following analysis before submitting for approval:

#### Workload Stability Assessment
- [ ] Workload running consistently for required period
  - 1-Year RI: >= 6 months stable operation
  - 3-Year RI: >= 2 years stable operation, no deprecation planned
- [ ] Business confirms workload continuity
- [ ] No major architectural changes planned (migration, re-platform, decommission)

#### Utilization Projection
- [ ] Historical usage analysis shows >= 80% consistent utilization
- [ ] Growth/shrinkage trends analyzed and incorporated
- [ ] Seasonality patterns documented (if applicable)
- [ ] Peak/off-peak usage considered

#### Financial Analysis
- [ ] Current pay-as-you-go monthly cost calculated
- [ ] RI monthly cost calculated (including upfront if applicable)
- [ ] Total savings calculated (absolute $ and % discount)
- [ ] Break-even point determined
- [ ] ROI calculated over commitment term
- [ ] Budget impact assessed (CapEx vs OpEx implications)

#### Technical Validation
- [ ] Correct resource type and SKU identified
- [ ] Region/location confirmed
- [ ] Appropriate scope selected:
  - **Shared**: Flexible, applies across subscriptions (recommended for consistency)
  - **Subscription**: Limited to single subscription
  - **Resource Group**: Most restrictive, use only if required
- [ ] Exchange/refund policy understood

### Phase 3: Approval Request

**Submission Channel:** Post in `#finops-approvals` Slack channel

**Required Information:**

```markdown
### RI Purchase Request

**Basic Information:**
- **Request ID**: ACME-RI-2025-XXX
- **Requestor**: [Your Name]
- **Date**: YYYY-MM-DD
- **Urgency**: [Standard / High / Critical]

**Reservation Details:**
- **Resource Type**: [e.g., Virtual Machine, SQL Database, Cosmos DB, Storage]
- **SKU**: [e.g., Standard_D4s_v3, S3, 4 vCore]
- **Region**: [e.g., East US, West Europe]
- **Quantity**: [Number of instances/units]
- **Term**: [1-Year / 3-Year]
- **Payment Option**: [All Upfront / Partial Upfront / Monthly]
- **Scope**: [Shared / Subscription / Resource Group]
- **Subscription(s)**: [List affected subscriptions]

**Financial Summary:**
- **Current Monthly Cost (PAYG)**: $X,XXX.XX
- **RI Monthly Cost**: $X,XXX.XX
- **Monthly Savings**: $X,XXX.XX
- **Total Commitment Amount**: $XX,XXX.XX (1Y) or $XXX,XXX.XX (3Y)
- **Total Savings Over Term**: $XX,XXX.XX
- **Discount Percentage**: XX%
- **Break-Even Period**: X months

**Utilization Confidence:**
- [x] High - Consistent 24/7 production workload, no changes planned
- [ ] Medium - Mostly consistent, some variability expected
- [ ] Low - New workload or uncertain future

**Business Justification:**
[Provide detailed business case including:]
- Business criticality of workload
- Confirmed longevity with business stakeholders
- Alignment with strategic roadmap
- Risk assessment and mitigation

**Supporting Data:**
- Azure Advisor Recommendation ID: [if applicable]
- Historical Usage Report: [Link to Power BI or exported data]
- Business Owner Confirmation: [@mention stakeholder]

**Approval Chain:**
- [ ] FinOps Team Lead: [Name] - $X amount
- [ ] Director of Engineering: [Name] - $X amount [if > $10K]
- [ ] CFO: [Name] - $X amount [if > $10K]
- [ ] CTO: [Name] - $X amount [if > $50K]
```

### Phase 4: Approval Process

**Approver Responsibilities:**

1. **Review Business Case**: Validate workload stability and financial projections
2. **Check Budget Alignment**: Ensure funds available in appropriate budget line
3. **Assess Risk**: Evaluate downside if workload changes or is decommissioned
4. **Verify Compliance**: Confirm purchase aligns with cloud governance policies
5. **Document Decision**: Approve or request modifications via Slack thread

**Approval Methods:**
- ✅ **Approve**: React with `:white_check_mark:` in Slack + comment "Approved"
- ⏸️ **Hold**: React with `:pause_button:` + comment with questions/concerns
- ❌ **Deny**: React with `:x:` + comment with detailed reasoning

**Escalation Path:**
- If approver unavailable > 2 days, escalate to their manager
- For urgent/critical requests, contact approvers directly via DM

### Phase 5: Purchase Execution

**Finance Team Responsibility:**

Once all required approvals obtained:

1. **Azure Portal Purchase:**
   - Navigate to: Azure Portal → Cost Management + Billing → Reservations → Purchase
   - Select resource type, SKU, region, quantity, term
   - Choose scope (Shared recommended)
   - Select payment option
   - Review and confirm purchase

2. **Documentation:**
   - Record in RI Tracking Spreadsheet:
     - Purchase date, order ID, reservation ID
     - Resource details, term, cost
     - Approvers, business justification
     - Renewal reminder date (90 days before expiration)
   - Update budget forecast with RI impact
   - Notify FinOps team of completion

3. **Calendar Reminders:**
   - Set reminder for 90 days before expiration
   - Set reminder for mid-term review (6 months for 1Y, 18 months for 3Y)

### Phase 6: Post-Purchase Monitoring

**FinOps Team Responsibility:**

#### Week 1 Post-Purchase:
- [ ] Verify RI appears in Azure Portal → Reservations
- [ ] Confirm RI scope applied correctly to target resources
- [ ] Check FinOps Hub Power BI shows RI utilization data

#### Weekly Monitoring:
- [ ] Review RI utilization in FinOps Hub → Rate Optimization
- [ ] Alert if utilization drops below 80% (automated via Azure Monitor)
- [ ] Investigate and document low utilization causes

#### Monthly Reporting:
- [ ] Include RI portfolio health in monthly FinOps report
- [ ] Report savings realized vs projected
- [ ] Highlight any underutilized RIs requiring action

#### Quarterly Optimization:
- [ ] Review all RIs for scope optimization opportunities
- [ ] Consider exchanges for size/region changes
- [ ] Evaluate underperforming RIs for refund (within policy limits)
- [ ] Identify new RI purchase opportunities

#### Renewal Planning (90 Days Before Expiration):
- [ ] Analyze utilization over full term
- [ ] Confirm workload continuity with business stakeholders
- [ ] Decide: Renew, Exchange, or Let Expire
- [ ] If renewing, initiate new approval request
- [ ] If not renewing, plan for cost increase in budget

## Exchange & Refund Policy

### Exchanges (Allowed)
- **What**: Swap RI for different SKU, region, or scope
- **When**: Anytime during term, multiple times
- **Cost**: No additional fees, prorated value
- **Use Cases**:
  - Workload migrated to different region
  - VM size changed due to optimization
  - Scope adjustment (e.g., Shared to Subscription)

**Process:**
1. FinOps team initiates exchange in Azure Portal
2. Document reason in RI tracking spreadsheet
3. No approval needed if value remains similar
4. If significant value change (>$10K), follow approval process

### Refunds (Limited)
- **Azure Policy**: 1-year limit on refunds ($50K USD total lifetime per enrollment)
- **When to Consider**:
  - Major architectural change (migration off Azure service)
  - Business unit closure/divestiture
  - Severe over-commitment discovered early in term
- **Process**:
  1. Evaluate exchange options first (preferred)
  2. Calculate refund penalty (12% early termination fee for some services)
  3. Submit refund request with CFO approval
  4. Document lessons learned

## Key Performance Indicators

### RI Portfolio Health Metrics

| Metric | Target | Measurement Frequency |
|--------|--------|----------------------|
| RI Utilization | >= 80% | Weekly |
| RI Coverage (Production) | 60-80% | Monthly |
| Approval Cycle Time | < SLA | Per request |
| Savings Realization | >= 95% of projected | Monthly |
| Renewal Rate | >= 85% | Quarterly |

## Tools & Resources

### Internal Resources
- **Slack Channels**:
  - `#finops-approvals` - Submit RI purchase requests
  - `#finops-general` - General FinOps discussions
  - `#finops-requests` - Workload owner requests
- **Documentation**:
  - RI Tracking Spreadsheet: [Link to SharePoint/Excel]
  - FinOps Hub Power BI: [Link]
  - Azure Advisor: [Portal Link]
- **Contacts**:
  - FinOps Team Lead: [Name, Email]
  - Finance Team: [Name, Email]
  - Procurement: [Name, Email]

### Azure Resources
- **Azure Portal**: Cost Management + Billing → Reservations
- **Azure Advisor**: Recommendations → Cost
- **FinOps Hub**: Rate Optimization report
- **Azure CLI**: `az reservations` commands
- **Azure Documentation**: https://learn.microsoft.com/azure/cost-management-billing/reservations/

## Example Scenarios

### Scenario 1: Standard VM RI (1-Year)

**Situation**: Admin Portal production VMs running 24/7 for 8 months

**Analysis:**
- **Resource**: 4x Standard_D4s_v3 VMs, East US
- **Current Cost**: $1,402/month ($16,824/year)
- **1-Year RI**: $840/month ($10,080/year upfront)
- **Savings**: $562/month, 40% discount, $6,744 total savings
- **Break-Even**: 18 months into term
- **Utilization Confidence**: High (24/7 production)

**Approval Path**: $10,080 < $10K → FinOps Team Lead only

**Decision**: ✅ **APPROVED** - Stable workload, strong ROI

### Scenario 2: Cosmos DB RI (3-Year)

**Situation**: Customer Portal database, considering 3-year RI

**Analysis:**
- **Resource**: 10,000 RU/s Cosmos DB, East US
- **Current Cost**: $5,840/month ($70,080/year)
- **3-Year RI**: $3,504/month ($126,144 total)
- **Savings**: $2,336/month, 40% discount, $84,096 total savings
- **Term**: 3 years
- **Utilization Confidence**: High, but new workload (only 6 months old)

**Approval Path**: $126K > $50K → CTO + CFO required

**Decision**: ⏸️ **HOLD** - Request 1-year RI first, reassess for 3-year after 18 months of validated stability

### Scenario 3: SQL Database RI Exchange

**Situation**: Migrated database from East US to West US 2

**Analysis:**
- **Current RI**: SQL Database 8 vCore, East US, 6 months remaining
- **Need**: SQL Database 8 vCore, West US 2
- **Cost**: $0 (exchange, prorated value)
- **Impact**: Same savings continue, different region

**Approval Path**: No approval needed (exchange, same value)

**Action**: FinOps team executes exchange, documents in tracking spreadsheet

## Revision History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-12-10 | Initial workflow document | FinOps Team |

## Questions or Feedback

Contact the FinOps team:
- **Slack**: `#finops-general`
- **Email**: finops-team@acme.com
- **Office Hours**: Thursdays 2-3 PM EST

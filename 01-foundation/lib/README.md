# Custom Azure Policies for ACME Landing Zones

This directory contains custom Azure Policy definitions and assignments for the ACME Azure Landing Zone.

## Allowed Resource Types for Workloads

### Policy: `Allowed-Resource-Types-Workloads`

**Purpose**: Restricts which Azure resource types can be deployed in workload subscriptions to maintain security, compliance, and cost control.

**Effect**: `Deny` (blocks non-whitelisted resources from being created)

**Scope**: Applied to `acme-workloads` and `acme-portals` management groups

### Whitelisted Resource Types

The following Azure services are allowed in workload subscriptions:

#### Core Infrastructure
- Resource Groups, Deployments, Tags

#### Web & Compute
- **Azure Static Web Apps** (`Microsoft.Web/staticSites`)
- **App Services** (`Microsoft.Web/sites`, `Microsoft.Web/serverfarms`)
- **Virtual Machines** (`Microsoft.Compute/virtualMachines`)
  - VM Extensions, Availability Sets
- **VM Scale Sets** (`Microsoft.Compute/virtualMachineScaleSets`)
  - VMSS Extensions
- **Managed Disks** (`Microsoft.Compute/disks`, `Microsoft.Compute/snapshots`, `Microsoft.Compute/images`)

#### Data & Storage
- **Storage Accounts** (`Microsoft.Storage/storageAccounts`)
  - Blob, File, Table, Queue services and containers
- **Cosmos DB** (`Microsoft.DocumentDB/databaseAccounts`)
- **Azure SQL** (`Microsoft.Sql/servers`, `Microsoft.Sql/servers/databases`)
- **Azure Cache for Redis** (`Microsoft.Cache/redis`)

#### Security & Identity
- **Key Vault** (`Microsoft.KeyVault/vaults`)
  - Secrets, Keys, Access Policies
- **Managed Identity** (`Microsoft.ManagedIdentity/userAssignedIdentities`)

#### Networking
- **Virtual Networks** (`Microsoft.Network/virtualNetworks`)
- **Subnets** (`Microsoft.Network/virtualNetworks/subnets`)
- **VNet Peering** (`Microsoft.Network/virtualNetworks/virtualNetworkPeerings`)
- **Private Endpoints** (`Microsoft.Network/privateEndpoints`)
- **Private DNS Zones** (`Microsoft.Network/privateDnsZones`)
- **Network Interfaces** (`Microsoft.Network/networkInterfaces`)
- **Network Security Groups** (`Microsoft.Network/networkSecurityGroups`)
  - Security Rules included
- **Route Tables** (`Microsoft.Network/routeTables`)
  - Routes included
- **NAT Gateways** (`Microsoft.Network/natGateways`)
- **Public IPs** (`Microsoft.Network/publicIPAddresses`)
- **Application Gateways** (`Microsoft.Network/applicationGateways`)
- **Load Balancers** (`Microsoft.Network/loadBalancers`)
- **Bastion Hosts** (`Microsoft.Network/bastionHosts`)
- **Network Watcher** (`Microsoft.Network/networkWatchers`)
  - Flow Logs, Connection Monitors (auto-created by Azure)
- **Azure Firewall** (`Microsoft.Network/azureFirewalls`, `Microsoft.Network/firewallPolicies`)

> **Note**: Each workload/spoke subscription creates its own VNet for network isolation in hub-and-spoke architecture.

#### Monitoring & Observability
- **Application Insights** (`Microsoft.Insights/components`)
- **Log Analytics** (`Microsoft.OperationalInsights/workspaces`)
- **Alerts & Metrics** (various `Microsoft.Insights/*`)
  - Action Groups, Alert Rules, Metric Alerts, Scheduled Query Rules
- **Workbooks** (`Microsoft.Insights/workbooks`)
- **Data Collection Rules** (`Microsoft.Insights/dataCollectionRules`, `Microsoft.Insights/dataCollectionEndpoints`)
- **Diagnostic Settings** (`Microsoft.Insights/diagnosticSettings`)

#### Containers
- **Container Registry** (`Microsoft.ContainerRegistry/registries`)
- **Container Instances** (`Microsoft.ContainerInstance/containerGroups`)
- **AKS** (`Microsoft.ContainerService/managedClusters`)

#### Integration & Messaging
- **Service Bus** (`Microsoft.ServiceBus/namespaces`)
  - Queues, Topics
- **Event Hub** (`Microsoft.EventHub/namespaces`)
  - Event Hubs
- **Event Grid** (`Microsoft.EventGrid/topics`, `Microsoft.EventGrid/systemTopics`)
  - Event Subscriptions
- **Logic Apps** (`Microsoft.Logic/workflows`)

#### AI & Cognitive Services
- **Cognitive Services** (`Microsoft.CognitiveServices/accounts`)

#### API Management
- **API Management** (`Microsoft.ApiManagement/service`)

### Deployment

The policy is automatically applied when you run:

```powershell
cd 01-foundation
terraform apply
```

### Customization

To add or remove allowed resource types, edit:
```
01-foundation/lib/policy_definitions/Allowed-Resource-Types-Workloads.alz_policy_definition.json
```

Modify the `defaultValue` array in the `listOfResourceTypesAllowed` parameter.

### Testing the Policy

After deployment, test the policy:

```powershell
# This should SUCCEED (Static Web App is whitelisted)
az staticwebapp create --name test-swa --resource-group test-rg --location eastus2

# This should FAIL (Virtual Networks are not whitelisted for workloads)
az network vnet create --name test-vnet --resource-group test-rg --location eastus2
```

### Changing the Effect

You can change the policy effect in the assignment file:

**File**: `01-foundation/lib/policy_assignments/Allowed-Resource-Types-Workloads.alz_policy_assignment.json`

Available effects:
- `Deny` - Block creation of non-whitelisted resources (default, recommended)
- `Audit` - Log non-whitelisted resources but allow creation (testing mode)
- `Disabled` - Turn off the policy

### Architecture

```
acme-alz (Root)
├── acme-workloads (Workloads MG) ← Policy Applied Here
│   └── acme-portals (Portals MG) ← Policy Applied Here
├── acme-platform (Platform MG)
│   ├── acme-connectivity ← VNets deployed here
│   ├── acme-management
│   └── acme-identity
├── acme-sandbox
└── acme-decommissioned
```

### Rationale

**Why restrict resource types in workloads?**

1. **Security**: Prevents teams from deploying unapproved services that may introduce vulnerabilities
2. **Cost Control**: Limits expensive services that could cause budget overruns
3. **Compliance**: Ensures only approved services are used for regulatory compliance
4. **Network Isolation**: Each spoke subscription creates its own VNet, peered to the connectivity hub
5. **Best Practices**: Enforces hub-and-spoke network architecture with centralized services in connectivity

### Support

For policy exemptions or to request additional resource types, contact the Cloud Platform team.

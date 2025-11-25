# Shared Modules Directory

This directory contains wrapper modules for Azure Verified Modules (AVM) that can be reused across all workloads in the organization.

## Purpose

- **Insulation**: Protects workloads from breaking changes in upstream AVM modules
- **Consistency**: Ensures all workloads use the same module versions
- **Customization**: Centralized place to add ACME-specific defaults or logic
- **Version Control**: Single point to manage upstream module versions

## Available Modules

### Infrastructure

- **alz-wrapper**: Azure Landing Zone foundation module
  - Location: `modules/alz-wrapper/`
  - Upstream: `Azure/avm-ptn-alz/azurerm`

### Resource Management

- **resource-group**: Resource group wrapper
  - Location: `modules/resource-group/`
  - Upstream: `Azure/avm-res-resources-resourcegroup/azurerm`

### Compute

- **app-service-plan**: App Service Plan wrapper
  - Location: `modules/app-service-plan/`
  - Upstream: `Azure/avm-res-web-serverfarm/azurerm`

- **web-app**: Web App / App Service wrapper
  - Location: `modules/web-app/`
  - Upstream: `Azure/avm-res-web-site/azurerm`

### Networking

- **virtual-network**: Virtual Network wrapper
  - Location: `modules/virtual-network/`
  - Upstream: `Azure/avm-res-network-virtualnetwork/azurerm`

### Monitoring

- **application-insights**: Application Insights wrapper
  - Location: `modules/application-insights/`
  - Upstream: `Azure/avm-res-insights-component/azurerm`

- **log-analytics-workspace**: Log Analytics Workspace wrapper
  - Location: `modules/log-analytics-workspace/`
  - Upstream: `Azure/avm-res-operationalinsights-workspace/azurerm`

## Usage Pattern

All workloads should reference these wrapper modules using relative paths:

```hcl
# From workloads/my-app/main.tf
module "resource_group" {
  source = "../../modules/resource-group"
  
  name     = "rg-myapp-dev"
  location = "eastus"
  tags     = { Environment = "dev" }
}
```

## Updating Upstream Modules

To update an upstream AVM module version:

1. Navigate to the wrapper module directory
2. Edit `main.tf` and change the `version` constraint
3. Test in a dev workload first
4. Update documentation if interfaces changed
5. Roll out to other workloads

Example:

```hcl
# modules/web-app/main.tf
module "web_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "~> 0.14"  # Update this version
  ...
}
```

## Adding New Wrapper Modules

When adding a new AVM module to the organization:

1. Create a new directory under `modules/`
2. Create three files: `main.tf`, `variables.tf`, `outputs.tf`
3. Add a `README.md` with usage examples
4. Follow the existing wrapper pattern
5. Test thoroughly before using in production workloads

## Module Structure

Each wrapper module should follow this structure:

```
modules/
└── my-module/
    ├── main.tf           # Wraps upstream AVM module
    ├── variables.tf      # Input variables
    ├── outputs.tf        # Output values
    └── README.md         # Usage documentation
```

## Best Practices

1. **Keep it Simple**: Wrapper modules should be thin layers over AVM modules
2. **Pass Through Variables**: Don't override defaults unless ACME-specific
3. **Document Changes**: Any customization should be documented
4. **Version Pinning**: Use `~>` constraints for minor version updates
5. **Test Updates**: Always test version updates in non-production first

## Benefits

- **Reduced Risk**: Changes to upstream modules don't immediately break workloads
- **Easier Updates**: Update one place instead of many workloads
- **Compliance**: Add organization-wide compliance logic in wrappers
- **Onboarding**: New team members use consistent, documented modules

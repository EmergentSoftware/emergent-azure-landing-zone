# Maintainer Guide

This document is for maintainers of the `emergent-azure-landing-zone` repository.

## Repository Maintenance

### Completed Setup ✅

- [x] Repository created: `emergent-azure-landing-zone`
- [x] Removed all sensitive subscription/tenant IDs (replaced with placeholders)
- [x] Added MIT License
- [x] Added CONTRIBUTING.md
- [x] Added SECURITY.md
- [x] Updated README with Emergent Software branding
- [x] Added badges to README
- [x] Updated .gitignore to include example files
- [x] Removed sensitive files (tfplan)
- [x] Added GitHub issue templates
- [x] Added pull request template
- [x] Added CODEOWNERS file
- [x] Added GitHub Actions for Terraform validation
- [x] Added GitHub Actions for security scanning
- [x] Added .editorconfig

### Repository Configuration Checklist

Configure the following in GitHub repository settings:

#### General Settings
- [ ] Add description: "Official Emergent Software reference implementation for Azure Landing Zones using Terraform and Azure Verified Modules"
- [ ] Add topics: `azure`, `terraform`, `landing-zone`, `azure-verified-modules`, `infrastructure-as-code`, `cloud-adoption-framework`
- [ ] Set license to MIT
- [ ] Enable Issues
- [ ] Enable Discussions
- [ ] Disable Wiki (use docs/ folder instead)

#### Security
- [ ] Enable Security Advisories
- [ ] Enable Dependabot alerts
- [ ] Enable Code scanning (uses Security Actions workflows)
- [x] Configure branch protection rules for `main`

#### Pull Request Settings
- [x] Allow squash merging (recommended for clean history)
- [ ] Allow merge commits (disabled)
- [ ] Allow rebase merging (disabled)
- [x] Automatically delete head branches (cleanup after merge)
- [ ] Allow auto-merge (optional)

**Default commit message**: Use pull request title and description

#### Branch Protection Rules for `main` (Demo Configuration)
- [ ] ~~Require pull request reviews~~ (Disabled - demo environment)
- [x] Require status checks to pass before merging
  - Required checks (add these in GitHub UI):
    - `Terraform PR Checks / Find Changed Terraform Directories`
    - `Terraform PR Checks / Check *` (wildcard matches all terraform validation jobs)
    - `Security Scan / Checkov Security Scan` (blocks on security issues)
    - `Security Scan / tfsec Security Scan` (blocks on security issues)
- [x] Require conversation resolution before merging
- [x] Require linear history
- [x] Block force pushes
- [x] Block deletions
- [ ] Do not allow bypassing the above settings (Disabled for demo flexibility)

**Note**: Security scans now have `soft_fail: false` and will block merges if security issues are found.

#### Teams and Permissions
Update the CODEOWNERS file with actual team names:
- Replace `@emergentsoftware/platform-team` with your actual platform/infrastructure team
- Replace `@emergentsoftware/security-team` with your actual security team
- Create these teams in your GitHub organization if they don't exist

### Release Management

#### Creating a Release

1. **Version Tagging**: Follow semantic versioning (e.g., v1.0.0, v1.1.0, v2.0.0)
2. **Create Release**:
   ```bash
   git tag -a v1.0.0 -m "Initial Release - Emergent Azure Landing Zone"
   git push origin v1.0.0
   ```
3. **GitHub Release**: Create a release in GitHub UI with:
   - Tag: `v1.0.0`
   - Title: "v1.0.0 - Initial Release"
   - Release notes including features, changes, and known limitations

#### Version Guidelines
- **Patch** (v1.0.X): Bug fixes, documentation updates
- **Minor** (v1.X.0): New features, non-breaking changes
- **Major** (vX.0.0): Breaking changes, major refactors

### Monitoring and Maintenance

#### Weekly Tasks
- [ ] Review open issues and PRs
- [ ] Check GitHub Actions workflow runs
- [ ] Review security alerts from Dependabot

#### Monthly Tasks
- [ ] Update Azure Verified Modules to latest versions
- [ ] Review and update documentation
- [ ] Check for new Azure features to incorporate

#### Quarterly Tasks
- [ ] Review and update SECURITY.md
- [ ] Update Terraform version requirements
- [ ] Community health check (response times, issue closure rate)

### Common Maintenance Tasks

#### Updating AVM Module Versions
1. Check for new versions: [AVM Pattern Module](https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest)
2. Update version in `alz-foundation/modules/alz-wrapper/main.tf`
3. Test thoroughly before merging
4. Document changes in release notes

#### Handling Security Issues
Follow the process outlined in SECURITY.md:
1. Issues reported to security@emergentsoftware.com
2. Triage within 48 hours
3. Fix and test
4. Create security advisory
5. Release patch version

## Contact

For questions about repository maintenance, contact the Platform Team.

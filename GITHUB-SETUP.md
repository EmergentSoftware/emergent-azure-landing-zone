# Emergent Software - Azure Landing Zone Reference Implementation

Official reference implementation for deploying production-ready Azure Landing Zones.

## Repository Name Suggestions

Based on industry standards and clarity, here are recommended repository names:

### Recommended (Pick One):

1. **`emergent-azure-landing-zone`** ⭐ (Recommended)
   - Clear, professional, brand-aligned
   - Follows industry naming patterns
   - Easy to find and remember

2. **`azure-landing-zone-terraform`**
   - Emphasizes the tool (Terraform)
   - Good for organizations with multiple IaC approaches

3. **`emergent-alz-reference`**
   - Concise using ALZ acronym
   - Clearly a reference implementation

4. **`azure-foundation-terraform`**
   - Emphasizes foundational nature
   - Generic enough for broader use

5. **`emergent-cloud-foundation`**
   - Future-proof for multi-cloud
   - Broader scope

### Naming Convention Used:
- `{organization}-{purpose}-{technology}`
- All lowercase with hyphens
- Descriptive and searchable
- Professional and clear

## GitHub Repository Checklist

Before making this repository public:

### ✅ Completed
- [x] Removed all sensitive subscription/tenant IDs (replaced with placeholders)
- [x] Added MIT License
- [x] Added CONTRIBUTING.md
- [x] Added SECURITY.md
- [x] Updated README with Emergent Software branding
- [x] Added badges to README
- [x] Updated .gitignore to include example files
- [x] Removed sensitive files (tfplan)

### 📋 Recommended Next Steps

1. **Choose Repository Name** (see suggestions above)

2. **Create GitHub Repository**
   ```bash
   # Initialize git if not already done
   git init
   git add .
   git commit -m "Initial commit: Emergent Software Azure Landing Zone Reference Implementation"
   
   # Add remote (replace with your repo name)
   git remote add origin https://github.com/emergentsoftware/emergent-azure-landing-zone.git
   git branch -M main
   git push -u origin main
   ```

3. **Configure Repository Settings**
   - Enable Issues
   - Enable Discussions
   - Enable Security Advisories
   - Add topics: `azure`, `terraform`, `landing-zone`, `azure-verified-modules`, `infrastructure-as-code`, `cloud-adoption-framework`
   - Add description: "Official Emergent Software reference implementation for Azure Landing Zones using Terraform and Azure Verified Modules"
   - Set license to MIT

4. **Create Initial Release**
   - Tag: `v1.0.0`
   - Title: "Initial Release - Emergent Azure Landing Zone"
   - Include deployment guide and known limitations

5. **Add GitHub Actions** (Optional)
   - Terraform fmt/validate checks
   - Security scanning (e.g., tfsec, checkov)
   - Automated documentation generation

6. **Documentation Enhancements**
   - Add architecture diagrams
   - Add video walkthrough or demo
   - Create wiki for additional documentation
   - Add FAQ section

7. **Community Features**
   - Add CODEOWNERS file
   - Create issue templates
   - Create pull request template
   - Add community health files

8. **Update References**
   - Replace "acme" references with actual organization name if any remain
   - Update contact email in SECURITY.md
   - Add company website links

## What's Already Secured

✅ **No hardcoded credentials** - All sensitive IDs replaced with placeholders  
✅ **Example files safe** - All `.tfvars.example` files use dummy values  
✅ **Gitignore configured** - Sensitive files excluded  
✅ **Documentation complete** - README, LICENSE, CONTRIBUTING, SECURITY  
✅ **Professional branding** - Emergent Software branding applied  
✅ **Best practices** - Follows OSS best practices  

## Repository Features

- ✅ Production-ready Azure Landing Zone
- ✅ Azure Verified Modules (AVM) integration
- ✅ Wrapper module pattern for customization
- ✅ Separate corporate and online landing zones
- ✅ Complete networking infrastructure
- ✅ Monitoring and diagnostics setup
- ✅ Example workload deployments
- ✅ Comprehensive documentation
- ✅ Step-by-step deployment guide

## Final Recommendation

**Recommended Repository Name:** `emergent-azure-landing-zone`

This name is:
- Professional and branded
- Clear about purpose (Azure Landing Zone)
- Follows GitHub naming conventions
- Easy to search and discover
- Scales well (can add `-terraform`, `-bicep` variants later)

The repository is now ready to be made public! 🚀

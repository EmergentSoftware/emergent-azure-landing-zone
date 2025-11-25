# Security Policy

## Supported Versions

We release updates for this Azure Landing Zone reference implementation regularly. Please use the latest version for the best security and features.

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| Older   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability in this repository, please report it by emailing:

**security@emergentsoftware.net**

Please include:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### What to Expect

- We will acknowledge receipt of your report within 48 hours
- We will provide an estimated timeline for a fix
- We will notify you when the vulnerability is fixed
- We will credit you in the fix announcement (unless you prefer to remain anonymous)

## Security Best Practices

When using this reference implementation:

### Credential Management

- **Never commit credentials** to version control
- Use Azure Managed Identities where possible
- Store secrets in Azure Key Vault
- Use Terraform variables for sensitive data
- Ensure `.tfvars` files are in `.gitignore`

### Access Control

- Follow principle of least privilege
- Use Azure RBAC for access management
- Enable MFA for all user accounts
- Review and audit access regularly

### Network Security

- Use private endpoints where applicable
- Implement network segmentation
- Enable DDoS protection for public-facing resources
- Use Azure Firewall or Network Security Groups

### Monitoring & Compliance

- Enable Azure Security Center
- Configure diagnostic logging
- Set up alerts for suspicious activity
- Regularly review policy compliance
- Use Azure Policy for governance

### Terraform State Security

- Store Terraform state in Azure Storage with encryption
- Enable versioning on state storage
- Use state locking
- Restrict access to state files
- Consider using Terraform Cloud or Azure DevOps for state management

## Azure-Specific Security Considerations

### Subscription Isolation

- Use separate subscriptions for different environments
- Implement management group hierarchy as shown in this repo
- Apply policies at appropriate scopes

### Policy Enforcement

- Review all policy assignments before deployment
- Test policies in audit mode first
- Document policy exemptions
- Regularly review policy compliance

### Identity & Access

- Use Managed Identities instead of service principals where possible
- Rotate service principal credentials regularly
- Implement conditional access policies
- Enable Azure AD Privileged Identity Management (PIM)

## Compliance

This reference implementation includes:

- Azure Policy assignments for common compliance frameworks
- Baseline security configurations
- Logging and monitoring setup

However, you are responsible for:

- Customizing policies for your compliance requirements
- Regularly updating to latest security patches
- Maintaining security documentation
- Conducting security assessments

## Updates and Patches

We monitor for:

- Azure Verified Module updates
- Terraform provider security patches
- Azure platform security advisories
- Industry security best practices

Security updates will be released as soon as possible and announced in the repository releases.

## Resources

- [Azure Security Best Practices](https://docs.microsoft.com/azure/security/fundamentals/best-practices-and-patterns)
- [Azure Landing Zone Security](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/security)
- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)

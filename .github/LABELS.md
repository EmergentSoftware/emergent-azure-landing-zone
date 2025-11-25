# Repository Labels

This file documents the labels used in this repository. You can create them using the GitHub CLI:

```bash
# Infrastructure labels
gh label create "bootstrap" --color "0366d6" --description "00-bootstrap infrastructure"
gh label create "foundation" --color "0366d6" --description "01-foundation (ALZ)"
gh label create "landing-zone" --color "0366d6" --description "02-landing-zones"
gh label create "landing-zone:corp" --color "1d76db" --description "Corporate landing zone"
gh label create "landing-zone:online" --color "1d76db" --description "Online landing zone"
gh label create "workload" --color "0366d6" --description "03-workloads"
gh label create "modules" --color "5319e7" --description "Shared Terraform modules"

# Type labels
gh label create "enhancement" --color "a2eeef" --description "New feature or request"
gh label create "bug" --color "d73a4a" --description "Something isn't working"
gh label create "documentation" --color "0075ca" --description "Improvements or additions to documentation"
gh label create "dependencies" --color "0366d6" --description "Dependency updates"
gh label create "security" --color "d93f0b" --description "Security-related issues"

# Priority labels
gh label create "priority:critical" --color "b60205" --description "Critical priority"
gh label create "priority:high" --color "d93f0b" --description "High priority"
gh label create "priority:medium" --color "fbca04" --description "Medium priority"
gh label create "priority:low" --color "0e8a16" --description "Low priority"

# Status labels
gh label create "status:blocked" --color "d93f0b" --description "Blocked by another issue"
gh label create "status:in-progress" --color "fbca04" --description "Currently being worked on"
gh label create "status:needs-review" --color "0e8a16" --description "Awaiting code review"
gh label create "status:needs-info" --color "d876e3" --description "More information needed"

# Special labels
gh label create "good first issue" --color "7057ff" --description "Good for newcomers"
gh label create "help wanted" --color "008672" --description "Extra attention is needed"
gh label create "breaking-change" --color "b60205" --description "Contains breaking changes"
gh label create "terraform" --color "623ce4" --description "Terraform configuration"
gh label create "github" --color "000000" --description "GitHub configuration"
```

## Label Usage Guide

### Infrastructure Labels
- `bootstrap` - Changes to bootstrap infrastructure (00-bootstrap)
- `foundation` - Changes to ALZ foundation (01-foundation)
- `landing-zone` - General landing zone changes
- `landing-zone:corp` - Corporate landing zone specific
- `landing-zone:online` - Online landing zone specific
- `workload` - Workload templates (03-workloads)
- `modules` - Shared Terraform modules

### Type Labels
- `enhancement` - New features
- `bug` - Bug fixes
- `documentation` - Documentation updates
- `dependencies` - Dependency updates (automated by Dependabot)
- `security` - Security-related changes

### Priority Labels
Use these to indicate urgency:
- `priority:critical` - Must be fixed immediately
- `priority:high` - Should be addressed soon
- `priority:medium` - Normal priority
- `priority:low` - Nice to have

### Status Labels
- `status:blocked` - Cannot proceed without another issue
- `status:in-progress` - Currently being worked on
- `status:needs-review` - Ready for code review
- `status:needs-info` - Waiting for more information

### Special Labels
- `good first issue` - Easy issues for new contributors
- `help wanted` - Issues where help is appreciated
- `breaking-change` - Changes that break backward compatibility

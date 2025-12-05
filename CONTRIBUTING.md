# Contributing to Amplifier Setup

Thank you for your interest in contributing to Amplifier Setup! This document provides guidelines for contributing to the project.

## Core Principles

### Documentation First

**Documentation is not optional—it's a first-class requirement.**

When you add a feature or modify existing functionality:

1. **Update user-facing documentation immediately**
   - Users should never discover features by accident
   - Documentation should be updated in the same PR as the code
   - If it's not documented, it doesn't exist for users

2. **Keep CHANGELOG.md current**
   - Every feature addition, bug fix, or breaking change goes in CHANGELOG.md
   - Use [Keep a Changelog](https://keepachangelog.com/) format
   - This is how existing users discover what's new or what changed
   - Update it before you create the PR, not after

3. **Think from the user's perspective**
   - How will users discover this feature?
   - What do they need to know to use it?
   - What common questions might they have?
   - What examples would help them understand?

### Documentation Standards

#### What to Update

**For new features:**
- [ ] CHANGELOG.md - Add entry under "Added" section
- [ ] README.md - Update if it affects installation, setup, or core features
- [ ] Relevant docs/ files - Add detailed documentation
- [ ] Plugin READMEs - Update if plugin functionality changed
- [ ] Examples - Add examples showing how to use the feature

**For bug fixes:**
- [ ] CHANGELOG.md - Add entry under "Fixed" section
- [ ] Docs - Update if the bug was due to incorrect documentation

**For breaking changes:**
- [ ] CHANGELOG.md - Add entry under "Breaking Changes" section with migration guide
- [ ] README.md - Update affected sections
- [ ] Docs - Add migration guide showing how to upgrade

**For modifications:**
- [ ] CHANGELOG.md - Add entry under "Changed" section
- [ ] Docs - Update affected documentation
- [ ] Examples - Update examples if behavior changed

## Pull Request Process

### Before Creating a PR

1. **Update all relevant documentation**
   - Review the "What to Update" checklist above
   - Ensure CHANGELOG.md has an entry for your changes
   - Update any affected docs/ files

2. **Test your changes**
   - Verify the feature works as documented
   - Test on the target platforms (Mac, Linux, Windows if applicable)
   - Confirm documentation is accurate and clear

3. **Review your own PR**
   - Read through your changes as if you were a reviewer
   - Check that documentation matches implementation
   - Verify CHANGELOG.md entry is clear and helpful

### Using `/submit-pr`

The `/submit-pr` command includes automatic documentation compliance checking:

```bash
/submit-pr
```

This command will:
- ✅ Automatically discover repository standards (this file!)
- ✅ Check if documentation needs updating based on your changes
- ✅ Verify CHANGELOG.md has been updated
- ✅ Run any required checks (linting, testing)
- ✅ Create the PR automatically

If compliance fails, it will tell you exactly what needs to be fixed before you can create the PR.

### PR Title Format

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only changes
- `refactor:` - Code change that neither fixes a bug nor adds a feature
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**
- `feat(git): add automatic documentation compliance to submit-pr command`
- `fix: resolve Windows path handling in amp-workspace.sh`
- `docs: add Windows installation instructions to README`

### PR Description

Include these sections in your PR description:

```markdown
## Summary
Brief description of what this PR does

## Changes
- Bullet list of specific changes made
- Be specific and clear

## Testing
- [ ] Tested on [platform]
- [ ] Documentation reviewed for accuracy
- [ ] CHANGELOG.md updated
- [ ] Examples work as documented

## Related
- Link to related issues or PRs
```

## CHANGELOG.md Format

We follow [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
## [Unreleased]

### Added
- New features for users go here

### Changed
- Changes in existing functionality go here

### Fixed
- Bug fixes go here

### Breaking Changes
- Breaking changes with migration instructions go here
```

**Guidelines:**
- Write for users, not developers
- Explain what changed from the user's perspective
- Include migration instructions for breaking changes
- Link to detailed documentation when helpful

**Good CHANGELOG entries:**
```markdown
### Added
- Automatic documentation compliance checking in `/submit-pr` command -
  ensures all docs are updated before PR creation
- Windows support with one-liner installation via PowerShell
```

**Bad CHANGELOG entries:**
```markdown
### Added
- Added new function
- Updated code
```

## Documentation Style Guide

### Be Clear and Concise

- Use simple, direct language
- Avoid jargon unless necessary (and explain it if you use it)
- Short sentences are better than long ones
- Use active voice ("Run this command" not "This command should be run")

### Include Examples

- Show, don't just tell
- Provide complete, working examples
- Include expected output
- Show common use cases

### Structure for Scanability

- Use headings to organize content
- Use bullet points for lists
- Use code blocks for commands and code
- Use tables for comparisons

### Keep It Updated

- Remove outdated information immediately
- Update examples when behavior changes
- Mark deprecated features clearly
- Provide migration paths for breaking changes

## Development Setup

See [README.md](README.md) for installation and setup instructions.

## File Organization

```
amplifier-setup/
├── CHANGELOG.md          # User-facing changelog (MUST be updated)
├── CONTRIBUTING.md       # This file
├── README.md             # Main documentation
├── docs/                 # Detailed documentation
│   ├── plugins.md        # Plugin documentation
│   └── ...
├── plugins/              # Plugin implementations
│   └── */README.md       # Plugin-specific docs (update when plugin changes)
└── ai_context/           # AI context and guidance
```

## Questions or Problems?

- Create an issue for bugs or feature requests
- Include clear reproduction steps for bugs
- For feature requests, explain the use case and user benefit

## Code of Conduct

- Be respectful and constructive
- Focus on what's best for users
- Document everything for the next person
- Leave the codebase better than you found it

---

**Remember: If it's not documented, it doesn't exist for users. Documentation is not a nice-to-have—it's a requirement.**

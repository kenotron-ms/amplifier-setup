---
description: "Phase 7: Update all relevant documentation"
category: development
allowed-tools: TodoWrite, Task, Read, Grep, Glob, Write, Edit
---

# New Feature - Phase 7: Documentation

Update all relevant docs, create examples, update CHANGELOG.

## Template (MUST FOLLOW)

**This template MUST be followed when creating `07-docs-checklist.md`.**

```markdown
# Documentation Updates: [Feature]

**Created**: YYYY-MM-DD

## Updated Files

- [ ] `README.md` - Added feature overview
- [ ] `docs/api.md` - Documented new endpoints/functions
- [ ] `docs/user-guide.md` - Added usage examples
- [ ] `CHANGELOG.md` - Added entry for this version

## New Documentation (Permanent)

Place in repository's documentation structure (from Phase 0 discovery):

- [ ] `[docs-location]/features/[feature-name].md` - Complete feature guide
- [ ] `[docs-location]/examples/[feature-name]/basic.ext` - Basic usage example
- [ ] `[docs-location]/examples/[feature-name]/advanced.ext` - Advanced usage

## Examples Added

- **Basic usage**: [what it demonstrates]
- **Advanced usage**: [what it demonstrates]
- **Integration**: [how to integrate]

## Documentation Quality

- [ ] All code examples tested and working
- [ ] API reference complete
- [ ] Migration guide created (if breaking changes)
- [ ] Follows repository documentation style
```

---

## Prerequisites

- Phase 6 (Verification) must be complete
- Feature must be working and tested
- Required files:
  - `ai_working/<feature>-<date>/06-manual-test-plan.md`
  - `ai_working/<feature>-<date>/00-discovery.md` (for doc structure)
  - `progress.md`

## Objectives

- Update all relevant documentation
- Create permanent feature documentation
- Add usage examples
- Update CHANGELOG

---

## Process

Update TodoWrite:

```markdown
- [ ] Documentation needs identified
- [ ] README updated
- [ ] API docs updated
- [ ] User guide updated
- [ ] Examples created
- [ ] CHANGELOG updated
- [ ] Permanent docs created per repo structure
```

### Step 1: Identify Documentation Needs (REQUIRED AGENT)

**REQUIRED**: Must use **content-researcher** agent.

```
Task content-researcher: "Identify all documentation that needs updating for
[feature]. Search for READMEs, API docs, user guides. Determine what needs
to be added or updated."
```

**Wait for agent to complete.** Review list of docs to update.

### Step 2: Update Existing Documentation

For each doc file identified, read and update with feature information.

If needed, use **insight-synthesizer** agent:

```
Task insight-synthesizer: "Create comprehensive documentation for [feature]
including overview, usage examples, API reference. Follow existing docs style."
```

**Wait for agent to complete** if used.

### Step 3: Create Permanent Feature Documentation (FOLLOW TEMPLATE ABOVE)

**REQUIRED**: Create permanent documentation per repository structure (from Phase 0 discovery).

1. **Copy template structure** from TEMPLATE section above
2. **Create** `ai_working/<feature>-<date>/07-docs-checklist.md`
3. **Create permanent docs** in repository's documentation location (from 00-discovery.md)
4. **Check off items** in 07-docs-checklist.md as completed

### Step 4: Update CHANGELOG

Add entry for this feature following repository's CHANGELOG format.

### Step 5: Create Documentation Checklist

Track in `ai_working/<feature>-<date>/07-docs-checklist.md` (following template).

### Step 6: Update Progress

Update `progress.md`:
- Mark Phase 7 complete: `[✓]`
- Update completion: `95%`

---

## Output Files

- Updated permanent documentation (README, API docs, user guides, CHANGELOG)
- `ai_working/<feature>-<date>/07-docs-checklist.md`
- `progress.md` (updated)

## Next Phase

```bash
/new-feature:8-deploy-prep
```

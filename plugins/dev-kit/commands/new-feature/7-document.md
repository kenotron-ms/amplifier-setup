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
  - `ai_working/<feature>-<date>/00-discovery.md` (for doc structure)
  - `ai_working/<feature>-<date>/01-requirements.md` (source for requirements doc)
  - `ai_working/<feature>-<date>/02-design.md` (source for design doc)
  - `ai_working/<feature>-<date>/03-test-plan.md` (source for test plan doc)
  - `ai_working/<feature>-<date>/06-manual-test-plan.md`
  - `progress.md`

## Objectives

- Ensure 3 key permanent documents exist (requirements, design, test plan)
- Update existing docs or create new following repository structure
- Update README, API docs, user guides
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

### Step 3: Ensure 3 Key Permanent Documents (REQUIRED)

**REQUIRED**: Ensure these 3 key documents exist in target repository.

Reference `00-discovery.md` for repository's documentation structure.

#### 3a. Functional Requirements Document

**Check if exists in target repository:**
```bash
find [docs location from 00-discovery.md] -name "*requirements*" -o -name "*[feature-name]*requirements*"
```

**If exists:**
- Read existing document
- Update with missing details from `ai_working/<feature>/01-requirements.md`:
  - User stories not documented
  - Acceptance criteria not listed
  - Assumptions or constraints not mentioned
- Preserve existing structure and style

**If NOT exists:**
- Determine location from 00-discovery.md
- Create following repository's documentation pattern
- Synthesize from `ai_working/<feature>/01-requirements.md`

#### 3b. Dev Design / Architecture Document

**Check if exists:**
```bash
find [docs location] -name "*design*" -o -name "*architecture*" -o -name "*ADR*"
```

**If exists:**
- Read existing document
- Update with missing details from `ai_working/<feature>/02-design.md`:
  - Architecture diagrams not present
  - Module design details missing
  - Integration points not documented

**If NOT exists:**
- Check if repository uses ADRs (from 00-discovery.md)
- Create in appropriate location
- Synthesize from `ai_working/<feature>/02-design.md`
- Include: Architecture overview, modules, key decisions

#### 3c. Test Plan Details

**REQUIRED**: Ensure test plan details are documented (adapt to repository structure).

**Check repository's documentation pattern from 00-discovery.md:**

**Pattern A: Combined document (design + test plan)**
```bash
# If repository uses single doc per feature
# Example: docs/features/[feature-name].md contains architecture, tests
```
- Read existing combined document
- Add "## Test Strategy" section if missing
- Update with details from `ai_working/<feature>/03-test-plan.md`
- Preserve document structure

**Pattern B: Separate test plan document**
```bash
# If repository has dedicated test plan docs
find [docs location] -name "*test*plan*" -o -name "*qa*"
```
- If exists: Read and update with missing test details
- If NOT exists: Create separate test plan doc
- Synthesize from `ai_working/<feature>/03-test-plan.md`

**Pattern C: Test details in epic/story**
```bash
# If repository uses epic/story format with acceptance criteria
find [docs location] -name "*epic*" -o -name "*story*"
```
- Read epic/story document
- Update test/acceptance section
- Add test cases from `ai_working/<feature>/03-test-plan.md`

**Adapt to repository's pattern** - don't impose rigid structure.

**Include from 03-test-plan.md (test cases only):**
- Test strategy (60/30/10 split)
- Test categories (new feature vs regression)
- List of test cases (unit, integration, e2e)
- Coverage targets

**Do NOT include:**
- Acceptance criteria (those are in requirements doc)
- Traceability mapping (criteria → tests)

Just document the tests themselves.

### Step 4: Update CHANGELOG

Add entry for this feature following repository's CHANGELOG format.

### Step 5: Create Documentation Checklist

Track all updates in `ai_working/<feature>-<date>/07-docs-checklist.md` (following TEMPLATE above).

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

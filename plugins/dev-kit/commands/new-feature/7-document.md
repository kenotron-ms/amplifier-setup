---
description: "Phase 7: Update all relevant documentation"
category: development
allowed-tools: TodoWrite, Task, Read, Grep, Glob, Write, Edit
---

# New Feature - Phase 7: Documentation

Create or update all relevant docs, create examples, update CHANGELOG.

## Template (MUST FOLLOW)

**This template MUST be followed when creating `07-docs-checklist.md`.**

```markdown
# Documentation Updates: [Feature]

**Created**: YYYY-MM-DD

## Updated Files

- [ ] `README.md` - Added feature overview
- [ ] `docs/api.md` - Documented new endpoints/functions
- [ ] `docs/user-guide.md` - Added usage examples
- [ ] `CHANGELOG.md` (or corresponding status reporting file) - Added entry for this version

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

- Document feature content (requirements, design, test plan) following target repository's structure
- Adapt to repository's documentation patterns (combined vs separate docs)
- Update README, API docs, user guides
- Add usage examples
- Update CHANGELOG (or corresponding status file in target repository)

---

## Process

### Step 1: Determine Documentation File Paths

**Read discovery to find where docs go and infer naming pattern.**

1. **Read `00-discovery.md` → "Documentation Structure"** to get locations:
   - Requirements location: `[path]`
   - Dev Design / Technical Design location: `[path]`
   - Test location: `[path]` (or combined with dev design)

2. **Observe existing files** to infer naming pattern:
   ```bash
   # List existing files in dev design doc location
   ls [dev-design-location]/*.md

   # Observe pattern (e.g., user-auth.md, canvas-updates.md → lowercase-with-dashes)
   ```

3. **Build file paths** using observed pattern:
   - Feature name: Slugify from description (e.g., "Persist Dock Panel State" → "dock-panel-persistence")
   - Apply observed naming pattern
   - Full paths:
     - Requirements: `[location]/[feature-name].md`
     - Dev Design: `[location]/[feature-name].md`
     - Test: `[location]/[feature-name].md` OR section in dev design doc

4. **Read README files in documentation locations:**
   ```bash
   # Check for README in each documentation location
   ls [requirements-location]/README.md
   ls [dev-design-location]/README.md
   ls [test-location]/README.md
   ```

   **For EACH README found, read it** to understand:
   - Naming conventions
   - Required sections or format
   - Templates to follow
   - Any specific rules or instructions for that directory and the files within

   **Use this guidance when creating/updating files in those locations.**

### Step 2: Document Dev Design Content FIRST (CANNOT SKIP)

**CRITICAL**: Create technical design doc FIRST so there's a clear place for technical content.

**2.1. Get dev design doc path** (from Step 1)

**2.2. Read README in dev design location** (if exists from Step 1.4)

**2.3. Check if dev design file exists:**
```bash
ls [dev-design-path]
```

**2.4. If exists**:
- Read existing file
- Compare with `02-design.md`
- Update with missing: Quick Reference, Alternatives, Assumptions, Diagrams, Deployment

**2.5. If doesn't exist**:
- **CREATE new file** at [dev-design-path]
- Use FULL content from `02-design.md`:
  - Quick Reference
  - Alternatives Considered
  - Design Assumptions
  - Architecture Overview (diagrams)
  - Module Design
  - Deployment Considerations
  - All sections

**2.6. Verify created/updated:**
```bash
ls [dev-design-path] && wc -l [dev-design-path]
```

**2.7. Verify has full details** (not just summary):
- Open file and check: Quick Reference? Alternatives? Assumptions? Diagrams?

**Mark complete: Dev design documented at [exact path] with full details**

---

### Step 3: Document Requirements Content

**NOW that dev design doc exists, update requirements/user stories.**

**3.1. Get requirements doc path** (from Step 1)

**3.2. Check if file exists:**
```bash
ls [requirements-path]
```

**3.3. If exists**: Read file, compare with `01-requirements.md`, update with any missing content

**3.4. If doesn't exist**: Create new file with content from `01-requirements.md`

**3.5. Verify created/updated:**
```bash
ls [requirements-path] && echo "✓ Requirements documented"
```

**CRITICAL**: User stories should have ONLY end-user details. Technical content goes in dev design doc (Step 2).

**Mark complete: Requirements content documented at [exact path]**

### Step 4: Ensure Test Strategy Content Documented

**Check if test doc exists (separate file or section in design doc).**

**If exists**: Update with test list from `03-test-plan.md` (strategy + tests, NO results)

**If doesn't exist**: Create or add section with content from `03-test-plan.md`

**Mark complete when done.**

### Step 5: Identify and Update Additional Documentation (REQUIRED AGENT)

**REQUIRED**: Must use **content-researcher** agent.

```
Task content-researcher: "Identify all documentation that needs updating for
[feature]. Search for READMEs, API docs, user guides, epics, stories, design docs.

For EACH document found, specify:
- Document name and location
- What specifically needs to be added or updated
- No priority categorization (HIGH/MEDIUM/LOW) - just list what needs updating

Output format:
- [Document path]: [Specific change needed]
- [Document path]: [Specific change needed]

Do NOT categorize by priority. All documentation in this phase should be completed."
```

**Wait for agent to complete.** Review list of docs to update.

**After content-researcher completes:**

**ADD** specific files to TodoWrite (expand the list), but **KEEP** the core tasks:
```markdown
- [ ] Documentation needs identified ✓
- [ ] Requirements content documented in target repo ← KEEP THIS
- [ ] Design/architecture content documented in target repo ← KEEP THIS
- [ ] Test plan content documented in target repo ← KEEP THIS
- [ ] README updated
  - [ ] User Story 07-12 ← ADD specifics
  - [ ] Epic 02 Canvas ← ADD specifics
  - [ ] STATUS.md ← ADD specifics
- [ ] CHANGELOG updated
```

**The 3 core content tasks are MANDATORY - do not remove them.**

### Step 2: Update Existing Documentation

For each doc file identified, read and update with feature information.

If needed, use **insight-synthesizer** agent:

```
Task insight-synthesizer: "Create comprehensive documentation for [feature]
including overview, usage examples, API reference. Follow existing docs style."
```

**Wait for agent to complete** if used.

### Step 3: Document Feature Content (ADAPT TO REPOSITORY STRUCTURE)

**REQUIRED**: Ensure ALL 3 types of content are documented in target repository.

**CRITICAL**: Adapt to repository structure - don't impose rigid format.

**First, read `00-discovery.md` to understand:**
- Where feature documentation lives
- Documentation format (combined vs separate)
- Naming conventions
- Examples of existing feature docs

**Then, ensure EACH content type is documented:**

**CRITICAL - "Adapt to repository pattern" means:**
- ✅ Adapt the FORMAT (combined vs separate, naming convention, structure)
- ✅ Adapt the LOCATION (follow repository's doc organization)
- ❌ NOT skip content if location seems unclear
- ❌ NOT skip content if pattern differs from examples
- ✅ **CONTENT MUST BE DOCUMENTED regardless of pattern**

**MUST DOCUMENT (always, no exceptions):**
1. ✅ Requirements content (from `01-requirements.md`)
2. ✅ Dev Design / Technical Design content (from `02-design.md`)
3. ✅ Test plan content (from `03-test-plan.md`)

**Each gets its own detailed step below.**

**CONTENT DEPTH - Use FULL details (not just summary):**

**Dev Design / Technical Design content should include:**
- ✅ Quick Reference (for quick lookup)
- ✅ Alternatives considered (preserves decision context - "why not X?")
- ✅ Design assumptions with reasoning (critical for future changes!)
- ✅ Trade-offs accepted (understanding compromises made)
- ✅ Full architecture diagrams
- ✅ All sections from 02-design.md
- ❌ Exclude: Agent-specific implementation prompts (if any)

**Why full details matter:**
- Future developers understand "why" not just "what"
- Assumptions documented prevent bugs when context changes
- Alternatives preserved prevent re-discussing rejected approaches
- Decision history enables informed evolution

**CRITICAL - Keep User Stories vs Technical Docs Separate:**

**User Stories / Epics (end-user focused):**
- ✅ User needs and behavior
- ✅ Acceptance criteria (what user sees/does)
- ✅ User value and benefits
- ❌ NO technical implementation details
- ❌ NO architecture decisions
- ❌ NO code-level specifics
- ❌ NO "Implementation Notes" sections

**Dev-Design Docs (technical focused):**
- ✅ Architecture and technical decisions
- ✅ Module design and implementation approach
- ✅ Alternatives considered and assumptions
- ✅ Deployment considerations

**If you add technical details to user stories, you're doing it wrong.**

**ADAPT TO REPOSITORY PATTERNS:**

**Pattern A: Single combined document per feature**
```bash
# Example: docs/features/[feature-name].md
# Contains: requirements, design, tests, deployment all in one doc
```

Find or create feature document, include ALL sections:
- ## References (link to requirements doc if separate)
- ## Requirements (from 01-requirements.md)
- ## Design & Architecture (from 02-design.md)
- ## Test Strategy (from 03-test-plan.md)
  - Test strategy (60/30/10 split)
  - List of tests created (unit, integration, e2e)
  - NO test results (pass/fail)
  - NO manual test results
- ## Deployment (from 02-design.md Deployment section)

**Pattern B: Separate documents**
```bash
# Example: docs/requirements/[feature].md, docs/design/[feature].md, etc.
```

Create/update separate docs:
- Requirements doc (from 01-requirements.md)
- Design doc (from 02-design.md):
  - Include References section linking to requirements doc
  - Include deployment section
  - If including test strategy: List of tests only, NO results
- Test plan doc (from 03-test-plan.md):
  - Test strategy and list of tests
  - NO test results (pass/fail)
  - NO manual test results

**Pattern C: Epic/Story format**
```bash
# Example: docs/epics/02-canvas.md with user stories
```

Find epic/story, update sections:
- User stories section (from 01-requirements.md)
- Design notes section (from 02-design.md)
  - Link to requirements if not in same doc
  - Include deployment notes
- Test strategy section (from 03-test-plan.md)
  - Test strategy and list of tests
  - NO test results (pass/fail)
  - NO manual test results
- Deployment notes (from 02-design.md)

**Pattern D: In-code documentation**
```bash
# Example: src/features/[feature]/README.md alongside code
```

Create README in feature directory with all content:
- Link to requirements (if not in same file)
- Design/architecture from 02-design.md
- Test list from 03-test-plan.md (NO results)
- Deployment from 02-design.md

**FOLLOW THE PATTERN, don't enforce structure.**

**CRITICAL - What NOT to Include:**
- ❌ Test results (pass/fail counts)
- ❌ Manual test results from Phase 6
- ❌ Test execution history
- ✅ Only: Test strategy and list of tests created

### Step 4: Update CHANGELOG

Add entry for this feature following repository's CHANGELOG format. CHANGELOG may have a different filename in the target repo.

### Step 5: Create Documentation Checklist

Track all updates in `ai_working/<feature>-<date>/07-docs-checklist.md` (following TEMPLATE above).

### Step 6: Verify Documentation Complete And Correct (AUTOMATED CHECKS)

**REQUIRED**: Run automated checks before marking phase complete.

**Check 1: Required files exist**
```bash
ls [requirements-path] || echo "❌ Requirements file missing"
ls [dev-design-path] || echo "❌ Dev design file missing"
ls [test-path] || grep -q "Test Strategy" [dev-design-path] || echo "❌ Test content missing"
```

**Check 2: Technical pollution in user stories (AUTOMATED)**
```bash
# Search for technical keywords in user story files
grep -i "implementation\|architecture\|module\|technical\|code\|class\|function" [user-story-files]

# If ANY found:
if [ $? -eq 0 ]; then
    echo "❌ FAILED: Technical content found in user stories"
    echo "Technical keywords found. This violates end-user focus."
    echo "Action: REMOVE technical content and MOVE to dev design doc"
    exit 1
fi
```

**Check 3: Dev design has full details**
```bash
# Verify key sections present
grep -q "Quick Reference" [dev-design-path] || echo "⚠️  Missing Quick Reference"
grep -q "Alternatives" [dev-design-path] || echo "⚠️  Missing Alternatives"
grep -q "Assumptions" [dev-design-path] || echo "⚠️  Missing Assumptions"
```

**If ANY check fails:**

❌ **STOP - Phase NOT complete:**
```
Verification FAILED!

Issues:
- [What failed]

Fix required:
1. Missing files → Create them (go back to Steps 2-4)
2. Technical content in user stories → MOVE to dev design doc
3. Missing sections in dev design → Add them

After fixing, re-run Step 6 verification.
```

**Only mark phase complete after ALL automated checks pass.**

### Step 7: Update Progress

Update `progress.md`:
- Mark Phase 7 complete: `[✓]`
- Update completion: `95%` (Phase 8 archiving will complete to 100%)

### Step 8: Suggest Commit (Recommended)

**All documentation complete.** Changes ready to commit.

Present to user:

```
✓ Phase 7 Complete - Documentation Updated

Changes ready to commit:
- Implementation code (if not committed yet)
- Tests (if not committed yet)
- Documentation (requirements, design, test plan)
- README, CHANGELOG, and other docs

Recommended: Commit all changes or submit pull request

/git:commit
/git:submit-pr

This may include:
- Just documentation (if you committed code earlier)
- Entire feature (code + tests + docs together)

Or continue to cleanup:
/new-feature:8-cleanup

Note: Phase 8 (Cleanup) will ask you to commit before proceeding.
```

**Committing is optional here** - user can batch commits or commit now for safety before cleanup.

---

## Output Files

- Updated permanent documentation (README, API docs, user guides, CHANGELOG)
- `ai_working/<feature>-<date>/07-docs-checklist.md`
- `progress.md` (updated)

## Next Phase

```bash
/new-feature:8-cleanup
```

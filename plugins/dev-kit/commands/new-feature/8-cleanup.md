---
description: "Phase 8: Archive working documents"
category: development
allowed-tools: TodoWrite, Read, Bash
---

# New Feature - Phase 8: Cleanup

Archive temporary working files to preserve feature development history.

## Prerequisites

- Phase 7 (Documentation) should be complete
- **RECOMMENDED**: User should commit all changes first
- Required files:
  - `ai_working/<feature>-<date>/`
  - `progress.md`

## Objectives

- Archive temporary working files for future reference
- Clean up ai_working directory

---

## Process

Update TodoWrite:

```markdown
- [ ] User confirmed changes committed (recommended)
- [ ] Working directory archived
- [ ] Progress updated
```

### Step 1: Confirm Commit (Recommended)

**Recommended**: Commit before archiving to preserve clean state.

Present to user:

```
Feature development complete! Ready to archive working documents.

Recommended: Commit all changes before archiving.

Have you committed?
1. Yes, committed - proceed with archiving
2. Let me commit now (use /git:commit)
3. Skip commit, just archive
4. Skip archiving entirely
```

If option 2, suggest `/git:commit`, then return here.

### Step 2: Archive Working Directory

**Archive the working directory to preserve development history:**

```bash
# Create archive directory if doesn't exist
mkdir -p ai_archive

# Archive the working directory
WORK_DIR="ai_working/<feature>-<date>"
ARCHIVE_DIR="ai_archive/<feature>-<date>"

# Move to archive (preserves all files)
mv "$WORK_DIR" "$ARCHIVE_DIR"

echo "✓ Archived: $ARCHIVE_DIR"
```

**What's preserved:**
- 00-discovery.md (project context and patterns)
- 01-requirements.md (decisions and assumptions)
- 02-design.md (alternatives considered, design assumptions)
- 03-test-plan.md (test strategy)
- 04-implementation.md (implementation notes)
- 05-review.md (code review findings)
- 06-manual-test-plan.md (user testing)
- 07-docs-checklist.md (documentation tracking)
- progress.md (complete session history)

**Benefits of archiving:**
- Future reference for why decisions were made
- Onboarding new developers
- Understanding feature evolution
- Debugging context

### Step 3: Update Progress (in Archive)

Update `ai_archive/<feature>-<date>/progress.md`:
- Mark Phase 8 complete: `[✓]`
- Update completion: `100%`
- Add final session note:
  ```
  ### Session X (YYYY-MM-DD) - Feature Complete
  - Archived working documents to ai_archive/
  - Feature fully implemented, tested, and documented
  - **Final Status**: 100% Complete
  ```

---

## Output Files

- Archived working directory: `ai_archive/<feature>-<date>/`
- Contains all development history and decisions

## Feature Complete!

```
🎉 Feature development complete!

Working documents archived to: ai_archive/<feature>-<date>/

Next steps (if not done):
- Final commit: /git:commit
- Create PR: /git:submit-pr

Feature is fully implemented, tested, and documented.
```

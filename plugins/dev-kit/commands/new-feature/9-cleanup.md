---
description: "Phase 9: Remove unused code safely (Optional)"
category: development
allowed-tools: TodoWrite, Read, Grep, Glob, Edit, Bash
---

# New Feature - Phase 9: Cleanup (Optional)

Safely remove unused code, archive temporary files, verify no breakage.

## ⚠️ WARNING: Destructive Operation

User must commit all changes before running cleanup.

## Prerequisites

- Phase 8 (Deployment Prep) should be complete
- **CRITICAL**: User must have committed all changes
- Required files:
  - `ai_working/<feature>-<date>/08-deployment.md`
  - `progress.md`

## Objectives

- Remove unused code safely
- Archive temporary working files
- Verify no breakage from cleanup

---

## Process

Update TodoWrite:

```markdown
- [ ] User confirmed changes committed
- [ ] Scanned for cleanup candidates
- [ ] User selected items to clean
- [ ] Cleanup executed
- [ ] Tests verified post-cleanup
```

### Step 1: Safety Check

Ask user:

```
⚠️  CLEANUP IS DESTRUCTIVE

Have you committed all your changes?
1. Yes, proceed with cleanup
2. No, let me commit first (use /git:commit)
3. Skip cleanup entirely
```

If not committed, STOP and suggest `/git:commit`.

### Step 2: Scan for Cleanup Candidates (REQUIRED)

**REQUIRED**: Scan for unused code using project's linter.

```bash
# Find unused imports, commented code, unused functions
[linter command from discovery]
```

Create `ai_working/<feature>-<date>/09-cleanup-candidates.md` documenting:
- Unused imports (with file:line)
- Commented code blocks (with file:lines)
- Unused functions/variables (with file:line)
- Temporary directory size

### Step 3: User Selection

Present findings and ask what to clean:
1. All unused imports
2. All commented code blocks
3. All unused functions
4. Temporary working directory (archive or delete)
5. Custom selection
6. Nothing (skip cleanup)

### Step 4: Execute Cleanup (CAREFUL)

For each selected item:
1. Remove unused code
2. Archive/delete temp directory
3. **Document what was removed**

### Step 5: VERIFY No Breakage (REQUIRED)

**REQUIRED**: Run tests to confirm cleanup didn't break anything.

```bash
[test command with verbose]
```

**Must see:** All tests PASSING

- [ ] All unit tests PASSING
- [ ] All integration tests PASSING
- [ ] All e2e tests PASSING

**If any tests fail:**
- ❌ Cleanup broke something
- ❌ Revert cleanup: `git checkout .`
- ❌ Review what was removed
- ❌ Fix or skip that cleanup item

### Step 6: Update Progress

Update `progress.md`:
- Mark Phase 9 complete: `[✓]`
- Update completion: `100%`
- Add cleanup summary to session history

---

## Output Files

- Cleaned up code
- `ai_working/<feature>-<date>/09-cleanup-candidates.md`
- Archived: `ai_archive/<feature>-<date>/` (if archived)
- `progress.md` (updated)

## Feature Complete

```bash
# Commit cleanup
/git:commit "chore: cleanup after feature completion"

# Create PR
/git:submit-pr
```

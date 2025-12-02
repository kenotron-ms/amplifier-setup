# Git Pull & Sync with Main

Sync your feature branch with the latest changes from origin/main, with intelligent conflict resolution assistance.

## Important: Project Directory

**All git commands must run in the actual project directory, not the Claude worktree.**

The commands will use `PROJECT_DIR` environment variable if set, otherwise fall back to the current directory (`$PWD`).

**At the start of this command, set PROJECT_DIR:**
```bash
# Use PROJECT_DIR if set, otherwise use current directory
PROJECT_DIR="${PROJECT_DIR:-$PWD}"
echo "Working in: $PROJECT_DIR"
```

**Then for all git commands, use:**
```bash
cd "$PROJECT_DIR"
git <command>
```

## Workflow

Follow these steps in order:

### Step 1: Assess Current State

Run these commands to understand the situation:
```bash
cd "$PROJECT_DIR"
git status
git branch --show-current
git stash list
```

**Pre-flight checks:**
- If there are uncommitted changes, stash them first:
  ```bash
  git stash push -m "Auto-stash before git-pull sync"
  ```
- Note the current branch name for later

### Step 2: Fetch Latest from Remote

```bash
cd "$PROJECT_DIR"
git fetch origin main
```

Show the user what's new:
```bash
git log --oneline HEAD..origin/main | head -20
```

If nothing new, inform user they're already up to date.

### Step 3: Attempt Rebase

Prefer rebase over merge for cleaner history:
```bash
cd "$PROJECT_DIR"
git rebase origin/main
```

**If rebase succeeds:** Skip to Step 5 (Restore stash)

**If conflicts occur:** Proceed to Step 4

### Step 4: Conflict Resolution (Interactive)

When conflicts are detected:

1. **List all conflicting files:**
   ```bash
   cd "$PROJECT_DIR"
   git diff --name-only --diff-filter=U
   ```

2. **For EACH conflicting file, guide the user through resolution:**

   a. Show the conflict context:
      ```bash
      git diff <filename>
      ```

   b. Read the file to understand both sides of the conflict

   c. **Use AskUserQuestion to help the user decide** - frame it as a high-level choice:

      Present options like:
      - "Keep YOUR version (feature branch changes)"
      - "Keep THEIR version (main branch changes)"
      - "Combine both changes (I'll help merge them)"
      - "Let me see the full context first"

      **DO NOT** ask users to pick specific lines of code. Instead:
      - Explain WHAT each side is trying to do
      - Explain WHY there's a conflict (both modified same area)
      - Ask which INTENT should win, or if both should be preserved

   d. Based on user's choice:
      - If keeping one side: Use `git checkout --ours <file>` or `git checkout --theirs <file>`
      - If combining: Read the file, understand both changes, propose a merged solution, show it to user for approval

   e. After resolving, stage the file:
      ```bash
      git add <filename>
      ```

3. **After all conflicts resolved:**
   ```bash
   cd "$PROJECT_DIR"
   git rebase --continue
   ```

   If more conflicts appear, repeat Step 4.

### Step 5: Restore Stashed Changes

If changes were stashed in Step 1:
```bash
cd "$PROJECT_DIR"
git stash pop
```

If stash pop has conflicts, help resolve those too using the same approach.

### Step 6: Report Result

Show the user:
- Summary of what was synced
- Number of commits from main that were integrated
- Any files that had conflicts and how they were resolved
- Current branch status

## Conflict Resolution Philosophy

**High-level thinking over line-by-line diffs:**

When explaining conflicts to users, focus on:
- "Your branch added a new validation function, main also added validation but with different logic"
- "Both branches modified the user authentication flow"
- "Your changes refactored this module, main added new features to the old structure"

**NOT:**
- "Line 45 has <<<<<<< HEAD"
- "Choose between lines 45-52 or lines 54-61"

The goal is to help users understand the SEMANTIC conflict, not the textual one.

## Abort Options

At any point during conflict resolution, offer the user:
- "Abort and return to previous state" (`git rebase --abort`)
- "Skip this commit" (`git rebase --skip`) - use sparingly
- "Continue with current resolution"

## Error Handling

- If rebase gets into a bad state, offer `git rebase --abort` to start fresh
- If user is confused, explain what rebase does vs merge
- If there are many conflicts, suggest resolving in batches or considering a merge instead
- If PROJECT_DIR is not set, inform user and use current directory as fallback

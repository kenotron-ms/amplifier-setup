# Submit Pull Request

Submit a pull request from the current branch with proper commit hygiene.

**🎯 Smart Standards Discovery**: This command automatically discovers and follows repository-specific PR standards by reading documentation files (`claude.md`, `contributing.md`, `maintenance.md`) from the repo. It adapts PR titles and descriptions to match each repository's conventions.

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

### Step 1: Verify Git State

Run these commands to understand the current state:
```bash
cd "$PROJECT_DIR"
git status
git branch --show-current
git remote -v
```

**Check:**
- If on `main` or `master` branch, STOP and ask the user to create a feature branch first
- If there are uncommitted changes, proceed to commit them
- If already on a feature branch with no changes, proceed to push/PR

### Step 2: Handle Uncommitted Changes

If there are uncommitted changes:

1. Show the user what will be committed:
   ```bash
   cd "$PROJECT_DIR"
   git diff --stat
   git diff --staged --stat
   ```

2. Stage all changes:
   ```bash
   git add -A
   ```

3. Generate a commit message based on the changes:
   - Analyze the diff to understand what changed
   - Write a concise, descriptive commit message following conventional commits format
   - Ask the user to confirm or modify the commit message using AskUserQuestion

4. Create the commit with the agreed message

### Step 3: Push to Remote

1. Check if the branch exists on remote:
   ```bash
   cd "$PROJECT_DIR"
   git ls-remote --heads origin $(git branch --show-current)
   ```

2. Push the branch:
   ```bash
   git push -u origin $(git branch --show-current)
   ```

### Step 4: Discover Repository Documentation Standards

Before creating the PR, discover and read repository-specific PR standards:

1. **Search for documentation files** in these locations:
   - Root: `/`, `/docs`, `/ai_context`
   - Look for files (case-insensitive):
     - `claude.md` or `CLAUDE.md`
     - `contributing.md` or `CONTRIBUTING.md`
     - `maintenance.md` or `MAINTENANCE.md`
   - Use recursive search to check subdirectories

2. **Read and extract PR standards** from discovered files:
   - Look for sections about:
     - PR title format/conventions (e.g., "[Component] Description")
     - PR description requirements (required sections like "## Summary", "## Testing")
     - Commit message patterns
     - Any special formatting or content expectations
   - If multiple files found, combine standards from all
   - If no standards found, use sensible defaults

3. **Analyze recent PRs** for patterns (optional):
   ```bash
   cd "$PROJECT_DIR"
   gh pr list --state merged --limit 5 --json title,body
   ```

### Step 5: Create Pull Request

1. Check if a PR already exists for this branch:
   ```bash
   cd "$PROJECT_DIR"
   gh pr view --json number,url 2>/dev/null || echo "No existing PR"
   ```

2. If no PR exists, create one **following discovered standards**:
   - Generate a PR title that matches the discovered format conventions
   - Generate a PR description that includes:
     - Required sections from discovered standards
     - Summary of changes based on git diff analysis
     - Test plan or verification steps
     - Any other required content
   - Maintain the tone and style consistent with the repo's standards
   - Ask the user to confirm or modify using AskUserQuestion
   - Create the PR:
     ```bash
     gh pr create --title "PR_TITLE" --body "PR_BODY"
     ```

3. If PR exists, ask if user wants to update it or view it

### Step 6: Report Result

Show the user:
- PR URL
- PR number
- Next steps (e.g., request reviewers, add labels)

## Error Handling

- If `gh` CLI is not installed, inform user and provide installation instructions
- If not authenticated with GitHub, guide user through `gh auth login`
- If push fails due to conflicts, suggest running `/pull` first
- If PROJECT_DIR is not set, inform user and use current directory as fallback

## Important Notes

- Never force push without explicit user confirmation
- Always show what will be committed before committing
- Use AskUserQuestion for any destructive or significant actions

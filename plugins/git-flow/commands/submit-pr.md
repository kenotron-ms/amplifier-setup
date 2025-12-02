# Submit Pull Request

Submit a pull request from the current branch with proper commit hygiene.

## Workflow

Follow these steps in order:

### Step 1: Verify Git State

Run these commands to understand the current state:
```bash
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
   git ls-remote --heads origin $(git branch --show-current)
   ```

2. Push the branch:
   ```bash
   git push -u origin $(git branch --show-current)
   ```

### Step 4: Create Pull Request

1. Check if a PR already exists for this branch:
   ```bash
   gh pr view --json number,url 2>/dev/null || echo "No existing PR"
   ```

2. If no PR exists, create one:
   - Generate a PR title from the branch name or recent commits
   - Generate a PR description summarizing the changes
   - Ask the user to confirm or modify using AskUserQuestion
   - Create the PR:
     ```bash
     gh pr create --title "PR_TITLE" --body "PR_BODY"
     ```

3. If PR exists, ask if user wants to update it or view it

### Step 5: Report Result

Show the user:
- PR URL
- PR number
- Next steps (e.g., request reviewers, add labels)

## Error Handling

- If `gh` CLI is not installed, inform user and provide installation instructions
- If not authenticated with GitHub, guide user through `gh auth login`
- If push fails due to conflicts, suggest running `/git-pull` first

## Important Notes

- Never force push without explicit user confirmation
- Always show what will be committed before committing
- Use AskUserQuestion for any destructive or significant actions

---
description: Submit a pull request with automatic documentation compliance
---

# Submit Pull Request

Complete end-to-end PR workflow: automatically creates branches, commits changes, ensures documentation compliance, monitors CI/CD checks, and merges when approved.

**🎯 Smart Standards Discovery**: This command automatically discovers and follows repository-specific PR standards by reading documentation files (`CONTRIBUTING.md`, `MAINTENANCE.md`, `CLAUDE.md`). It ensures all documentation is updated and all required steps are completed before creating the PR.

**✨ Full Lifecycle Automation**:
- **Auto-branch**: Creates feature branch if on main/master
- **Auto-monitor**: Watches PR checks and approval status in real-time
- **Auto-merge**: Merges and cleans up branches when ready

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

### Step 1: Verify Git State and Create Branch if Needed

Run these commands to understand the current state:
```bash
cd "$PROJECT_DIR"
git status
CURRENT_BRANCH=$(git branch --show-current)
git remote -v
echo "Current branch: $CURRENT_BRANCH"
```

**Check and handle branches:**

1. **If on `main` or `master` branch, automatically create a feature branch:**
   ```bash
   cd "$PROJECT_DIR"
   CURRENT_BRANCH=$(git branch --show-current)

   if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
     # Generate a branch name based on changes
     # Analyze git diff to understand what changed
     # Create a descriptive branch name like: feature/add-user-auth, fix/login-bug, etc.

     echo "📌 Currently on $CURRENT_BRANCH - creating feature branch..."

     # Generate branch name from changes (you should analyze the diff)
     BRANCH_NAME="feature/$(date +%Y%m%d-%H%M%S)"  # Fallback if can't determine from diff

     git checkout -b "$BRANCH_NAME"
     echo "✅ Created and switched to branch: $BRANCH_NAME"
   fi
   ```

2. **If there are uncommitted changes, proceed to commit them**

3. **If already on a feature branch with no changes, proceed to compliance check**

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

3. Generate and create a commit automatically:
   - Analyze the diff to understand what changed
   - Write a concise, descriptive commit message following conventional commits format
   - Create the commit immediately (no confirmation needed)

### Step 3: Ensure Documentation Compliance (Automatic)

**This step ALWAYS runs to ensure documentation is never out of sync with code changes.**

1. **Find repository documentation standards:**
   ```bash
   cd "$PROJECT_DIR"

   # Use git ls-files to find tracked documentation
   DOCS=$(git ls-files '*.md' | grep -iE '(contributing|maintenance|claude)\.md$')

   if [[ -z "$DOCS" ]]; then
     echo "📋 No documentation standards found (CONTRIBUTING.md, MAINTENANCE.md, CLAUDE.md)"
     echo "   Proceeding without compliance check"
   else
     echo "📋 Found documentation standards:"
     echo "$DOCS"
     echo ""
     echo "🔍 Ensuring documentation compliance..."
   fi
   ```

2. **If standards found, ensure compliance using general-purpose agent:**

   Use Task tool with `subagent_type: 'general-purpose'`

   **Note**: Repositories can optionally create a specialized `docs-compliance-agent` for better performance. See documentation for details.

   **Provide this detailed prompt:**

   ```
   TASK: Ensure complete documentation compliance before PR submission

   REPOSITORY STANDARDS:
   {Read each file in DOCS and provide full contents}

   CHANGES IN THIS PR:
   Branch: {output of: git branch --show-current}
   Base branch: {main or master - check which exists}

   Diff: {output of: git diff origin/{base}...HEAD or git diff HEAD~5..HEAD if no remote}
   Commits: {output of: git log origin/{base}...HEAD --oneline or git log -5 --oneline if no remote}

   YOUR MISSION:

   1. **Read ALL documentation standards carefully**
      - Understand what documentation must be updated
      - Understand what commands must be run
      - Understand what files must be generated
      - Understand conditional requirements (e.g., "if API changed, update X")

   2. **Analyze the changes to determine which requirements apply**
      - What code changed?
      - What features were added/modified?
      - What APIs were affected?
      - What user-facing changes occurred?
      - Are there breaking changes?

   3. **Execute EVERYTHING required automatically (NO ASKING):**

      **Documentation Updates:**
      - Update CHANGELOG.md with appropriate entries
      - Update API documentation if APIs changed
      - Update README.md if features/setup changed
      - Update configuration docs if config changed
      - Update migration docs if breaking changes
      - Any other docs mentioned in standards

      **Run Required Commands:**
      - Linting: `npm run lint`, `make lint`, etc.
      - Testing: `npm run test`, `make test`, etc.
      - Formatting: `npm run format`, etc.
      - Type checking: `npm run typecheck`, `make check`, etc.
      - Doc generation: `npm run docs:generate`, etc.

      **File Generation:**
      - Regenerate any auto-generated files mentioned
      - Update version numbers if required
      - Generate types, schemas, etc.

      **Handle Conditionals Intelligently:**
      - If standards say "if API changed, update docs/api/", check if API actually changed
      - Only apply requirements that are relevant to this PR
      - Note what was skipped and why

   4. **Stage all changes:**
      ```bash
      git add -A
      ```

   5. **Report what you did in this EXACT format:**

      ```
      COMPLIANCE STATUS: [COMPLETE|FAILED]

      DOCUMENTATION UPDATES:
      - File: path/to/file.md
        Status: ✅ Updated | ⊘ Skipped | ❌ Failed
        Changes: Brief description of what was updated
        Reason: Why this was updated/skipped

      COMMANDS RUN:
      - Command: command here
        Status: ✅ Passed | ❌ Failed
        Output: [Include if relevant, especially for failures]

      FILES GENERATED:
      - File: path/to/generated/file
        Status: ✅ Generated | ❌ Failed

      SKIPPED (and why):
      - Requirement: what was skipped
        Reason: why it was skipped (e.g., "No API changes in this PR")

      FAILURES: [Only if status is FAILED]
      - What failed
        Error details
        What needs to be fixed

      STAGED CHANGES READY TO COMMIT: [Yes|No]
      ```

   CRITICAL RULES:
   - Be thorough - don't skip steps
   - Be accurate - update docs to exactly match code changes
   - Be intelligent - apply conditional requirements correctly
   - Be efficient - run commands in optimal order
   - Handle failures gracefully - report clearly and stop if critical
   - Stage everything - make sure all updates are staged
   - NO ASKING - just execute everything automatically
   ```

3. **Process agent response:**

   **If COMPLIANCE STATUS: COMPLETE:**
   ```bash
   # Check if agent made any changes
   cd "$PROJECT_DIR"
   if [[ -n $(git diff --cached) ]]; then
     echo "📝 Committing documentation compliance updates..."
     git commit -m "docs: ensure documentation compliance

- Updated all required documentation per repository standards
- Ran all pre-PR checks and commands
- Generated/updated auto-generated files

🤖 Generated with [Amplifier](https://github.com/microsoft/amplifier)

Co-Authored-By: Amplifier <240397093+microsoft-amplifier@users.noreply.github.com>"
     echo "✅ Documentation compliance complete"
   else
     echo "✅ Documentation already compliant, no updates needed"
   fi
   ```

   **If COMPLIANCE STATUS: FAILED:**
   ```bash
   echo "❌ Documentation compliance FAILED"
   echo ""
   echo "The following issues must be fixed before submitting PR:"
   echo "{Show FAILURES section from agent report}"
   echo ""
   echo "Please fix these issues and run /git:submit-pr again"
   exit 1
   ```

### Step 4: Push to Remote

1. Check if the branch exists on remote:
   ```bash
   cd "$PROJECT_DIR"
   git ls-remote --heads origin $(git branch --show-current)
   ```

2. Push the branch:
   ```bash
   git push -u origin $(git branch --show-current)
   ```

### Step 5: Discover Repository PR Standards

Before creating the PR, discover repository-specific PR title and description standards:

1. **Standards are already loaded from Step 3** (CONTRIBUTING.md, MAINTENANCE.md, CLAUDE.md)

2. **Analyze recent PRs for patterns:**
   ```bash
   cd "$PROJECT_DIR"
   gh pr list --state merged --limit 5 --json title,body
   ```

   Look for:
   - Title format (e.g., "feat:", "fix:", "[Component] Description")
   - Common description sections
   - PR body structure

### Step 6: Create Pull Request

1. Check if a PR already exists for this branch:
   ```bash
   cd "$PROJECT_DIR"
   gh pr view --json number,url 2>/dev/null || echo "No existing PR"
   ```

2. If no PR exists, create one automatically **following discovered standards**:

   - Generate a PR title that matches the discovered format conventions
   - Generate a PR description that includes:
     - Required sections from discovered standards
     - Summary of changes based on git diff analysis
     - Test plan or verification steps
     - Any other required content
   - Maintain the tone and style consistent with the repo's standards
   - Create the PR immediately (no confirmation needed):
     ```bash
     gh pr create --title "PR_TITLE" --body "PR_BODY"
     ```

3. If PR exists, report the existing PR URL

### Step 7: Monitor PR Gates and Status

After PR creation, ask the user if they want to monitor and auto-merge:

```bash
cd "$PROJECT_DIR"

PR_NUMBER=$(gh pr view --json number -q .number)
PR_URL=$(gh pr view --json url -q .url)

echo ""
echo "✅ PR created: $PR_URL"
echo ""
echo "Would you like to:"
echo "1. Monitor PR checks and auto-merge when approved (recommended)"
echo "2. Exit now and manage PR manually"
echo ""
read -p "Enter choice (1 or 2): " CHOICE

if [[ "$CHOICE" != "1" ]]; then
  echo "PR submitted successfully. You can manage it manually at: $PR_URL"
  exit 0
fi

echo ""
echo "🔍 Monitoring PR status and checks..."
echo ""

# Show initial status
gh pr view --json statusCheckRollup,reviewDecision -q '.statusCheckRollup[] | "  [\(.state)] \(.context)"'

echo ""
echo "Watching for updates... (Press Ctrl+C to stop and exit)"
echo ""

# Monitor checks in a loop
PREV_STATE=""
while true; do
  # Get current status
  STATUS=$(gh pr view "$PR_NUMBER" --json statusCheckRollup,reviewDecision,state)

  # Extract check states
  CHECKS_STATE=$(echo "$STATUS" | jq -r '.statusCheckRollup[]? | "\(.state)|\(.context)"')
  REVIEW_STATE=$(echo "$STATUS" | jq -r '.reviewDecision // "PENDING"')
  PR_STATE=$(echo "$STATUS" | jq -r '.state')

  CURRENT_STATE="$CHECKS_STATE|$REVIEW_STATE|$PR_STATE"

  # Only show update if state changed
  if [[ "$CURRENT_STATE" != "$PREV_STATE" ]]; then
    echo "$(date '+%H:%M:%S') - Status Update:"

    # Show check statuses
    echo "$CHECKS_STATE" | while IFS='|' read -r state context; do
      case "$state" in
        SUCCESS) echo "  ✅ $context" ;;
        FAILURE) echo "  ❌ $context" ;;
        PENDING) echo "  ⏳ $context" ;;
        *) echo "  ⚪ $context ($state)" ;;
      esac
    done

    # Show review status
    case "$REVIEW_STATE" in
      APPROVED) echo "  ✅ PR Approved" ;;
      CHANGES_REQUESTED) echo "  🔄 Changes Requested" ;;
      PENDING) echo "  ⏳ Awaiting Review" ;;
    esac

    # Check if PR is ready to merge
    if [[ "$REVIEW_STATE" == "APPROVED" ]]; then
      ALL_CHECKS_PASSED=true
      echo "$CHECKS_STATE" | while IFS='|' read -r state context; do
        if [[ "$state" != "SUCCESS" && -n "$state" ]]; then
          ALL_CHECKS_PASSED=false
          break
        fi
      done

      if [[ "$ALL_CHECKS_PASSED" == "true" ]]; then
        echo ""
        echo "🎉 PR is approved and all checks passed!"
        echo "Ready to proceed to merge..."
        break
      fi
    fi

    PREV_STATE="$CURRENT_STATE"
  fi

  # If PR is closed/merged, stop monitoring
  if [[ "$PR_STATE" == "MERGED" || "$PR_STATE" == "CLOSED" ]]; then
    echo "PR state: $PR_STATE"
    break
  fi

  sleep 10  # Check every 10 seconds
done
```

### Step 8: Auto-Merge and Cleanup

Once the PR is approved and all checks pass:

```bash
cd "$PROJECT_DIR"

echo ""
echo "🔀 Merging PR #$PR_NUMBER..."

# Merge the PR
gh pr merge "$PR_NUMBER" --merge --delete-branch

if [[ $? -eq 0 ]]; then
  echo "✅ PR merged successfully!"

  # Switch back to main/master
  BASE_BRANCH=$(gh pr view "$PR_NUMBER" --json baseRefName -q .baseRefName)
  git checkout "$BASE_BRANCH"

  # Pull latest changes
  git pull origin "$BASE_BRANCH"

  # Delete local branch
  BRANCH_NAME=$(git branch --list | grep -v "^\*" | grep -v "$BASE_BRANCH" | tail -1 | xargs)
  if [[ -n "$BRANCH_NAME" ]]; then
    git branch -D "$BRANCH_NAME"
    echo "✅ Deleted local branch: $BRANCH_NAME"
  fi

  echo ""
  echo "🎉 Complete! You're back on $BASE_BRANCH with latest changes."
else
  echo "❌ Merge failed. Please check the PR manually: $PR_URL"
  exit 1
fi
```

### Step 9: Report Final Result

Show the user:
- PR URL
- PR number
- Merge status
- Summary of what was done (commits, docs updated, commands run, checks passed, merged)
- Current branch status

## Error Handling

- If `gh` CLI is not installed, inform user and provide installation instructions
- If not authenticated with GitHub, guide user through `gh auth login`
- If push fails due to conflicts, suggest running `git pull --rebase` first
- If PROJECT_DIR is not set, inform user and use current directory as fallback
- If compliance check fails, stop and report what needs to be fixed

## Important Notes

- **Automatic branch creation**: If on main/master, automatically creates a feature branch
- **Automatic PR monitoring**: Watches CI/CD checks and approval status in real-time
- **Automatic merge**: When approved and checks pass, merges PR and cleans up branches
- Never force push without explicit user confirmation
- All actions are automatic - no user confirmation needed for commits or PR creation
- Documentation compliance is AUTOMATIC - never skip it
- If compliance fails, PR submission is blocked until fixed
- Process is designed for speed - monitors and completes the entire PR lifecycle

## Optimization

For repositories with complex requirements, consider creating a specialized agent:

**`.claude/agents/docs-compliance-agent.md`:**

This command will automatically use `docs-compliance-agent` if it exists, otherwise it uses the general-purpose agent. The specialized agent can be tailored to your repository's specific requirements for better performance.

See project documentation for details on creating specialized compliance agents.

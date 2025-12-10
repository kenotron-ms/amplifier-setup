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
   - Create the PR and **immediately enable auto-merge**:
     ```bash
     # Create PR
     gh pr create --title "PR_TITLE" --body "PR_BODY"

     # Enable auto-merge immediately (GitHub will merge when checks pass + approved)
     PR_NUMBER=$(gh pr view --json number -q .number)
     gh pr merge "$PR_NUMBER" --auto --merge

     if [[ $? -eq 0 ]]; then
       echo "✅ Auto-merge enabled - PR will merge automatically when approved and checks pass"
     else
       echo "⚠️  Could not enable auto-merge (may require repository permissions)"
       echo "   Will monitor and merge manually instead"
     fi
     ```

3. If PR exists, check if auto-merge is already enabled, enable it if not:
   ```bash
   AUTO_MERGE=$(gh pr view --json autoMergeRequest -q .autoMergeRequest)
   if [[ "$AUTO_MERGE" == "null" ]]; then
     gh pr merge --auto --merge 2>/dev/null && echo "✅ Auto-merge enabled"
   fi
   ```

### Step 7: Continuously Monitor PR Status with Sleep + Poll Loop

**FULLY AUTONOMOUS - NO USER PROMPTS**

After PR creation, enter a continuous monitoring loop using `sleep` + `gh pr view`:

```bash
cd "$PROJECT_DIR"

PR_NUMBER=$(gh pr view --json number -q .number)
PR_URL=$(gh pr view --json url -q .url)

echo ""
echo "✅ PR created: $PR_URL"
echo ""
echo "🔍 Entering continuous monitoring loop (checking every 30 seconds)..."
echo "   Will automatically fix issues and merge when ready."
echo ""

# Initialize retry tracking
MAX_RETRY_ATTEMPTS=3
RETRY_COUNT=0
PREV_STATE_HASH=""

# Continuous monitoring loop
while true; do
  # Sleep first (except first iteration)
  if [[ -n "$PREV_STATE_HASH" ]]; then
    sleep 30
  fi

  # Fetch current PR status
  echo "$(date '+%H:%M:%S') - Checking PR status..."

  PR_DATA=$(gh pr view "$PR_NUMBER" --json \
    state,statusCheckRollup,reviewDecision,reviews,latestReviews 2>/dev/null)

  if [[ $? -ne 0 ]]; then
    echo "⚠️  Failed to fetch PR status. Retrying..."
    continue
  fi

  # Extract key information
  PR_STATE=$(echo "$PR_DATA" | jq -r '.state')
  REVIEW_DECISION=$(echo "$PR_DATA" | jq -r '.reviewDecision // "PENDING"')

  # Check if PR is already merged or closed
  if [[ "$PR_STATE" == "MERGED" ]]; then
    echo "✅ PR already merged!"
    exit 0
  elif [[ "$PR_STATE" == "CLOSED" ]]; then
    echo "⚠️  PR was closed without merging"
    exit 1
  fi

  # Get check statuses
  CHECKS_JSON=$(echo "$PR_DATA" | jq -r '.statusCheckRollup[]? | "\(.state)|\(.context)|\(.targetUrl // "")"')

  # Calculate state hash to detect changes
  CURRENT_STATE_HASH=$(echo "$PR_STATE|$REVIEW_DECISION|$CHECKS_JSON" | md5sum | cut -d' ' -f1)

  # Only show detailed status if state changed
  if [[ "$CURRENT_STATE_HASH" != "$PREV_STATE_HASH" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Status changed at $(date '+%H:%M:%S')"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Show checks status
    if [[ -n "$CHECKS_JSON" ]]; then
      echo "CI/CD Checks:"
      while IFS='|' read -r state context url; do
        [[ -z "$state" ]] && continue
        case "$state" in
          SUCCESS) echo "  ✅ $context" ;;
          FAILURE) echo "  ❌ $context ($url)" ;;
          PENDING|QUEUED) echo "  ⏳ $context" ;;
          *) echo "  ⚪ $context [$state]" ;;
        esac
      done <<< "$CHECKS_JSON"
    else
      echo "CI/CD Checks: None configured"
    fi

    # Show review status
    echo ""
    echo "Review Status: $REVIEW_DECISION"

    # Detect issues that need fixing
    HAS_FAILED_CHECKS=false
    FAILED_CHECKS_LIST=""

    while IFS='|' read -r state context url; do
      [[ -z "$state" ]] && continue
      if [[ "$state" == "FAILURE" || "$state" == "ERROR" ]]; then
        HAS_FAILED_CHECKS=true
        FAILED_CHECKS_LIST="$FAILED_CHECKS_LIST
- $context: $url"
      fi
    done <<< "$CHECKS_JSON"

    # Check if we need to address issues
    if [[ "$HAS_FAILED_CHECKS" == "true" ]] || [[ "$REVIEW_DECISION" == "CHANGES_REQUESTED" ]]; then
      if [[ $RETRY_COUNT -lt $MAX_RETRY_ATTEMPTS ]]; then
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo ""
        echo "⚠️  Issues detected! (Attempt $RETRY_COUNT of $MAX_RETRY_ATTEMPTS)"
        echo ""

        if [[ "$HAS_FAILED_CHECKS" == "true" ]]; then
          echo "Failed CI/CD checks:"
          echo "$FAILED_CHECKS_LIST"
        fi

        if [[ "$REVIEW_DECISION" == "CHANGES_REQUESTED" ]]; then
          echo "Review changes requested:"
          gh pr view "$PR_NUMBER" --json latestReviews \
            --jq '.latestReviews[] | select(.state=="CHANGES_REQUESTED") | "  - \(.author.login): \(.body)"'
        fi

        echo ""
        echo "🤖 Proceeding to Step 7a to fix issues..."

        # Create flag file with issue details
        cat > "/tmp/pr-needs-fix-$PR_NUMBER.json" <<EOF
{
  "pr_number": "$PR_NUMBER",
  "pr_url": "$PR_URL",
  "failed_checks": $(echo "$PR_DATA" | jq '.statusCheckRollup[] | select(.state=="FAILURE" or .state=="ERROR")'),
  "review_comments": $(echo "$PR_DATA" | jq '[.latestReviews[] | select(.state=="CHANGES_REQUESTED")]'),
  "retry_attempt": $RETRY_COUNT
}
EOF
        break

      else
        echo ""
        echo "❌ Maximum retry attempts reached ($MAX_RETRY_ATTEMPTS)"
        echo ""
        echo "Issues that could not be fixed:"
        [[ "$HAS_FAILED_CHECKS" == "true" ]] && echo "$FAILED_CHECKS_LIST"
        [[ "$REVIEW_DECISION" == "CHANGES_REQUESTED" ]] && \
          gh pr view "$PR_NUMBER" --json latestReviews \
            --jq '.latestReviews[] | select(.state=="CHANGES_REQUESTED") | "  - \(.author.login): \(.body)"'
        echo ""
        echo "PR requires manual intervention: $PR_URL"
        exit 1
      fi
    fi

    # Check if ready to merge
    ALL_CHECKS_PASSED=true
    if [[ -n "$CHECKS_JSON" ]]; then
      while IFS='|' read -r state context url; do
        [[ -z "$state" ]] && continue
        if [[ "$state" != "SUCCESS" ]]; then
          ALL_CHECKS_PASSED=false
          break
        fi
      done <<< "$CHECKS_JSON"
    fi

    if [[ "$REVIEW_DECISION" == "APPROVED" ]] && [[ "$ALL_CHECKS_PASSED" == "true" ]]; then
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "🎉 PR approved and all checks passed!"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo "Proceeding to merge..."
      break
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    PREV_STATE_HASH="$CURRENT_STATE_HASH"
  else
    # No change, just show we're still watching
    echo "  ⏱️  Still monitoring... (no changes detected)"
  fi
done

# Check if we need to fix issues
if [[ -f "/tmp/pr-needs-fix-$PR_NUMBER.json" ]]; then
  # Proceed to Step 7a to address issues
  :
else
  # All checks passed, proceed to merge (Step 8)
  :
fi
```

### Step 7a: Autonomously Address PR Issues

**This step only runs if failures or change requests were detected in Step 7**

When issues are detected, use the Task tool to delegate fixing them:

**Use Task tool with `subagent_type: 'general-purpose'`**

**Provide this detailed prompt:**

```
TASK: Autonomously fix PR issues to enable merge

PR CONTEXT:
- PR Number: {PR_NUMBER}
- PR URL: {PR_URL}
- Current branch: {output of: git branch --show-current}

DETECTED ISSUES:

CI/CD CHECK FAILURES:
{List all failed checks with their context and URLs from Step 7}

REVIEW CHANGE REQUESTS:
{List all review comments requesting changes with reviewer name and feedback}

YOUR MISSION:

1. **Analyze what failed and why:**
   - Read CI/CD logs from failed check URLs
   - Read review comments to understand requested changes
   - Identify root causes of failures

2. **Fix all issues automatically:**

   **For CI check failures:**
   - If linting failures: Run linter and fix all issues
   - If test failures: Fix failing tests or the code causing failures
   - If type errors: Fix all type issues
   - If build failures: Fix build errors
   - Run `make check` or equivalent to verify fixes

   **For review change requests:**
   - Read each comment carefully
   - Implement the requested changes
   - Address all reviewer feedback
   - Ensure changes match reviewer expectations

3. **Commit fixes:**
   ```bash
   cd "$PROJECT_DIR"
   git add -A
   git commit -m "fix: address PR feedback and CI failures

- Fixed {list what was fixed}
- Addressed reviewer feedback from {reviewer names}

🤖 Generated with [Amplifier](https://github.com/microsoft/amplifier)

Co-Authored-By: Amplifier <240397093+microsoft-amplifier@users.noreply.github.com>"
   ```

4. **Push fixes:**
   ```bash
   git push origin $(git branch --show-current)
   ```

5. **Report status in this EXACT format:**
   ```
   FIX STATUS: [COMPLETE|FAILED]

   CI CHECKS ADDRESSED:
   - Check: {check name}
     Status: ✅ Fixed | ❌ Could not fix
     Changes: {what was done to fix it}

   REVIEW FEEDBACK ADDRESSED:
   - Reviewer: {name}
     Status: ✅ Addressed | ❌ Could not address
     Changes: {what was done}

   COMMITS CREATED: {number}
   CHANGES PUSHED: [Yes|No]

   FAILURES: [Only if FIX STATUS is FAILED]
   - What could not be fixed
   - Why it could not be fixed
   - What human intervention is needed
   ```

CRITICAL RULES:
- Be thorough - fix everything you can
- Be accurate - ensure fixes actually resolve the issues
- Test your fixes - run checks before committing
- Commit and push immediately - don't wait
- NO ASKING - just fix everything automatically
```

**Process agent response:**

```bash
cd "$PROJECT_DIR"

# Extract fix status from agent output
if grep -q "FIX STATUS: COMPLETE" <<< "$AGENT_OUTPUT"; then
  echo "✅ Issues fixed successfully by agent"
  echo ""
  echo "🔄 Returning to monitoring loop..."
  # Return to Step 7 to continue monitoring
  # This creates a fix-verify-merge loop
else
  echo "❌ Agent could not fix all issues"
  echo ""
  echo "Issues that could not be fixed automatically:"
  grep -A 100 "FAILURES:" <<< "$AGENT_OUTPUT"
  echo ""
  echo "PR URL: $PR_URL"
  echo "Please fix these issues manually and push to continue"
  exit 1
fi
```

**After fixes are pushed, automatically return to Step 7** to continue monitoring. This creates an autonomous loop:
- Monitor → Detect issues → Fix issues → Push → Monitor → Detect passing → Merge

### Step 8: Wait for Auto-Merge and Cleanup

Since auto-merge is enabled, GitHub will automatically merge when approved and checks pass.
Just wait for it to happen and then clean up local branches:

```bash
cd "$PROJECT_DIR"

echo ""
echo "⏳ Waiting for GitHub auto-merge to complete..."
echo "   (PR will merge automatically when approved and all checks pass)"
echo ""

# Poll until PR is merged
while true; do
  sleep 10

  PR_STATE=$(gh pr view "$PR_NUMBER" --json state -q .state 2>/dev/null)

  if [[ "$PR_STATE" == "MERGED" ]]; then
    echo "✅ PR auto-merged successfully by GitHub!"
    break
  elif [[ "$PR_STATE" == "CLOSED" ]]; then
    echo "⚠️  PR was closed without merging"
    exit 1
  fi

  echo "  ⏱️  Still waiting for auto-merge... (state: $PR_STATE)"
done

# Clean up local branches
echo ""
echo "🧹 Cleaning up local branches..."

BASE_BRANCH=$(gh pr view "$PR_NUMBER" --json baseRefName -q .baseRefName 2>/dev/null)
FEATURE_BRANCH=$(git branch --show-current)

# Switch back to base branch
git checkout "$BASE_BRANCH"

# Pull latest changes (includes the merged PR)
git pull origin "$BASE_BRANCH"

# Delete local feature branch
if [[ "$FEATURE_BRANCH" != "$BASE_BRANCH" ]]; then
  git branch -D "$FEATURE_BRANCH"
  echo "✅ Deleted local branch: $FEATURE_BRANCH"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Complete! PR merged and cleaned up."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "You're back on $BASE_BRANCH with the latest changes."
echo "PR: $PR_URL"
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

- **FULLY AUTONOMOUS**: Zero user prompts or confirmations required
- **Automatic branch creation**: If on main/master, automatically creates a feature branch
- **GitHub auto-merge**: Enables auto-merge on PR creation - GitHub merges when ready
- **Continuous monitoring**: Polls PR status every 30 seconds using `sleep` + `gh pr view`
- **Autonomous issue fixing**: When CI fails or changes are requested, automatically fixes and re-pushes
- **Fix-verify-merge loop**: Continuously monitors → fixes issues → verifies → GitHub auto-merges
- **Maximum 3 retry attempts**: If issues can't be fixed after 3 tries, exits with error
- Never force push without explicit user confirmation
- All actions are automatic - no user confirmation needed for commits, PR creation, monitoring, or merging
- Documentation compliance is AUTOMATIC - never skip it
- If compliance fails, PR submission is blocked until fixed
- Process is designed for complete autonomy - submit PR and walk away, it will handle everything

## Optimization

For repositories with complex requirements, consider creating a specialized agent:

**`.claude/agents/docs-compliance-agent.md`:**

This command will automatically use `docs-compliance-agent` if it exists, otherwise it uses the general-purpose agent. The specialized agent can be tailored to your repository's specific requirements for better performance.

See project documentation for details on creating specialized compliance agents.

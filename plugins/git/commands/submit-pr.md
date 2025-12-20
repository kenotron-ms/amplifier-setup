---
description: Submit a pull request with automatic documentation compliance
---

# Submit Pull Request

Complete end-to-end PR workflow: automatically creates branches, commits changes, ensures documentation compliance, monitors CI/CD checks, and merges when approved.

**🎯 Smart Standards Discovery**: This command automatically discovers and follows repository-specific PR standards by reading documentation files (`CONTRIBUTING.md`, `MAINTENANCE.md`, `CLAUDE.md`). It ensures all documentation is updated and all required steps are completed before creating the PR.

**✨ Full Lifecycle Automation**:
- **Auto-branch**: Creates feature branch if on main/master
- **Auto-monitor**: Watches PR checks and approval status in real-time
- **Smart merge**: Uses GitHub auto-merge when available, otherwise merges manually when checks pass
- **Auto-cleanup**: Cleans up branches after merge completes

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

### Step 3: Pull Latest Changes and Resolve Merge Conflicts

**This step ensures the branch is up-to-date with the base branch before PR submission.**

1. **Identify the base branch:**
   ```bash
   cd "$PROJECT_DIR"

   # Determine if this repo uses main or master
   if git rev-parse --verify origin/main >/dev/null 2>&1; then
     BASE_BRANCH="main"
   elif git rev-parse --verify origin/master >/dev/null 2>&1; then
     BASE_BRANCH="master"
   else
     echo "❌ Cannot determine base branch (neither main nor master exists)"
     exit 1
   fi

   echo "📌 Base branch: $BASE_BRANCH"
   ```

2. **Fetch latest changes from remote:**
   ```bash
   cd "$PROJECT_DIR"
   git fetch origin "$BASE_BRANCH"
   echo "✅ Fetched latest changes from origin/$BASE_BRANCH"
   ```

3. **Check for merge conflicts:**
   ```bash
   cd "$PROJECT_DIR"

   # Try to merge base branch (dry-run first to detect conflicts)
   if git merge-base --is-ancestor origin/"$BASE_BRANCH" HEAD; then
     echo "✅ Branch is already up-to-date with $BASE_BRANCH"
   else
     echo "🔄 Merging latest changes from origin/$BASE_BRANCH..."

     # Attempt the merge
     if git merge origin/"$BASE_BRANCH" --no-edit; then
       echo "✅ Successfully merged $BASE_BRANCH with no conflicts"
     else
       echo "⚠️  Merge conflicts detected - analyzing before resolution..."
       # Conflicts detected - proceed to analysis
     fi
   fi
   ```

4. **If conflicts exist, analyze them carefully using the Task tool:**

   **Use Task tool with `subagent_type: 'general-purpose'`**

   **Provide this detailed prompt:**

   ```
   TASK: Carefully analyze and resolve merge conflicts with full context understanding

   CRITICAL: DO NOT jump to conclusions. Thoroughly analyze the conflicting changes by reviewing the actual commits and understanding the intent behind each change before proposing resolutions.

   MERGE CONTEXT:
   - Current branch: {output of: git branch --show-current}
   - Base branch: {BASE_BRANCH}
   - Conflicted files: {output of: git diff --name-only --diff-filter=U}

   YOUR MISSION:

   1. **List all conflicted files:**
      ```bash
      cd "$PROJECT_DIR"
      git diff --name-only --diff-filter=U
      ```

   2. **For EACH conflicted file, perform deep analysis:**

      **A. View the conflict markers:**
      ```bash
      cat [conflicted_file]
      ```

      **B. Understand what changed in OUR branch (feature branch):**
      ```bash
      # Get the merge base (common ancestor)
      MERGE_BASE=$(git merge-base HEAD origin/$BASE_BRANCH)

      # Show what we changed in our branch
      git log $MERGE_BASE..HEAD --oneline -- [conflicted_file]
      git diff $MERGE_BASE..HEAD -- [conflicted_file]
      ```

      **C. Understand what changed in THEIR branch (base branch):**
      ```bash
      # Show what changed in base branch since we diverged
      git log $MERGE_BASE..origin/$BASE_BRANCH --oneline -- [conflicted_file]
      git diff $MERGE_BASE..origin/$BASE_BRANCH -- [conflicted_file]
      ```

      **D. Read the actual commit messages and full diffs:**
      ```bash
      # Show full commit details for our changes
      git log $MERGE_BASE..HEAD -p -- [conflicted_file]

      # Show full commit details for their changes
      git log $MERGE_BASE..origin/$BASE_BRANCH -p -- [conflicted_file]
      ```

      **E. Analyze the intent and context:**
      - What problem was each side trying to solve?
      - Are the changes related or independent?
      - Is one change a refactor that affects the other?
      - Did someone rename/move code that we modified?
      - Are there breaking changes in either branch?
      - Do the commit messages reveal important context?

   3. **Categorize the conflict complexity:**

      **SIMPLE CONFLICTS** (you should resolve automatically):
      - Both sides made independent changes to adjacent lines
      - One side added, other side modified nearby
      - Formatting/whitespace conflicts
      - Simple variable/function renames that don't change logic
      - Non-overlapping feature additions

      **COMPLEX CONFLICTS** (requires human judgment):
      - Both sides modified the same function/logic differently
      - Architectural changes that conflict (different design decisions)
      - Breaking changes on one side that affect the other
      - Semantic conflicts (code that technically merges but is logically wrong)
      - Security or safety-critical code with conflicting approaches
      - Unclear intent from commit messages

   4. **For SIMPLE conflicts - resolve automatically:**

      For each file with simple conflicts:

      ```bash
      # Edit the file to resolve conflicts intelligently
      # Keep both changes if they're independent
      # Choose the more complete/recent implementation if one supersedes the other
      # Preserve the intent from both branches

      # Mark as resolved
      git add [conflicted_file]
      ```

      Document your resolution reasoning in the commit message.

   5. **For COMPLEX conflicts - request human help:**

      If ANY conflict is complex, STOP and report to the user:

      ```
      CONFLICT STATUS: REQUIRES_HUMAN_REVIEW

      COMPLEX CONFLICTS DETECTED:

      File: [conflicted_file]
      Complexity: [Why this requires human judgment]

      CONTEXT FROM OUR BRANCH (feature):
      Commits:
      {git log output showing our commits}

      Changes:
      {summarize what we changed and why based on commits}

      CONTEXT FROM BASE BRANCH:
      Commits:
      {git log output showing base branch commits}

      Changes:
      {summarize what they changed and why based on commits}

      CONFLICT ANALYSIS:
      - Nature of conflict: [describe the conflicting changes]
      - Why it's complex: [explain why this needs human judgment]
      - Possible resolutions: [list 2-3 possible ways to resolve]
      - Risks: [what could go wrong with each approach]

      RECOMMENDATION:
      [Your suggestion for how to resolve, with clear reasoning]

      Please review the conflict and provide guidance on the correct resolution approach.
      ```

   6. **If all conflicts were simple and resolved, commit the merge:**
      ```bash
      cd "$PROJECT_DIR"
      git commit -m "merge: resolve conflicts with $BASE_BRANCH

   - Merged latest changes from $BASE_BRANCH
   - Resolved conflicts in: {list files}
   - {brief summary of how conflicts were resolved}

   🤖 Generated with [Amplifier](https://github.com/microsoft/amplifier)

   Co-Authored-By: Amplifier <240397093+microsoft-amplifier@users.noreply.github.com>"
      ```

   7. **Report status in this EXACT format:**
      ```
      MERGE STATUS: [COMPLETE|REQUIRES_HUMAN_REVIEW|FAILED]

      CONFLICTS ANALYZED: {number}

      SIMPLE CONFLICTS (auto-resolved):
      - File: path/to/file
        Analysis: {what changed in each branch}
        Resolution: {how it was resolved and why}

      COMPLEX CONFLICTS (need review):
      - File: path/to/file
        Analysis: {detailed analysis from step 5}

      MERGE COMMIT: [Created|Not needed]
      ```

   CRITICAL RULES:
   - ALWAYS analyze commit history and full diffs before resolving
   - NEVER guess at the intent - read the actual commits
   - NEVER resolve complex conflicts without human review
   - When in doubt, ask for human guidance
   - Document your reasoning clearly
   - Test that the resolution makes sense logically (not just syntactically)
   ```

5. **Process the agent response:**

   **If MERGE STATUS: COMPLETE:**
   ```bash
   echo "✅ Successfully merged and resolved conflicts with $BASE_BRANCH"
   echo "   Proceeding to documentation compliance check..."
   ```

   **If MERGE STATUS: REQUIRES_HUMAN_REVIEW:**
   ```bash
   echo "⚠️  Complex merge conflicts detected that require human review"
   echo ""
   echo "{Display the conflict analysis from agent report}"
   echo ""
   echo "Please review the conflicts above and either:"
   echo "  1. Resolve manually: git merge --continue after fixing"
   echo "  2. Abort merge: git merge --abort"
   echo ""
   echo "After resolving, run /git:submit-pr again"
   exit 1
   ```

   **If MERGE STATUS: FAILED:**
   ```bash
   echo "❌ Merge failed with errors"
   echo ""
   echo "{Show error details from agent report}"
   exit 1
   ```

### Step 4: Ensure Documentation Compliance (Automatic)

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

### Step 5: Push to Remote

1. Check if the branch exists on remote:
   ```bash
   cd "$PROJECT_DIR"
   git ls-remote --heads origin $(git branch --show-current)
   ```

2. Push the branch:
   ```bash
   git push -u origin $(git branch --show-current)
   ```

### Step 6: Discover Repository PR Standards

Before creating the PR, discover repository-specific PR title and description standards:

1. **Standards are already loaded from Step 4** (CONTRIBUTING.md, MAINTENANCE.md, CLAUDE.md)

2. **Analyze recent PRs for patterns:**
   ```bash
   cd "$PROJECT_DIR"
   gh pr list --state merged --limit 5 --json title,body
   ```

   Look for:
   - Title format (e.g., "feat:", "fix:", "[Component] Description")
   - Common description sections
   - PR body structure

### Step 7: Create Pull Request

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
   - Create the PR and **attempt to enable auto-merge**:
     ```bash
     # Create PR
     gh pr create --title "PR_TITLE" --body "PR_BODY"

     # Try to enable auto-merge (may fail if not enabled in repo)
     PR_NUMBER=$(gh pr view --json number -q .number)
     AUTO_MERGE_ENABLED=false

     if gh pr merge "$PR_NUMBER" --auto --merge 2>/dev/null; then
       echo "✅ Auto-merge enabled - PR will merge automatically when approved and checks pass"
       AUTO_MERGE_ENABLED=true
     else
       echo "⚠️  Auto-merge not available in this repository"
       echo "   Will monitor checks and merge manually when ready"
       AUTO_MERGE_ENABLED=false
     fi

     # Store auto-merge status for later steps
     export AUTO_MERGE_ENABLED
     ```

3. If PR exists, check if auto-merge is already enabled, enable it if not:
   ```bash
   AUTO_MERGE=$(gh pr view --json autoMergeRequest -q .autoMergeRequest)
   if [[ "$AUTO_MERGE" == "null" ]]; then
     gh pr merge --auto --merge 2>/dev/null && echo "✅ Auto-merge enabled"
   fi
   ```

4. **After PR is created, IMMEDIATELY proceed to Step 8** - do NOT ask the user what to do next, do NOT pause, do NOT provide options. The workflow is fully autonomous.

### Step 8: Monitor PR Status Until Ready or Issues Detected

**CRITICAL: This step ALWAYS runs immediately after Step 7 - NO USER CONFIRMATION NEEDED**

**FULLY AUTONOMOUS - NO USER PROMPTS**

After PR creation, IMMEDIATELY begin monitoring the PR status by repeatedly checking and waiting:

**Your mission**: Keep checking the PR status every 30 seconds until one of these conditions is met:

1. **PR is merged** → Report success and proceed to Step 8 (cleanup)
2. **PR has failed CI checks, change requests, or merge conflicts** → Proceed to Step 7a (fix issues), maximum 3 attempts
3. **PR is closed without merging** → Report failure and exit

**How to monitor**:

1. Use `gh pr view [PR_NUMBER] --json state,statusCheckRollup,reviewDecision,mergeable,comments` to check status
2. Check for new comments since last check:
   - Track the number of comments from previous check
   - If comment count increased, fetch and display new comments: `gh pr view [PR_NUMBER] --json comments`
   - Report new comments to user (reviewer name, timestamp, comment body)
3. Display the current status clearly when it changes (not every check)
4. Wait 30 seconds using Bash `sleep 30` command
5. Repeat until one of the exit conditions is met

**What to report**:
- Current timestamp
- PR state (OPEN/MERGED/CLOSED)
- Review status (PENDING/APPROVED/CHANGES_REQUESTED)
- CI/CD check results (SUCCESS/PENDING/FAILURE)
- Merge conflicts status (mergeable field: MERGEABLE/CONFLICTING/UNKNOWN)
- New comments (if any): reviewer name, timestamp, comment text
- What we're waiting for (approval, checks, conflict resolution, or ready to merge)

**Exit conditions**:
- ✅ **MERGED**: PR successfully merged → go to Step 9
- ⚠️  **Failed checks, changes requested, or conflicts**: → go to Step 8a (up to 3 times)
- ❌ **CLOSED**: PR closed without merging → exit with error
- 🎉 **All checks passed + no conflicts**:
  - If `AUTO_MERGE_ENABLED=true`: Wait for GitHub auto-merge → go to Step 9
  - If `AUTO_MERGE_ENABLED=false`: Merge manually → go to Step 8b

### Step 8a: Autonomously Address PR Issues

**This step only runs if failures or change requests were detected in Step 8**

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

MERGE CONFLICTS:
{If mergeable status is CONFLICTING, note that conflicts exist}

YOUR MISSION:

1. **Download and analyze CI artifacts FIRST (for CI failures):**

   **CRITICAL: Many failures only reproduce in CI. Always download artifacts before theorizing.**

   For each failed CI check:
   ```bash
   # Get the run ID for the failed check
   RUN_ID=$(gh run list --workflow="<workflow-name>" --limit 1 --json databaseId -q '.[0].databaseId')

   # Download all artifacts from the failed run
   gh run download "$RUN_ID" --dir ci-artifacts/

   # List what was downloaded
   find ci-artifacts/ -type f
   ```

   **Examine downloaded artifacts:**
   - **Log files**: Read complete error logs and stack traces
   - **Test results**: Screenshots, videos, test output files
   - **Build artifacts**: Build logs, compilation errors
   - **Coverage reports**: Identify untested code paths
   - **Error context files**: Any `error-context.md` or similar diagnostic files
   - **Environment info**: CI environment details that differ from local

   **Compare CI vs Local:**
   - What's different in the CI environment? (Node version, OS, dependencies, environment variables)
   - Does the error only happen in CI? (timing issues, environment-specific bugs)
   - Are there CI-specific configurations? (different test settings, stricter rules)

2. **Analyze what failed and why (using CI evidence):**
   - Read the downloaded CI logs and artifacts thoroughly
   - Read review comments to understand requested changes
   - Check if merge conflicts exist (mergeable: CONFLICTING)
   - Identify root causes based on ACTUAL CI evidence, not local assumptions

3. **Fix all issues automatically:**

   **For merge conflicts:**
   - Pull latest changes from base branch: `git fetch origin && git merge origin/main` (or master)
   - Resolve conflicts intelligently by analyzing both versions
   - Keep changes from this PR while integrating base branch updates
   - Test that resolved code still works correctly
   - Mark conflicts as resolved

   **For CI check failures (using downloaded artifacts from Step 1):**
   - If linting failures: Run linter and fix all issues based on CI logs
   - If test failures: Fix failing tests or the code causing failures (reference test screenshots/videos if available)
   - If type errors: Fix all type issues shown in CI build logs
   - If build failures: Fix build errors using exact error messages from CI logs
   - If CI-specific issues: Address environment differences, timing issues, or configuration problems revealed in artifacts
   - Run the target project's verification commands to verify fixes locally
   - Consider if fixes need CI-specific testing (e.g., different Node version, OS-specific issues)

   **For review change requests:**
   - Read each comment carefully
   - Implement the requested changes
   - Address all reviewer feedback
   - Ensure changes match reviewer expectations

4. **Commit fixes:**
   ```bash
   cd "$PROJECT_DIR"
   git add -A
   git commit -m "fix: address PR feedback and CI failures

- Fixed {list what was fixed}
- Addressed reviewer feedback from {reviewer names}

🤖 Generated with [Amplifier](https://github.com/microsoft/amplifier)

Co-Authored-By: Amplifier <240397093+microsoft-amplifier@users.noreply.github.com>"
   ```

5. **Push fixes:**
   ```bash
   git push origin $(git branch --show-current)
   ```

6. **Report status in this EXACT format:**
   ```
   FIX STATUS: [COMPLETE|FAILED]

   CI ARTIFACTS ANALYZED:
   - Run ID: {run id}
     Status: ✅ Downloaded and analyzed | ⊘ No artifacts available | ❌ Could not download
     Artifacts: {list of key artifacts examined: logs, screenshots, test results, etc.}
     Key findings: {what the artifacts revealed about the failure}

   MERGE CONFLICTS RESOLVED:
   - Status: ✅ Resolved | ⊘ No conflicts | ❌ Could not resolve
     Files: {list of conflicted files}
     Resolution: {brief description of how conflicts were resolved}

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
- **Download CI artifacts FIRST** - Never theorize about CI failures without examining actual logs and artifacts
- **Use evidence, not assumptions** - Base fixes on what the CI logs/artifacts show, not local behavior
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

**After fixes are pushed, automatically return to Step 8** to continue monitoring. This creates an autonomous loop:
- Monitor → Detect issues → Fix issues → Push → Monitor → Detect passing → Merge

### Step 8b: Manual Merge When Checks Pass

**This step only runs if auto-merge is not enabled/available AND all checks have passed**

When auto-merge is not available in the repository but all checks are green and there are no conflicts:

1. **Verify the PR is ready to merge**: Check one final time that all status checks show SUCCESS and the PR is mergeable

2. **Merge the PR**: Use the gh CLI to merge the PR and delete the remote branch

3. **Report success**: Confirm the PR was merged and the branch was deleted

4. **If merge fails**: Report the error and provide the PR URL for manual intervention

After successful merge, proceed to Step 9 for cleanup.

### Step 9: Cleanup After Merge

**This step runs after the PR has been merged (either via GitHub auto-merge or manual merge in Step 8b)**

Once the PR is confirmed as merged, clean up the local workspace:

**If auto-merge was enabled (coming from Step 8 monitoring)**:
1. Wait for GitHub to complete the auto-merge by polling the PR state
2. When state becomes "MERGED" → proceed to cleanup below
3. If state becomes "CLOSED" → exit with error

**If manual merge was performed (coming from Step 8b)**:
- Skip waiting, PR is already merged → proceed directly to cleanup below

**Cleanup local branches**:
1. Get the base branch name (main/master) from the PR
2. Switch to the base branch: `git checkout [base_branch]`
3. Pull latest changes: `git pull origin [base_branch]`
4. Delete the feature branch: `git branch -D [feature_branch]`

**Report completion**:
- PR URL
- Confirmation that you're back on base branch
- Latest changes pulled

### Step 10: Report Final Result

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

- **FULLY AUTONOMOUS**: The ENTIRE workflow (Steps 1-9) is autonomous with zero user prompts or confirmations unless an unfixable issue is encountered
- **NO ASKING THE USER**: NEVER ask "Would you like me to monitor?" or present options at any point - the workflow runs continuously from start to finish
- **Automatic branch creation**: If on main/master, automatically creates a feature branch
- **Smart merging strategy**: Attempts to enable auto-merge, but if not available, monitors and merges manually when checks pass
- **Continuous monitoring**: Polls PR status every 30 seconds to detect when checks complete
- **Autonomous issue fixing**: When CI fails or changes are requested, automatically fixes and re-pushes (up to 3 attempts)
- **Fix-verify-merge loop**: Continuously monitors → fixes issues → verifies → merges (auto or manual)
- **Maximum 3 retry attempts**: If issues can't be fixed after 3 tries, exits with error and requests human intervention
- Never force push without explicit user confirmation
- All actions are automatic - no user confirmation needed for commits, PR creation, monitoring, or merging
- Documentation compliance is AUTOMATIC - never skip it
- If compliance fails, PR submission is blocked until fixed
- **Process design**: Submit PR and walk away - the command handles everything autonomously until the PR is merged or an unfixable issue requires human intervention

## Optimization

For repositories with complex requirements, consider creating a specialized agent:

**`.claude/agents/docs-compliance-agent.md`:**

This command will automatically use `docs-compliance-agent` if it exists, otherwise it uses the general-purpose agent. The specialized agent can be tailored to your repository's specific requirements for better performance.

See project documentation for details on creating specialized compliance agents.

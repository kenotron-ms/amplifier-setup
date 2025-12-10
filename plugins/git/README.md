# Git Plugin

Git workflow helpers for creating PRs and syncing branches with intelligent conflict resolution.

## Commands

- `/pull` - Sync your feature branch with latest changes from origin/main
- `/submit-pr` - Submit a pull request from the current branch

## Skills

- **pr-submission** - Automatically triggers `/submit-pr` when you mention creating or merging a PR

  The skill activates when you say things like:
  - "Create a PR"
  - "Submit a pull request"
  - "Let's merge this"
  - "Ready for review"
  - "Open a pull request"

  It immediately runs `/submit-pr` without asking for confirmation, giving you a fully hands-off experience.

## Project Directory Handling

The git plugin automatically works in the correct project directory:

- **Default**: Uses `$PWD` (current working directory)
- **Override**: Set `PROJECT_DIR` environment variable to specify a different location
- **Why**: Ensures git commands run in your actual project, not the Claude worktree

### How It Works

When you run `/pull` or `/submit-pr`, the commands will:
1. Check if `PROJECT_DIR` is set in your environment
2. Fall back to `$PWD` (current directory) if not set
3. Display which directory is being used
4. Run all git operations in that directory

### Setting PROJECT_DIR (Optional)

If you need to override the default behavior:

```bash
export PROJECT_DIR="/path/to/your/project"
```

Or add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):
```bash
# Auto-set PROJECT_DIR when using amp
if [ -n "$AMP_WORKSPACE" ]; then
  export PROJECT_DIR="$PWD"
fi
```

## Usage

### Syncing with Main

```
/pull
```

This will:
- Fetch latest changes from origin/main
- Attempt to rebase your feature branch
- Guide you through conflict resolution if needed
- Restore any stashed changes

### Submitting a Pull Request

```
/submit-pr
```

This automates the complete PR workflow from start to finish with **ZERO user prompts**:

**Smart branch handling:**
- Automatically creates a feature branch if you're on main/master
- Prevents accidental commits to base branch

**Automatic commits and compliance:**
- Commits any uncommitted changes with smart commit messages
- **Ensures documentation compliance (automatic)**:
  - Discovers repository documentation standards
  - Updates all required documentation based on code changes
  - Runs required checks (linting, testing, type checking)
  - Generates/updates auto-generated files
  - Blocks PR submission if compliance fails

**PR creation and auto-merge:**
- Pushes your branch to remote
- Creates pull request following repository conventions
- **Enables GitHub auto-merge immediately** - GitHub merges when conditions met
- **Continuous monitoring with sleep + gh pr polling** (checks every 30 seconds)
- Shows live status updates for checks and approvals

**Autonomous issue fixing:**
- **When CI checks fail**: Automatically analyzes logs, fixes issues, and re-pushes
- **When changes are requested**: Automatically addresses reviewer feedback and updates PR
- **Fix-verify-merge loop**: Monitors → Fixes → Verifies → GitHub auto-merges (max 3 attempts)
- Fully autonomous - no human intervention needed

**Auto-merge and cleanup:**
- GitHub auto-merges when approved and checks pass
- Command waits for auto-merge to complete
- Automatically deletes local feature branch
- Switches back to base branch with latest changes
- **Submit PR and walk away** - complete hands-off workflow

## Requirements

- Git installed and configured
- For `/submit-pr`: GitHub CLI (`gh`) installed and authenticated

## Migration from git-flow

This plugin was renamed from `git-flow` to `git`:
- Plugin name: `git-flow` → `git`
- Command: `/git-pull` → `/pull`
- Command: `/submit-pr` (unchanged)

The functionality remains the same, with improved project directory handling.

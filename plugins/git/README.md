# Git Plugin

Git workflow helpers for creating PRs and syncing branches with intelligent conflict resolution.

## Commands

- `/pull` - Sync your feature branch with latest changes from origin/main
- `/submit-pr` - Submit a pull request from the current branch

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

This will:
- Check your git state
- Commit any uncommitted changes (with your approval)
- **Ensure documentation compliance (automatic)**:
  - Discover repository documentation standards
  - Update all required documentation based on code changes
  - Run required checks (linting, testing, type checking)
  - Generate/update auto-generated files
  - Block PR submission if compliance fails
- Push your branch to remote
- Discover repository PR standards from docs and recent PRs
- Create a pull request using `gh` CLI following discovered conventions

## Requirements

- Git installed and configured
- For `/submit-pr`: GitHub CLI (`gh`) installed and authenticated

## Migration from git-flow

This plugin was renamed from `git-flow` to `git`:
- Plugin name: `git-flow` → `git`
- Command: `/git-pull` → `/pull`
- Command: `/submit-pr` (unchanged)

The functionality remains the same, with improved project directory handling.

# Migration Guide: Upgrading to Worktree-based Workspaces

This guide helps you upgrade from the pre-December 2025 version of `amp` to the new worktree-based workspace system.

## What Changed?

### Before (Single Shared Environment)
```
~/.amp/main/
├── .venv/                    # Shared by all projects
├── ai_working/               # Shared by all projects
├── .data/                    # Shared by all projects
└── amplifier/                # Shared codebase
```

**Problems:**
- ❌ Dependency conflicts between projects
- ❌ AI working files mixed together
- ❌ Can't work on different branches per project
- ❌ Data directory shared across projects

### After (Isolated Worktrees)
```
~/.amp/
├── main/                     # Main repo (worktree parent)
│   └── .venv/                # Main environment
└── w/                        # Workspace worktrees
    ├── Users-ken-project-1/  # Project 1's isolated workspace
    │   ├── .venv/            # ✅ Independent Python env
    │   ├── ai_working/       # ✅ Project-specific AI files
    │   ├── .data/            # ✅ Project-specific data
    │   └── amplifier/        # ✅ Can be on different branch
    └── Users-ken-project-2/  # Project 2's isolated workspace
        └── (same structure)   # ✅ Completely isolated
```

**Benefits:**
- ✅ Complete isolation per project
- ✅ No dependency conflicts
- ✅ Independent git branches
- ✅ Separate AI working directories
- ✅ Project-specific data storage

## Migration Options

### Option 1: Automatic Migration (Recommended)

The easiest way - reinstall with the latest version:

1. **Update amp scripts**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
   ```

2. **Reload your shell**:
   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

3. **Done!** Next time you run `amp` in any project:
   - A new isolated workspace will be created automatically
   - Your existing `~/.amp/main` becomes the worktree parent
   - All your work continues seamlessly

**What happens:**
- First `amp` run in a project creates `~/.amp/w/{workspace-name}/`
- Existing `~/.amp/main` remains and becomes the parent for worktrees
- Each project gets its own `.venv/`, `ai_working/`, and `.data/`
- No data loss - everything migrates automatically

### Option 2: Clean Install (Fresh Start)

For the cleanest experience:

1. **Backup any important data** (if you have custom files in `~/.amp/main/`):
   ```bash
   cp -r ~/.amp/main/ai_working ~/backup-ai-working
   cp -r ~/.amp/main/.data ~/backup-data
   ```

2. **Uninstall old version**:
   ```bash
   amp uninstall --data
   ```

3. **Reinstall latest**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

4. **Restore backed up data** (if needed):
   ```bash
   # After first amp run creates workspace for your project
   cp -r ~/backup-ai-working ~/.amp/w/YOUR-WORKSPACE-NAME/ai_working
   cp -r ~/backup-data ~/.amp/w/YOUR-WORKSPACE-NAME/.data
   ```

## Frequently Asked Questions

### Do I need to do anything special?

**No!** Just run the install command:
```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
source ~/.zshrc  # or source ~/.bashrc
```
Then run `amp` in your project directory. Everything else is automatic.

### Will my existing work be preserved?

**Yes!** The migration is designed to be non-destructive. Your existing `~/.amp/main` remains and becomes the parent for all workspace worktrees.

### What happens to my AI working files?

With automatic migration:
- Old `ai_working/` remains in `~/.amp/main/`
- Each project gets its own new `ai_working/` in its workspace
- You can manually copy files if needed:
  ```bash
  cp -r ~/.amp/main/ai_working/* ~/.amp/w/YOUR-WORKSPACE/ai_working/
  ```

### Can I use different Python versions per project?

**Yes!** Each workspace has its own `.venv/`. After creating a workspace, you can:

```bash
cd ~/.amp/w/YOUR-WORKSPACE
rm -rf .venv
uv venv --python 3.11  # or any version you want
make install
```

### How do I see all my workspaces?

```bash
amp workspace list
```

This shows all workspaces with their project paths and current branches.

### Can I work on different branches per project?

**Yes!** Each workspace is an independent git worktree:

```bash
# In project 1
cd /path/to/project-1
amp workspace info  # Shows: branch 'feature-a'

# In project 2
cd /path/to/project-2
amp workspace info  # Shows: branch 'main'
```

Each workspace can be on a different branch independently!

### What if I delete a project directory?

Run `amp workspace prune` to clean up orphaned workspaces:

```bash
amp workspace prune
```

This finds workspaces whose project directories no longer exist and offers to remove them.

### Can I manually remove a workspace?

**Yes!**

Interactive:
```bash
amp workspace remove
```

By path:
```bash
amp workspace remove /path/to/project
```

Or directly:
```bash
rm -rf ~/.amp/w/WORKSPACE-NAME
```

### How much disk space does this use?

Each workspace uses approximately:
- `.venv/`: ~200-500 MB (Python dependencies)
- `ai_working/`: Varies based on your work
- `.data/`: Varies based on your data
- Git worktree metadata: <1 MB

If you have 10 projects, expect ~2-5 GB total (but with complete isolation!).

### Can I share dependencies between workspaces?

Not directly, but you can:

1. **Use the main repo's venv** (not recommended):
   ```bash
   cd ~/.amp/w/YOUR-WORKSPACE
   rm -rf .venv
   ln -s ../../main/.venv .venv
   ```

2. **Better approach**: Use `uv` lockfiles to ensure consistent versions:
   ```bash
   # In ~/.amp/main
   uv lock

   # In workspaces, use the same lockfile
   cp ~/.amp/main/uv.lock ~/.amp/w/WORKSPACE/
   cd ~/.amp/w/WORKSPACE
   make install
   ```

### What if something goes wrong?

1. **Check the log**:
   ```bash
   tail -f ~/.amp/.amp.log
   ```

2. **List workspaces**:
   ```bash
   amp workspace list
   ```

3. **Force recreate a workspace**:
   ```bash
   amp workspace remove /path/to/project
   cd /path/to/project
   amp  # Creates fresh workspace
   ```

4. **Complete reinstall**:
   ```bash
   amp uninstall --data
   curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
   ```

## New Commands Reference

### `amp workspace`

Manage workspace worktrees:

```bash
# List all workspaces
amp workspace list

# Show current workspace info
amp workspace info

# Show specific workspace info
amp workspace info /path/to/project

# Remove a workspace (interactive)
amp workspace remove

# Remove specific workspace
amp workspace remove /path/to/project

# Clean up orphaned workspaces
amp workspace prune
```

### `amp new`

Create new Amplifier projects:

```bash
# Initialize current directory
amp new

# Create new project directory
amp new my-project

# Creates:
# - CLAUDE.md with guidance
# - Git repository
# - Offers GitHub repo creation
```

### `amp update`

Comprehensive update:

```bash
amp update

# Updates:
# - Amplifier repository
# - Dependencies (if needed)
# - Amp scripts
# - Workspace settings
# - Plugin marketplaces
```

### `amp uninstall`

Clean uninstall:

```bash
# Remove amp (keeps workspace data)
amp uninstall

# Remove amp AND all workspace data
amp uninstall --data

# See all options
amp uninstall --help
```

## Troubleshooting Migration

### "Virtual environment not found in worktree"

The workspace creation may have failed. Recreate it:

```bash
rm -rf ~/.amp/w/WORKSPACE-NAME
cd /path/to/project
amp  # Creates fresh workspace
```

### "Failed to create worktree"

Check if you have local changes in `~/.amp/main`:

```bash
cd ~/.amp/main
git status
git stash  # Save local changes
cd /path/to/project
amp  # Try again
```

### Workspaces using too much disk space

Remove unused workspaces:

```bash
amp workspace list
amp workspace remove /path/to/unused-project
```

Or clean up orphaned workspaces:

```bash
amp workspace prune
```

### Want to consolidate workspaces

If you have multiple projects that should share an environment:

```bash
# Option 1: Use one workspace for multiple projects
cd /path/to/project-1
amp  # Creates workspace
cd /path/to/project-2
# Manually use project-1's workspace (advanced)

# Option 2: Use symlinks (not recommended)
cd ~/.amp/w/
ln -s existing-workspace new-workspace-name
```

## Getting Help

If you encounter issues:

1. **Check the log**: `tail -f ~/.amp/.amp.log`
2. **Check workspace status**: `amp workspace info`
3. **Try clean reinstall**: See "Option 2: Clean Install" above
4. **Open an issue**: [amplifier-setup issues](https://github.com/kenotron-ms/amplifier-setup/issues)

## Summary

**For most users**: Just run the install command and continue working normally. The migration happens automatically!
```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
source ~/.zshrc  # or source ~/.bashrc
```

**For a fresh start**: Use `amp uninstall --data` then reinstall from scratch.

**New benefits you'll see**:
- ✅ No more dependency conflicts
- ✅ Independent AI working directories
- ✅ Work on different branches per project
- ✅ Complete isolation and peace of mind

Enjoy your new isolated workspaces! 🎉

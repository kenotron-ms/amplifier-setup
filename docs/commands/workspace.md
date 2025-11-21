# amp workspace

Manage workspace worktrees for different projects.

## What are Workspaces?

Each project directory gets its own isolated amplifier worktree in `~/.amp/w/`. This provides complete isolation of:
- Python dependencies (.venv)
- AI working files (ai_working/)
- Data files (.data/)
- Git branches (can be on different branches)

## Commands

### List Workspaces

Show all workspace worktrees:

```bash
amp workspace list
```

Example output:
```
Workspace worktrees in ~/.amp/w:

1. Users-ken-projects-myapp
   → /Users/ken/projects/myapp
   Branch: main

2. Users-ken-workspace-amplifier-setup
   → /Users/ken/workspace/amplifier-setup
   Branch: feature/docs
```

### Show Current Workspace

Display information about the workspace for your current directory:

```bash
amp workspace info
```

Example output:
```
Current workspace:
  Worktree: /Users/ken/.amp/w/Users-ken-projects-myapp
  Project:  /Users/ken/projects/myapp
  Branch:   main
  Python:   /Users/ken/.amp/w/Users-ken-projects-myapp/.venv/bin/python3
```

### Remove Workspace

Remove a workspace worktree:

```bash
# Remove workspace for current directory
amp workspace remove

# Remove workspace for specific directory
amp workspace remove /path/to/project
```

?> **Note:** This only removes the worktree in `~/.amp/w/`, not your actual project files.

### Prune Orphaned Workspaces

Clean up workspaces whose project directories no longer exist:

```bash
amp workspace prune
```

Example output:
```
🔍 Scanning for orphaned workspaces...

Found 2 orphaned workspace(s):

  • Users-ken-old-project (1.2G)
  • Users-ken-deleted-app (856M)

Remove these orphaned workspaces? [y/N]: y

🗑️  Removing Users-ken-old-project...
🗑️  Removing Users-ken-deleted-app...

✅ Removed 2 orphaned workspace(s)
```

This is useful when you've deleted project directories and want to reclaim disk space.

## Workspace Structure

```
~/.amp/w/Users-ken-projects-myapp/
├── .git                 # Git worktree metadata
├── .venv/               # Isolated Python environment
├── ai_working/          # Project-specific AI work
├── .data/               # Project-specific data
├── amplifier/           # Amplifier modules
└── Makefile             # Full amplifier functionality
```

## Benefits

- **Isolation** - Each project has its own dependencies
- **No conflicts** - Different projects can use different amplifier versions
- **Clean** - Project directories stay clean (amp files in ~/.amp/)
- **Fast switching** - Jump between projects without environment setup

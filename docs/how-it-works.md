# How It Works

## Workspace Pattern

When you run `amp` from any directory, it automatically provides Claude Code with workspace context via `--append-system-prompt`:

```
I'm working on the {project-name} project.
The project is located at {current-directory}.
The {worktree-path} directory is the amplifier dev environment for this workspace.

Please read @{current-directory}/CLAUDE.md for project-specific guidance.

Whenever we execute any tools, we should assume {current-directory} is the root directory.
```

This tells Claude Code:
- What project you're working on
- Where the project is located
- Where the amplifier dev environment is (separate from your project)
- To look for `CLAUDE.md` for project-specific instructions
- To use your current directory as the working directory

## File Structure

```
~/.amp/                          # State directory
├── amp.sh                       # The amp command
├── amp-workspace.sh             # Workspace management
├── uninstall.sh                 # Uninstall script
├── .amp_ready                   # Flag: bootstrap completed
├── .amp_last_check              # Timestamp of last update check
├── .amp.log                     # Operation log
└── w/                           # Workspace worktrees
    ├── Users-ken-projects-foo/  # Worktree for /Users/ken/projects/foo
    │   ├── .git                 # Git worktree metadata
    │   ├── .venv/               # Isolated Python environment
    │   ├── ai_working/          # Project-specific AI work
    │   ├── .data/               # Project-specific data
    │   ├── amplifier/           # Amplifier modules
    │   └── Makefile             # Full amplifier functionality
    └── Users-ken-workspace-bar/ # Worktree for /Users/ken/workspace/bar
        └── (same structure)

~/.amp/main/                     # Main amplifier repository (git worktree parent)
├── .venv/                       # Main virtual environment
├── Makefile                     # Build system
└── amplifier/                   # Amplifier modules
```

**Key Concept:** Each project directory gets its own isolated amplifier worktree in `~/.amp/w/`.

## First Run

On your first `amp` command, it will automatically:

1. **Check prerequisites** - Verifies git, make, python3, uv, claude are installed
2. **Clone amplifier** - Downloads repository to `~/.amp/main`
3. **Install dependencies** - Runs `make install` (~2-5 minutes)
4. **Create worktree** - Creates isolated workspace for your project
5. **Launch Claude** - Starts Claude Code with proper context

## Subsequent Runs

After the first run:

1. **Check for updates** - Once per 24 hours
2. **Update if needed** - Pulls changes, reinstalls dependencies (only if dependency files changed)
3. **Launch Claude** - Activates venv and starts Claude Code

This is typically instant (no update needed) or very fast (update without reinstall).

## Update Intelligence

amp only runs `make install` when these files change:
- `pyproject.toml` - Python dependencies
- `uv.lock` - Locked dependency versions
- `Makefile` - Build instructions

For other changes (docs, code), it skips the reinstall, saving 2-5 minutes.

## Environment Variables

### AMP_HOME

Override state directory (default: `~/.amp`):

```bash
export AMP_HOME="$HOME/.my-amp"
amp
```

### AMP_AMPLIFIER_DIR

Override amplifier clone location (default: `~/.amp/main`):

```bash
export AMP_AMPLIFIER_DIR="$HOME/.my-amp/main"
amp
```

## Logging

All operations are logged to `~/.amp/.amp.log`:

```bash
tail -f ~/.amp/.amp.log
```

This is useful for troubleshooting if something goes wrong.

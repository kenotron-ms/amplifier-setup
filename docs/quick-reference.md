# Quick Reference Guide

Essential commands and workflows for using `amp`.

## Installation

### Fresh Install
```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
source ~/.zshrc  # or source ~/.bashrc
```

### Update Existing Installation
```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
source ~/.zshrc  # or source ~/.bashrc
```

## Basic Usage

### Start Claude Code
```bash
cd ~/your-project
amp
```

### Run with Prompt
```bash
amp "implement feature X"
```

### Pass Claude Arguments
```bash
amp --model opus
amp --help
amp "analyze code" --add-dir ../other-project
```

## Project Management

### Create New Project
```bash
# Initialize current directory
amp new

# Create new project directory
amp new my-project
```

**Creates:**
- CLAUDE.md with Flow-Driven Development guidance
- Git repository
- Offers GitHub repo creation (requires `gh` CLI)

## Workspace Management

### List All Workspaces
```bash
amp workspace list
```
Shows all workspace worktrees with project paths and branches.

### Show Workspace Info
```bash
# Current workspace
amp workspace info

# Specific workspace
amp workspace info /path/to/project
```

### Remove Workspace
```bash
# Interactive (prompts for selection)
amp workspace remove

# Specific workspace
amp workspace remove /path/to/project
```

### Clean Up Orphaned Workspaces
```bash
amp workspace prune
```
Removes workspaces whose project directories no longer exist.

## Maintenance

### Update Everything
```bash
# Reinstall to get latest
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
source ~/.zshrc  # or source ~/.bashrc
```

Updates:
- Amplifier repository
- Dependencies (if needed)
- Amp scripts
- Workspace settings
- Plugin marketplaces

### Uninstall
```bash
# Keep workspace data
amp uninstall

# Remove everything
amp uninstall --data

# See options
amp uninstall --help
```

## Troubleshooting

### Check Log
```bash
tail -f ~/.amp/.amp.log
```

### Force Reinstall
```bash
rm ~/.amp/.amp_ready
amp  # Triggers full bootstrap
```

### Complete Reset
```bash
rm -rf ~/.amp
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
```

### Workspace Issues
```bash
# Check workspace status
amp workspace info

# Recreate workspace
amp workspace remove /path/to/project
cd /path/to/project
amp  # Creates fresh workspace
```

## File Locations

```
~/.amp/                          # State directory
├── amp.sh                       # Main command
├── amp-workspace.sh             # Workspace management
├── install.sh                   # Installer
├── uninstall.sh                 # Uninstaller
├── .amp_ready                   # Bootstrap completion flag
├── .amp_last_check              # Update check timestamp
├── .amp.log                     # Operation log
├── main/                        # Main amplifier repo
│   └── .venv/                   # Main Python environment
└── w/                           # Workspace worktrees
    ├── Users-ken-project-1/     # Isolated workspace
    │   ├── .venv/               # Independent Python env
    │   ├── ai_working/          # Project-specific AI files
    │   ├── .data/               # Project-specific data
    │   └── amplifier/           # Amplifier modules
    └── Users-ken-project-2/     # Another isolated workspace
```

## Environment Variables

```bash
# Override state directory (default: ~/.amp)
export AMP_HOME="$HOME/.my-amp"

# Override amplifier location (default: ~/.amp/main)
export AMP_AMPLIFIER_DIR="$HOME/.my-amp/main"
```

## Common Patterns

### Multiple Projects
```bash
# Each project gets its own isolated workspace
cd ~/project-1
amp  # Works in project-1's workspace

cd ~/project-2
amp  # Works in project-2's workspace (completely isolated)
```

### Different Branches per Project
```bash
# Project 1 on feature branch
cd ~/project-1
amp workspace info  # Shows: branch 'feature-a'

# Project 2 on main
cd ~/project-2
amp workspace info  # Shows: branch 'main'
```

### Custom Python Version per Workspace
```bash
cd ~/.amp/w/YOUR-WORKSPACE
rm -rf .venv
uv venv --python 3.11
make install
```

## Tips

1. **Always reload shell after install/update**:
   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

2. **Check logs when things go wrong**:
   ```bash
   tail -f ~/.amp/.amp.log
   ```

3. **Use workspace commands to manage isolation**:
   ```bash
   amp workspace list  # See all workspaces
   amp workspace prune  # Clean up orphaned ones
   ```

4. **Each workspace is independent**:
   - Own Python environment
   - Own AI working files
   - Own data directory
   - Own git branch

5. **Force updates when needed**:
   ```bash
   rm ~/.amp/.amp_ready
   amp  # Forces full bootstrap
   ```

## Quick Commands Cheat Sheet

| Task | Command |
|------|---------|
| Install | `curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh \| bash` |
| Start Claude | `amp` |
| New project | `amp new [name]` |
| List workspaces | `amp workspace list` |
| Workspace info | `amp workspace info` |
| Remove workspace | `amp workspace remove` |
| Clean orphans | `amp workspace prune` |
| Uninstall | `amp uninstall [--data]` |
| Check log | `tail -f ~/.amp/.amp.log` |
| Force reinstall | `rm ~/.amp/.amp_ready && amp` |

## Getting Help

- **Documentation**: [README.md](README.md)
- **Migration**: [MIGRATION.md](MIGRATION.md)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)
- **Issues**: [GitHub Issues](https://github.com/kenotron-ms/amplifier-setup/issues)
- **Amplifier**: [microsoft/amplifier](https://github.com/microsoft/amplifier)
- **Claude Code**: [Anthropic Docs](https://docs.anthropic.com/en/docs/claude-code)

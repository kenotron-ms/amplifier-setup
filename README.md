# Amplifier Setup (`amp`)

**A transparent wrapper for Claude Code that automatically manages the [Amplifier](https://github.com/microsoft/amplifier) development environment.**

## ✨ What's New (December 2025)

**Complete workspace isolation with git worktrees!** Each project now gets its own isolated environment:
- 🔒 **Isolated Python environments** - No more dependency conflicts between projects
- 🌳 **Git worktree-based** - Work on different branches per project independently
- 📁 **Separate AI working directories** - Each project has its own `ai_working/` and `.data/`
- 🚀 **New commands**: `amp workspace`, `amp new`, `amp update`, `amp uninstall`
- 🔌 **Claude Code plugins** - Git workflow helpers (`/pull`, `/submit-pr`) with more coming

[See full changelog →](CHANGELOG.md)

---

## Quick Start

### One-Time Installation

#### Windows

**Step 1: Install** (PowerShell or Command Prompt)

```powershell
irm https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.ps1 | iex
```

**Step 2: Reload your shell**

- **PowerShell**: `. $PROFILE`
- **CMD**: Close and reopen Command Prompt

**Step 3: Done!**

Installation complete. Works in PowerShell, pwsh, and CMD.

---

#### Mac / Linux

**Step 1: Install**

```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
```

**Step 2: Reload your shell**

```bash
source ~/.${SHELL##*/}rc
```

**Step 3: Done!**

Installation complete. You only need to do this once.

---

### Everyday Use

Every time you want to work with Claude Code + Amplifier:

```bash
cd ~/your-project
amp
```

**That's it!** Use `amp` exactly like you would use `claude`:

```bash
amp "implement feature X"
amp --model opus
amp --help
```

---

## What is `amp`?

`amp` is a command that you use **exactly like `claude`**, but with all the amplifier complexity handled automatically behind the scenes.

### The Problem

Setting up and maintaining the amplifier environment involves many manual steps:
- Cloning the amplifier repository
- Running `make install` after every clone/update
- Activating the virtual environment
- Providing workspace context to Claude Code
- Managing updates

This creates friction, especially for non-technical users.

### The Solution

`amp` is a **direct replacement for the `claude` command** that:
- ✅ Installs amplifier automatically on first run
- ✅ Updates amplifier daily (when needed)
- ✅ Activates the virtual environment automatically
- ✅ Provides proper workspace context to Claude Code
- ✅ Passes through all `claude` arguments transparently

**You just type `amp` instead of `claude` - that's it.**

---

## Detailed Installation

### Prerequisites

The installer automatically installs all prerequisites:

**Windows:**
- **Windows 10 1809+ or Windows 11** (for winget package manager)
- **PowerShell** or **Command Prompt**

**Mac:**
- **Homebrew** (installed automatically if missing)

**Linux:**
- **Python 3.11+** (install manually: `sudo apt install python3` or equivalent)
- **Git** (install manually: `sudo apt install git` or equivalent)

**The installer automatically installs:**
- ✅ Python 3.12 (if not present)
- ✅ Git (if not present - Windows/Mac only)
- ✅ uv (Python package manager)
- ✅ **Claude Code** (using native binary installer - no Node.js required)

### Installation Options

#### Windows

**PowerShell or Command Prompt:**

```powershell
irm https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.ps1 | iex
```

#### Mac / Linux

**Terminal:**

```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
```

This will:
1. Download latest `amp.sh` and `amp-workspace.sh` to `~/.amp/`
2. Add it to your `~/.bashrc` and `~/.zshrc`
3. Make it available immediately in your current shell

**That's it!** After installation completes, just type `amp` to get started.

**Note**: This installer is idempotent - run it anytime to get the latest version of amp scripts.

**Note**: The installer will tell you exactly what to run after it completes.

## Usage

### Basic Usage

Use `amp` exactly like you would use `claude`:

```bash
# Start Claude Code in current directory (creates workspace worktree if needed)
amp

# Run with a prompt
amp "implement feature X"

# Pass any claude arguments
amp --help
amp --model opus
amp "analyze this code" --add-dir ../other-project
```

### Creating New Projects

```bash
# Initialize current directory as an Amplifier project
amp new

# Create a new project directory
amp new my-project

# Creates:
# - CLAUDE.md with Flow-Driven Development guidance
# - Git repository (if git is available)
# - Offers to create GitHub repo (if gh CLI is available)
```

### Workspace Management

```bash
# List all workspace worktrees
amp workspace list

# Show info about current workspace
amp workspace info

# Remove a workspace worktree
amp workspace remove
amp workspace remove /path/to/project

# Clean up orphaned workspaces (project directories deleted)
amp workspace prune
```

### Update

```bash
# Update everything (amplifier + amp scripts)
amp update

# Then reload your shell to use updated scripts
source ~/.zshrc  # or source ~/.bashrc
```

### Uninstall

```bash
# Remove amp (keeps workspace data)
amp uninstall

# Remove amp and all workspace data
amp uninstall --data

# View uninstall options
amp uninstall --help
```

### First Run

On your first `amp` command, it will automatically:
1. Check that prerequisites are installed
2. Clone the amplifier repository to `~/.amp/main`
3. Run `make install` to set up dependencies
4. Create a workspace worktree for your current directory
5. Launch Claude Code with proper workspace context

This takes about 2-5 minutes depending on your network speed.

### Subsequent Runs

After the first run, `amp` is fast:
- Checks for updates once per 24 hours
- If updates are available, pulls and reinstalls automatically
- Otherwise, launches immediately

## How It Works

### Workspace Pattern

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

### File Structure

```
~/.amp/                          # State directory
├── amp.sh                       # The amp command (installed by install.sh)
├── amp-workspace.sh             # Workspace worktree management
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

**Key Concept**: Each project directory gets its own isolated amplifier worktree in `~/.amp/w/`. This provides complete isolation of:
- Python dependencies (.venv)
- AI working files (ai_working/)
- Data files (.data/)
- Git branches (can be on different branches)

The main amplifier repository at `~/.amp/main` serves as the parent for all workspace worktrees.

## Configuration

### Environment Variables

- `AMP_HOME` - Override state directory (default: `~/.amp`)
- `AMP_AMPLIFIER_DIR` - Override amplifier clone location (default: `~/.amp/main`)

Example:
```bash
export AMP_HOME="$HOME/.my-amp"
export AMP_AMPLIFIER_DIR="$HOME/.my-amp/main"
amp
```

### Update Frequency

By default, `amp` checks for updates once per 24 hours. To force an update check:

```bash
rm ~/.amp/.amp_last_check
amp
```

## Troubleshooting

### Check the Log

If something goes wrong, check the log:

```bash
tail -f ~/.amp/.amp.log
```

### Force Reinstall

If the amplifier installation is corrupted:

```bash
rm ~/.amp/.amp_ready
amp  # Will trigger full bootstrap
```

### Complete Reinstall

To start from scratch:

```bash
rm -rf ~/.amp
amp  # Will re-clone and install everything
```

### Common Issues

#### "Missing required tools"

Install the missing prerequisites:
- **git**: https://git-scm.com/downloads
- **make**: `xcode-select --install` (macOS) or via package manager (Linux)
- **python3**: https://www.python.org/downloads/
- **uv**: https://docs.astral.sh/uv/getting-started/installation/
- **claude**: https://docs.anthropic.com/en/docs/claude-code/install

#### "Virtual environment not found"

The installation may have been interrupted:

```bash
rm ~/.amp/.amp_ready
amp  # Will retry installation
```

#### "Failed to pull updates"

Network issue or local changes in amplifier repo:

```bash
cd ~/.amp/main
git status  # Check for local changes
git reset --hard origin/main  # Reset to clean state
```

## Uninstall

```bash
# Remove amp from shell configuration (keeps workspace data)
amp uninstall

# Remove amp AND all workspace data
amp uninstall --data

# View all options
amp uninstall --help
```

## Platform Support

- ✅ **macOS** (bash & zsh)
- ✅ **Linux** (bash & zsh)
- ⏸️ **Windows** (not yet supported)

## Documentation

- **[Quick Reference](QUICK_REFERENCE.md)** - Essential commands and workflows
- **[Plugins](docs/plugins.md)** - Claude Code plugins and extensions
- **[Migration Guide](MIGRATION.md)** - Upgrading from pre-worktree versions
- **[Changelog](CHANGELOG.md)** - Complete history of changes
- **[Amplifier Docs](https://github.com/microsoft/amplifier)** - Amplifier development environment
- **[Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)** - Claude Code documentation

## Contributing

See the [amplifier-setup repository](https://github.com/kenotron-ms/amplifier-setup) for contribution guidelines.

## License

This project is licensed under the MIT License.

## Related Projects

- [Amplifier](https://github.com/microsoft/amplifier) - The underlying development environment
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) - Anthropic's AI coding assistant

---

**Made with ❤️ to simplify amplifier setup**

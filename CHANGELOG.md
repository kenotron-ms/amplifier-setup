# Changelog

All notable changes to amplifier-setup (`amp`) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Full PR lifecycle automation in `/submit-pr`**: The git plugin now automates the complete pull request workflow from start to finish
  - **Auto-branch creation**: Automatically creates a feature branch when you're on main/master, so you never accidentally commit to your base branch
  - **Real-time PR monitoring**: Watches your PR's CI/CD checks and approval status, showing live updates as they happen
  - **Auto-merge on approval**: When your PR is approved and all checks pass, it automatically merges and cleans up branches for you
  - Complete hands-off workflow: Create branch → Commit → Ensure compliance → Monitor checks → Merge → Cleanup

### Changed

- **Enhanced merge conflict resolution in `/submit-pr`**: Improved Step 3 to include intelligent merge conflict handling before PR submission
  - Automatically fetches and merges latest changes from base branch (main/master)
  - Performs deep conflict analysis by examining commit history and intent from both branches
  - Distinguishes between simple conflicts (auto-resolvable) and complex conflicts (requires human review)
  - For simple conflicts: automatically resolves and commits with detailed reasoning
  - For complex conflicts: provides comprehensive analysis with context from both branches, possible resolutions, and recommendations
  - Downloads and analyzes CI artifacts before theorizing about failures to ensure evidence-based resolution
  - Returns to monitoring loop after fixes (up to 3 attempts) for autonomous fix-verify-merge workflow

### Fixed

- **Duplicate context prompt on session resume**: Fixed issue where resuming a Claude Code session with `-r`/`--resume` or `-c`/`--continue` would send the workspace context prompt again, causing confusion and unnecessary context duplication. The `amp` command now detects resume flags and skips the initial prompt, allowing Claude to restore its own context cleanly.
- **CLI arguments not passed through to Claude Code**: Fixed issue in `amp.sh` where additional command-line arguments (like session resume flags) were not being forwarded to the Claude CLI. Added `"$@"` to properly pass all arguments through, restoring session resume and other CLI features that rely on additional arguments.
- **Development workflow improvements in `reload-amp.sh`**:
  - Now clears Claude Code shell snapshot cache to ensure updated scripts are used in active sessions
  - Added `--keep-cache` flag to optionally skip cache clearing
  - Improved help messages and user feedback when running in active Claude sessions
  - Better argument parsing with support for multiple flags
- **Claude not reading project CLAUDE.md files**: Fixed issue where the `amp` command's system prompt wasn't properly instructing Claude Code to read the project's CLAUDE.md guidance file. The instruction is now more explicit, ensuring Claude always reads and follows project-specific instructions from your CLAUDE.md file.
- **Workspace creation failure in new directories**: Fixed issue where `amp` would fail with "Failed to create/access workspace worktree" when run in a blank folder. The marketplace configuration output was contaminating stdout, causing the directory check to fail. Output is now correctly redirected to stderr.

### Added - 2025-12-04

#### Git Plugin Enhancements
- **Automatic documentation compliance in `/submit-pr`**: Command now automatically discovers and enforces repository documentation standards
  - Discovers standards from `CONTRIBUTING.md`, `MAINTENANCE.md`, `CLAUDE.md`
  - Automatically updates required documentation based on code changes
  - Runs pre-PR checks (linting, testing, type checking)
  - Blocks PR submission if compliance fails
  - Uses general-purpose agent (or specialized `docs-compliance-agent` if available)
  - Creates compliance commit automatically when updates are made
  - Provides detailed compliance report with status of each requirement

### Added - 2025-12-02

#### Worktree-based Workspace System
- **Complete isolation per project**: Each project directory gets its own git worktree at `~/.amp/w/{workspace-name}/`
- **Isolated Python environments**: Each workspace has its own `.venv/` with independent dependencies
- **Isolated AI working directories**: Each workspace has its own `ai_working/` and `.data/` directories
- **Isolated git branches**: Each workspace can be on a different branch independently
- **Automatic worktree creation**: First `amp` run in a directory creates a dedicated worktree
- **Automatic marketplace configuration**: VSCode settings and plugin marketplace configured per workspace
- **Clean separation**: Main amplifier repo at `~/.amp/main` serves as parent for all worktrees

#### Workspace Management Commands
- `amp workspace list` - List all workspace worktrees with project paths and branches
- `amp workspace info` - Show detailed info about current workspace (or any workspace by path)
- `amp workspace remove` - Remove a workspace worktree (interactive or by path)
- `amp workspace prune` - Clean up orphaned workspaces (project directories deleted)

#### Project Initialization
- `amp new [project-name]` - Create new Amplifier project with:
  - CLAUDE.md with Flow-Driven Development guidance
  - Git repository initialization
  - GitHub repository creation (optional, requires `gh` CLI)
  - Initial commit and push to GitHub
- `amp new` (no args) - Initialize current directory as Amplifier project

#### Update System
- `amp update` - Comprehensive update command that:
  - Updates amplifier repository (git fetch + pull)
  - Reinstalls dependencies if pyproject.toml/uv.lock/Makefile changed
  - Updates amp scripts (amp.sh, amp-workspace.sh)
  - Updates workspace settings (marketplace config)
  - Updates plugin marketplaces via Claude CLI
- Smart dependency detection: Only reinstalls when dependency files change
- Clear update output with version SHAs
- Automatic shell reload instructions

#### Uninstall System
- `amp uninstall` - Remove amp from shell config (keeps workspace data)
- `amp uninstall --data` - Remove amp AND all workspace data
- `amp uninstall --help` - Show all uninstall options
- Interactive confirmation for data removal
- Clean removal of shell RC modifications
- Complete cleanup of ~/.amp directory

#### Installation Improvements
- **Idempotent installer**: `install.sh` can be run multiple times safely
- **Local development mode**: Detects local repository and uses local scripts
- **Multiple script management**: Downloads and installs:
  - `amp.sh` (main command)
  - `amp-workspace.sh` (workspace management)
  - `install.sh` (installer itself)
  - `uninstall.sh` (uninstaller)
- **Update mode**: `install.sh --update` for script-only updates (no shell RC modifications)
- **Improved error messages**: Clear, actionable error messages with suggestions
- **Shell detection**: Automatically detects bash vs zsh
- **Cleanup of old references**: Removes outdated `.amplifier` references automatically

### Changed - 2025-12-02

#### Workspace Context
- **Enhanced system prompt**: Workspace context now includes:
  - Project name
  - Project directory (user's actual project)
  - Worktree directory (amplifier dev environment)
  - Instruction to read project's CLAUDE.md
  - Working directory guidance
- **Automatic directory addition**: Project directory automatically added with `--add-dir`
- **Separated concerns**: Clear distinction between project files and amplifier environment

#### Bootstrap Process
- **Smarter installation**: Only reinstalls dependencies when needed
- **Update-on-bootstrap**: Automatically updates to latest on first run
- **Cleaner output**: Better progress messages and status indicators
- **Proper cleanup**: Removes `.amp_ready` flag when updating scripts

#### File Structure
- **Reorganized state directory**:
  ```
  ~/.amp/
  ├── amp.sh                    # Main command
  ├── amp-workspace.sh          # Workspace management
  ├── install.sh                # Installer
  ├── uninstall.sh              # Uninstaller
  ├── .amp_ready                # Bootstrap completion flag
  ├── .amp_last_check           # Update check timestamp
  ├── .amp.log                  # Operation log
  ├── main/                     # Main amplifier repo (worktree parent)
  └── w/                        # Workspace worktrees
      ├── Users-ken-project-1/  # Isolated workspace
      └── Users-ken-project-2/  # Another isolated workspace
  ```

#### Update Behavior
- **Daily checks**: Updates checked once per 24 hours automatically
- **Forced checks**: Can force update with `amp update` or by removing `.amp_last_check`
- **Dependency-aware**: Only reinstalls when dependency files actually changed
- **Git worktree-aware**: Properly handles main repo vs workspace worktrees

### Fixed - 2025-12-02

#### Workspace Isolation Issues
- Fixed shared state between different projects
- Fixed dependency conflicts when projects need different versions
- Fixed AI working files mixing between projects
- Fixed data directory conflicts

#### Installation Issues
- Fixed duplicate entries in shell RC files
- Fixed broken references to old `.amplifier` directory
- Fixed shell detection in post-create scripts
- Fixed pnpm configuration during DevContainer setup

#### Update Issues
- Fixed unnecessary reinstalls when no dependencies changed
- Fixed network check timing out update process
- Fixed missing marketplace configuration after updates
- Fixed plugin marketplace not updating

#### Shell Integration Issues
- Fixed SHELL environment variable not set in some contexts
- Fixed shell RC file detection
- Fixed source command for different shells
- Fixed reload instructions after updates

### Documentation

#### README.md
- Documented worktree-based workspace system
- Added workspace management commands
- Added project initialization workflow
- Added update and uninstall procedures
- Added file structure diagrams
- Added troubleshooting guide
- Added configuration options

#### CHANGELOG.md (this file)
- Created comprehensive changelog
- Documented all changes from 2024-12-02
- Organized by category (Added, Changed, Fixed)
- Included detailed descriptions and examples

### Technical Details

#### Architecture Changes
- Moved from single-directory to worktree-based architecture
- Implemented proper git worktree parent/child relationships
- Added workspace name normalization (path → identifier)
- Implemented automated marketplace configuration
- Added proper cleanup and pruning mechanisms

#### Code Quality
- Improved error handling throughout
- Added comprehensive logging
- Improved shell script robustness
- Better handling of edge cases
- Proper cleanup on failures

#### Dependencies
- No new dependencies added
- Better handling of existing dependencies (git, make, python3, uv, claude)
- Smarter dependency change detection

## [1.0.0] - Prior to 2025-12-02

### Initial Release
- Basic `amp` command as wrapper for `claude`
- Automatic amplifier clone and installation
- Virtual environment activation
- Basic update checking
- Simple workspace context

---

## Migration Guide

### For Existing Users

If you were using `amp` before 2025-12-02, here's how to migrate to the new worktree-based system:

1. **Update your installation**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

2. **Your existing setup will be migrated automatically**:
   - First `amp` run in each project will create a worktree
   - Old `~/.amp/main` becomes the worktree parent
   - Workspaces are created at `~/.amp/w/{workspace-name}/`

3. **Benefits you'll see immediately**:
   - Complete isolation between projects
   - Independent Python environments
   - Separate AI working directories
   - Can work on different branches per project

4. **No manual steps required**: Everything migrates automatically!

### Clean Install (Recommended)

For the cleanest experience with the new system:

1. **Uninstall old version**:
   ```bash
   amp uninstall --data  # Removes everything
   ```

2. **Reinstall**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

3. **Start fresh**: Each project gets its own clean workspace!

---

## Links

- [Repository](https://github.com/kenotron-ms/amplifier-setup)
- [Amplifier](https://github.com/microsoft/amplifier)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

# Amplifier Setup Tool - Vision

## Problem Statement

[Amplifier](https://github.com/microsoft/amplifier/tree/main) is a powerful development environment, but it's confusing to set up for users who aren't working on amplifier itself. Several pain points exist:

### Current Challenges

1. **Confusing Setup for External Projects**
   - Amplifier is a dev environment designed to develop other repos
   - Created before Claude Code plugins/marketplace existed
   - Not intuitive for users who want to use it with their own projects

2. **Complex Workspace Pattern**
   - The [Workspace Pattern](https://github.com/microsoft/amplifier/blob/main/docs/WORKSPACE_PATTERN.md) exists but involves many steps
   - Non-technical users struggle with the number of steps and concepts needed before being productive

3. **Repetitive Manual Setup Steps**
   - Every time we clone amplifier: need to run `make install`
   - Every time we update amplifier: need to run `make install` again
   - Every session: need to activate `.venv`
   - Every session: need to include workspace pattern text/instructions

4. **Barrier to Entry**
   - Too many prerequisites and concepts to understand
   - Manual, error-prone process
   - Discourages adoption by non-technical users

## Solution: The `amp` Command

Create a globally available command called `amp` that serves as a **complete replacement for `claude`**, but with all the amplifier complexity handled automatically.

### Design Principle

**`amp` should be what users type instead of `claude`**

Users shouldn't think "I need to use amplifier, so I'll run `amp`". They should think "I want to use Claude Code with my project" and type `amp` naturally, getting all the amplifier benefits transparently.

### Core Functionality

When a user runs `amp` from any directory, it should:

1. **Ensure Prerequisites**
   - Check if required tools are installed
   - Install or update as needed

2. **Manage Amplifier Installation**
   - Clone amplifier if not present
   - Update to latest main branch if already cloned
   - Run `make install` automatically when needed

3. **Handle Virtual Environment**
   - Activate the `.venv` automatically
   - No manual activation required

4. **Workspace-Aware Execution**
   - Use the current directory as the "workspace" folder
   - Launch Claude Code with appropriate context
   - Automatically include workspace pattern instructions

5. **Pass-Through Claude Arguments**
   - Accept all `claude` CLI arguments
   - Forward them to the underlying `claude` command
   - Users should be able to use `amp` exactly like they would use `claude`

### User Experience Goal

**Before (Current State):**
```bash
# User has to remember and execute:
cd ~/amplifier
git pull origin main
make install
source .venv/bin/activate
cd ~/my-project
claude --add-dir ~/my-project
# Then manually paste workspace pattern text
```

**After (With `amp`):**
```bash
# User simply runs (exactly like they would use claude):
cd ~/my-project
amp

# Or with any claude arguments:
amp --help
amp --model opus
amp "implement feature X"
amp --add-dir ../other-project

# Everything else happens automatically behind the scenes
```

### Mental Model

Users should think of `amp` as:
- **Not**: "A tool to manage amplifier"
- **But**: "An enhanced version of `claude` that just works better"

The fact that it uses amplifier under the hood should be an implementation detail, not something users need to understand or care about.

## Design Inspiration

The [post-create.sh script from workspaces2](https://github.com/microsoft/workspaces2/blob/main/.devcontainer/post-create.sh) provides excellent patterns for:

- Automated dependency installation
- Environment configuration
- Git repository management
- Shell function creation
- Helpful user feedback and status reporting
- Integration with tmux for session management

Key patterns to adopt:
- Idempotent operations (safe to run multiple times)
- Clear user feedback during setup
- Logging for troubleshooting
- Graceful handling of missing dependencies
- Smart defaults with escape hatches

## Success Criteria

The tool will be successful when:

1. **Transparent Replacement**
   - Users can type `amp` anywhere they would type `claude`
   - All `claude` CLI arguments work identically
   - No cognitive overhead to understand "amplifier mode" vs "normal mode"

2. **Zero-Friction Setup**
   - New users can go from "never used amplifier" to productive in < 5 minutes
   - No manual steps required
   - First run automatically sets up everything needed

3. **Intelligent Automation**
   - Detects when amplifier needs updating
   - Only runs expensive operations when necessary
   - Handles errors gracefully with helpful messages
   - Silent when everything is working (no unnecessary output)

4. **Context-Aware**
   - Understands current directory as workspace
   - Provides appropriate Claude Code initialization
   - Respects project-specific configurations (CLAUDE.md, etc.)

5. **Reliable**
   - Works consistently across different environments
   - Handles edge cases (no internet, partial installs, etc.)
   - Logs operations for debugging
   - Never breaks the user's flow

## Implementation Strategy

### Technology Choices

**Language/Tooling**: Pure bash/zsh scripting
- No additional runtime dependencies (Python, Node.js, etc.)
- Works out-of-the-box on target platforms
- Simple to distribute and install

**Target Platforms** (Initial Release):
- ✅ macOS (bash & zsh)
- ✅ Linux (bash & zsh)
- ⏸️ Windows (deferred until we have a good solution)

**Rationale**:
- Bash/zsh are native to Mac/Linux development environments
- Keeps dependencies minimal
- Easy to debug and maintain
- Fast execution
- Simple installation (just source a script)

### Distribution Approach

Install via a simple curl/wget command that:
1. Downloads the script
2. Adds it to `~/.bashrc` / `~/.zshrc`
3. Sources it immediately for current session

Example:
```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/amplifier-setup/main/install.sh | bash
```

### Testing Strategy (TBD)

- Manual testing on macOS (bash & zsh)
- Manual testing on Linux distributions
- Edge case handling (no git, no internet, partial installs)

## Future Enhancements (Ideas)

- Session management with tmux integration (like workspaces2)
- Multiple workspace support
- Configuration file for user preferences
- Plugin system for project-specific customizations
- Status command to show amplifier/workspace health

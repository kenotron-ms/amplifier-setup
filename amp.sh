#!/usr/bin/env bash
# amp.sh - Amplifier wrapper script
#
# Usage:
#   Source this file in your ~/.bashrc or ~/.zshrc:
#     source ~/.amplifier/amp.sh
#
#   Then run:
#     amp [claude-arguments...]
#
# This script:
# 1. Bootstraps the amplifier environment on first run (clone, install)
# 2. Checks for updates daily
# 3. Activates the virtual environment
# 4. Launches Claude Code with workspace context
#
# Environment:
#   AMP_HOME - State directory (default: ~/.amp)
#   AMP_AMPLIFIER_DIR - Amplifier clone directory (default: ~/.amp/main)
#
# State files:
#   $AMP_HOME/.amp_ready       - Marks bootstrap complete
#   $AMP_HOME/.amp_last_check  - Timestamp of last update check
#   $AMP_HOME/.amp.log         - Operation log

# Configuration
AMP_HOME="${AMP_HOME:-$HOME/.amp}"
AMP_AMPLIFIER_DIR="${AMP_AMPLIFIER_DIR:-$HOME/.amp/main}"
AMP_REPO="https://github.com/microsoft/amplifier.git"
UPDATE_CHECK_INTERVAL=$((24 * 3600))  # 24 hours in seconds

# State files
AMP_READY_FLAG="$AMP_HOME/.amp_ready"
AMP_LAST_CHECK="$AMP_HOME/.amp_last_check"
AMP_LOG="$AMP_HOME/.amp.log"

# ============================================================================
# Logging
# ============================================================================

_amp_log() {
    local message="$1"
    echo "[$(date -u +"%Y-%m-%d %H:%M:%S UTC")] $message" >> "$AMP_LOG"
}

# ============================================================================
# Error Handling
# ============================================================================

_amp_error() {
    local message="$1"
    local suggestion="${2:-}"

    echo "❌ Error: $message" >&2
    if [[ -n "$suggestion" ]]; then
        echo "💡 Suggestion: $suggestion" >&2
    fi

    _amp_log "ERROR: $message"
    return 1
}

# ============================================================================
# Prerequisite Checks
# ============================================================================

_amp_check_prereqs() {
    local missing=()

    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi

    if ! command -v make &> /dev/null; then
        missing+=("make")
    fi

    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi

    if ! command -v uv &> /dev/null; then
        missing+=("uv")
    fi

    if ! command -v claude &> /dev/null; then
        missing+=("claude")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        _amp_error "Missing required tools: ${missing[*]}" \
            "Install missing tools:\n  - git: https://git-scm.com/downloads\n  - make: Install via system package manager\n  - python3: https://www.python.org/downloads/\n  - uv: https://docs.astral.sh/uv/getting-started/installation/\n  - claude: https://docs.anthropic.com/en/docs/claude-code/install"
        return 1
    fi

    _amp_log "Prerequisites check passed"
}

# ============================================================================
# Clone
# ============================================================================

_amp_clone() {
    echo "📦 Cloning amplifier repository..."

    if ! git clone "$AMP_REPO" "$AMP_AMPLIFIER_DIR"; then
        _amp_error "Failed to clone repository" \
            "Check network connection and repository URL"
        return 1
    fi

    # Verify critical files exist
    if [[ ! -f "$AMP_AMPLIFIER_DIR/Makefile" ]]; then
        _amp_error "Cloned repository is incomplete or corrupted" \
            "Remove and retry: rm -rf $AMP_AMPLIFIER_DIR && amp"
        return 1
    fi

    _amp_log "Cloned repository to $AMP_AMPLIFIER_DIR"
    echo "✅ Repository cloned"
}

# ============================================================================
# Update
# ============================================================================

_amp_update() {
    local current_time
    current_time=$(date +%s)

    # Check if update check is needed
    if [[ -f "$AMP_LAST_CHECK" ]]; then
        local last_check
        last_check=$(cat "$AMP_LAST_CHECK")
        local time_diff=$((current_time - last_check))

        if [[ $time_diff -lt $UPDATE_CHECK_INTERVAL ]]; then
            # No update check needed yet
            return 0
        fi
    fi

    echo "🔄 Checking for updates..."

    # Use subshell to auto-restore directory
    (
        cd "$AMP_AMPLIFIER_DIR" || {
            _amp_error "Failed to change to amplifier directory" \
                "Check directory exists: $AMP_AMPLIFIER_DIR"
            exit 1
        }

        # Fetch latest changes
        if ! git fetch origin main --quiet 2>&1; then
            _amp_log "Warning: Failed to fetch updates"
            echo "$current_time" > "$AMP_LAST_CHECK"
            exit 0
        fi

        # Check if update is available
        local local_sha
        local remote_sha
        local_sha=$(git rev-parse HEAD)
        remote_sha=$(git rev-parse origin/main)

        if [[ "$local_sha" != "$remote_sha" ]]; then
            echo "📥 Updates available, pulling changes..."

            # Check if dependency files changed
            local needs_install=false
            local changed_files
            changed_files=$(git diff --name-only HEAD origin/main)

            if echo "$changed_files" | grep -qE "pyproject.toml|uv.lock|Makefile"; then
                needs_install=true
                _amp_log "Dependency files changed, will reinstall"
            else
                _amp_log "No dependency changes detected, skipping reinstall"
            fi

            if ! git pull origin main --quiet; then
                _amp_error "Failed to pull updates" \
                    "Try manually updating: cd $AMP_AMPLIFIER_DIR && git pull"
                exit 1
            fi

            _amp_log "Updated from $local_sha to $remote_sha"

            # Re-install only if dependency files changed
            if $needs_install; then
                echo "🔧 Reinstalling dependencies (dependency files changed)..."
                if ! make install >> "$AMP_LOG" 2>&1; then
                    _amp_error "Failed to reinstall after update" \
                        "Check log: $AMP_LOG"
                    exit 1
                fi
                echo "✅ Updated and reinstalled"
            else
                echo "✅ Updated (no reinstall needed)"
            fi
        fi

        # Update last check timestamp
        echo "$current_time" > "$AMP_LAST_CHECK"
        exit 0
    )
    return $?
}

# ============================================================================
# Install
# ============================================================================

_amp_install() {
    echo "🔧 Installing dependencies..."

    pushd "$AMP_AMPLIFIER_DIR" > /dev/null || {
        _amp_error "Failed to change to amplifier directory" \
            "Check directory exists: $AMP_AMPLIFIER_DIR"
        return 1
    }

    if ! make install >> "$AMP_LOG" 2>&1; then
        _amp_error "Installation failed" \
            "Check log for details: $AMP_LOG"
        popd > /dev/null
        return 1
    fi

    _amp_log "Installation completed"
    echo "✅ Dependencies installed"

    popd > /dev/null
}

# ============================================================================
# Bootstrap
# ============================================================================

_amp_bootstrap() {
    echo "🚀 Bootstrapping amplifier environment..."

    # Create log directory
    mkdir -p "$(dirname "$AMP_LOG")"

    _amp_log "Bootstrap started"

    # Check prerequisites
    _amp_check_prereqs || return 1

    # Clone repository if it doesn't exist, otherwise update it
    if [[ ! -d "$AMP_AMPLIFIER_DIR" ]]; then
        _amp_clone || return 1
    else
        echo "📦 Amplifier already exists, updating to latest..."
        _amp_log "Updating existing amplifier installation"

        pushd "$AMP_AMPLIFIER_DIR" > /dev/null || {
            _amp_error "Failed to change to amplifier directory" \
                "Check directory exists: $AMP_AMPLIFIER_DIR"
            return 1
        }

        echo "📥 Fetching latest changes..."
        if ! git fetch origin main; then
            echo "⚠️  Warning: Failed to fetch updates, using existing version"
            _amp_log "Warning: Failed to fetch during bootstrap"
            popd > /dev/null
        else
            local local_sha
            local remote_sha
            local needs_install=false
            local_sha=$(git rev-parse HEAD)
            remote_sha=$(git rev-parse origin/main)

            if [[ "$local_sha" != "$remote_sha" ]]; then
                echo "📥 Pulling latest changes..."

                # Check if dependency files will change
                local changed_files
                changed_files=$(git diff --name-only HEAD origin/main)
                if echo "$changed_files" | grep -qE "pyproject.toml|uv.lock|Makefile"; then
                    needs_install=true
                    _amp_log "Dependency files changed during bootstrap, will reinstall"
                fi

                if ! git pull origin main; then
                    echo "⚠️  Warning: Failed to pull updates, using existing version"
                    _amp_log "Warning: Failed to pull during bootstrap"
                else
                    echo "✅ Updated to latest"
                fi
            else
                echo "✅ Already up to date"
            fi

            popd > /dev/null
        fi
    fi

    # Install dependencies (always on fresh clone, or if dependencies changed)
    if [[ ! -f "$AMP_AMPLIFIER_DIR/.venv/bin/activate" ]] || ${needs_install:-true}; then
        _amp_install || return 1
    else
        echo "✅ Dependencies already installed"
        _amp_log "Skipping install - no dependency changes"
    fi

    # Mark as ready
    touch "$AMP_READY_FLAG"
    _amp_log "Bootstrap completed"

    echo "✅ Amplifier environment ready"
}

# ============================================================================
# Execution
# ============================================================================

_amp_execute() {
    # Check for updates (once per day)
    _amp_update

    # Source workspace functions (should be in same directory as amp.sh)
    local workspace_script="$AMP_HOME/amp-workspace.sh"
    if [[ -f "$workspace_script" ]]; then
        # shellcheck disable=SC1090
        source "$workspace_script"
    else
        _amp_error "Workspace script not found: $workspace_script" \
            "Reinstall amp: curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash"
        return 1
    fi

    # Get or create workspace worktree for current directory
    local worktree_path
    worktree_path="$(_amp_get_or_create_worktree)"

    if [[ -z "$worktree_path" ]] || [[ ! -d "$worktree_path" ]]; then
        _amp_error "Failed to create/access workspace worktree" \
            "Check log for details: $AMP_LOG"
        return 1
    fi

    # Activate virtual environment from the worktree
    local venv_activate="$worktree_path/.venv/bin/activate"
    if [[ ! -f "$venv_activate" ]]; then
        _amp_error "Virtual environment not found in worktree" \
            "Try running: cd $worktree_path && make install"
        return 1
    fi

    # shellcheck disable=SC1090
    source "$venv_activate"

    # Generate workspace system prompt
    local workspace_dir
    workspace_dir="$(pwd)"

    # Validate workspace directory
    if [[ ! -d "$workspace_dir" ]]; then
        _amp_error "Current directory does not exist" \
            "Run amp from a valid directory"
        return 1
    fi

    local project_name
    project_name="$(basename "$workspace_dir")"

    local workspace_system_prompt="I'm working on the $project_name project. The project is located at $workspace_dir. The $worktree_path directory is the amplifier dev environment for this workspace.

Please read @$workspace_dir/CLAUDE.md for project-specific guidance.

Whenever we execute any tools, we should assume $workspace_dir is the root directory."

    _amp_log "Launching claude from worktree $worktree_path with project dir $workspace_dir"

    # Change to worktree directory and launch claude with project directory added
    pushd "$worktree_path" > /dev/null || {
        _amp_error "Failed to change to worktree directory" \
            "Check worktree exists: $worktree_path"
        return 1
    }

    # Execute claude with workspace context as system prompt and add project directory
    claude --append-system-prompt "$workspace_system_prompt" --add-dir "$workspace_dir" "$@"

    # Return to original directory after claude exits
    popd > /dev/null
}

# ============================================================================
# Main Entry Point
# ============================================================================

amp() {
    # Handle subcommands
    case "${1:-}" in
        workspace)
            shift
            # Source workspace functions
            local workspace_script="$(dirname "${BASH_SOURCE[0]}")/amp-workspace.sh"
            if [[ -f "$workspace_script" ]]; then
                # shellcheck disable=SC1090
                source "$workspace_script"
                amp_workspace "$@"
            else
                echo "❌ Error: amp-workspace.sh not found"
                return 1
            fi
            return
            ;;
        update)
            # Force update of amplifier main repo
            echo "🔄 Forcing amplifier update..."
            rm -f "$AMP_LAST_CHECK"  # Force update check

            if [[ ! -d "$AMP_AMPLIFIER_DIR" ]]; then
                echo "❌ Error: Amplifier not installed yet"
                echo "💡 Run 'amp' first to bootstrap"
                return 1
            fi

            cd "$AMP_AMPLIFIER_DIR" || return 1

            echo "📥 Fetching latest changes..."
            if ! git fetch origin main; then
                echo "❌ Error: Failed to fetch updates"
                return 1
            fi

            local local_sha
            local remote_sha
            local_sha=$(git rev-parse HEAD)
            remote_sha=$(git rev-parse origin/main)

            if [[ "$local_sha" == "$remote_sha" ]]; then
                echo "✅ Already up to date"
                return 0
            fi

            # Check if dependency files changed
            echo "📋 Checking what changed..."
            local changed_files
            changed_files=$(git diff --name-only HEAD origin/main)
            local needs_install=false

            if echo "$changed_files" | grep -qE "pyproject.toml|uv.lock|Makefile"; then
                needs_install=true
                echo "   • Dependency files changed - will reinstall"
            else
                echo "   • No dependency changes - will skip reinstall"
            fi

            echo "📥 Pulling changes..."
            if ! git pull origin main; then
                echo "❌ Error: Failed to pull updates"
                echo "💡 Try: cd $AMP_AMPLIFIER_DIR && git status"
                return 1
            fi

            if $needs_install; then
                echo "🔧 Reinstalling dependencies..."
                if ! make install; then
                    echo "❌ Error: Installation failed"
                    return 1
                fi
                echo ""
                echo "✅ Amplifier updated and reinstalled successfully"
            else
                echo ""
                echo "✅ Amplifier updated successfully (no reinstall needed)"
            fi

            echo "   From: ${local_sha:0:7}"
            echo "   To:   ${remote_sha:0:7}"
            return 0
            ;;
        uninstall)
            # Delegate to uninstall.sh
            # Note: This script will remove amp itself
            local uninstall_script="$(dirname "${BASH_SOURCE[0]}")/uninstall.sh"
            if [[ -f "$uninstall_script" ]]; then
                shift  # Remove 'uninstall' from args
                "$uninstall_script" "$@"
            else
                echo "❌ Error: uninstall.sh not found"
                echo "💡 Try: curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/uninstall.sh | bash"
                return 1
            fi
            return
            ;;
        new)
            # Create a new Amplifier project
            shift  # Remove 'new' from args

            local project_path="${1:-.}"
            local target_dir
            local project_name

            # Resolve target directory and project name
            if [[ "$project_path" == "." ]]; then
                target_dir="$(pwd)"
                project_name="$(basename "$target_dir")"
                echo "🚀 Initializing Amplifier project: $project_name"
                echo "   Location: $target_dir"
            else
                target_dir="$(cd "$(dirname "$project_path")" 2>/dev/null && pwd)/$(basename "$project_path")"
                project_name="$(basename "$project_path")"
                echo "🚀 Creating new Amplifier project: $project_name"
                echo "   Location: $target_dir"

                # Create directory
                mkdir -p "$target_dir" || {
                    echo "❌ Error: Could not create directory: $target_dir"
                    return 1
                }
                echo "📁 Created directory"
            fi

            # Create CLAUDE.md
            local claude_md="$target_dir/CLAUDE.md"
            if [[ -f "$claude_md" ]]; then
                echo "📄 CLAUDE.md already exists, skipping"
            else
                cat > "$claude_md" << 'CLAUDE_MD_EOF'
# CLAUDE.md

Project-specific guidance for AI assistants working in this repository.

## Development Philosophy

This project follows Flow-Driven Development principles. See @ai_context/flow/FLOW_DRIVEN_DEVELOPMENT.md for the complete methodology.

### Key Principles

- **Flow state over rigid process** - Adapt tools to support deep work
- **Ultra-thinking for complex tasks** - Use `/ultrathink-task` for multi-step problems
- **Verification-driven development** - Validate assumptions continuously
- **Modular design** - Build in self-contained, regenerable pieces

### Workflow Commands

When working on complex features or debugging:

1. **Plan first**: Use `/ultrathink-task` to break down the problem
2. **Verify continuously**: Test assumptions as you build
3. **Document decisions**: Update this file with project-specific patterns

## Project-Specific Guidelines

Add your project's specific instructions here:

- Build command: [e.g., `make build`]
- Test command: [e.g., `make test`]
- Code style guidelines
- Important patterns

## Resources

- Flow-Driven Development: @ai_context/flow/FLOW_DRIVEN_DEVELOPMENT.md
- Amplifier: https://github.com/microsoft/amplifier
CLAUDE_MD_EOF
                echo "📄 Created CLAUDE.md"
            fi

            # Initialize git if not already
            if [[ -d "$target_dir/.git" ]]; then
                echo "📦 Git already initialized"
            else
                if command -v git &> /dev/null; then
                    (cd "$target_dir" && git init) > /dev/null 2>&1
                    echo "📦 Initialized git repository"
                else
                    echo "💡 Git not found, skipping initialization"
                fi
            fi

            # Offer GitHub repo creation
            if command -v gh &> /dev/null; then
                # Check if gh is authenticated
                if gh auth status &> /dev/null; then
                    # Get GitHub username
                    local gh_username
                    gh_username=$(gh api user --jq .login 2>/dev/null)

                    if [[ -n "$gh_username" ]]; then
                        echo ""
                        echo "🐙 Create GitHub repository?"
                        echo "   Suggested: $gh_username/$project_name"
                        echo -n "   Create? [y/N]: "
                        read -r REPLY
                        echo ""

                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            if (cd "$target_dir" && gh repo create "$gh_username/$project_name" --private --source=. 2>&1); then
                                echo "✅ Created GitHub repository: $gh_username/$project_name"
                            else
                                echo "⚠️  Failed to create repository"
                                echo "   Create manually: gh repo create $gh_username/$project_name --private --source=."
                            fi
                        else
                            echo "   Skipped GitHub repo creation"
                        fi
                    fi
                else
                    echo "💡 Run 'gh auth login' to enable GitHub repo creation"
                fi
            else
                echo "💡 Install 'gh' CLI to enable GitHub repo creation"
            fi

            # Success summary
            echo ""
            echo "✨ Project ready!"
            echo ""
            if [[ "$project_path" != "." ]]; then
                echo "Next steps:"
                echo "  cd $project_name"
                echo "  # Edit CLAUDE.md with your project details"
                echo "  amp"
            else
                echo "Next steps:"
                echo "  # Edit CLAUDE.md with your project details"
                echo "  amp"
            fi
            echo ""

            return 0
            ;;
    esac

    # Check if bootstrap is needed
    if [[ ! -f "$AMP_READY_FLAG" ]]; then
        _amp_bootstrap || return 1
    fi

    # Execute claude
    _amp_execute "$@"
}

# Function is defined and ready to use
# Source this file in your shell RC file to enable the amp command

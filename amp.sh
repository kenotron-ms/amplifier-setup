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

            if ! git pull origin main --quiet; then
                _amp_error "Failed to pull updates" \
                    "Try manually updating: cd $AMP_AMPLIFIER_DIR && git pull"
                exit 1
            fi

            _amp_log "Updated from $local_sha to $remote_sha"

            # Re-install after update
            echo "🔧 Reinstalling dependencies..."
            if ! make install >> "$AMP_LOG" 2>&1; then
                _amp_error "Failed to reinstall after update" \
                    "Check log: $AMP_LOG"
                exit 1
            fi

            echo "✅ Updated and reinstalled"
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
            local_sha=$(git rev-parse HEAD)
            remote_sha=$(git rev-parse origin/main)

            if [[ "$local_sha" != "$remote_sha" ]]; then
                echo "📥 Pulling latest changes..."
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

    # Install dependencies
    _amp_install || return 1

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
            "Reinstall amp: curl -fsSL https://raw.githubusercontent.com/kenotron/amplifier-setup/main/install.sh | bash"
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

    # Generate workspace message
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

    local workspace_message="I'm working on the $project_name project. The project is located at $workspace_dir. The $worktree_path directory is the amplifier dev environment for this workspace.

Please read @$workspace_dir/CLAUDE.md for project-specific guidance.

Whenever we execute any tools, we should assume $workspace_dir is the root directory."

    _amp_log "Launching claude from $workspace_dir using worktree $worktree_path"

    # Execute claude with workspace context as first message, then pass through all user arguments
    claude "$workspace_message" "$@"
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

            echo "📥 Pulling changes..."
            if ! git pull origin main; then
                echo "❌ Error: Failed to pull updates"
                echo "💡 Try: cd $AMP_AMPLIFIER_DIR && git status"
                return 1
            fi

            echo "🔧 Reinstalling dependencies..."
            if ! make install; then
                echo "❌ Error: Installation failed"
                return 1
            fi

            echo ""
            echo "✅ Amplifier updated successfully"
            echo "   From: ${local_sha:0:7}"
            echo "   To:   ${remote_sha:0:7}"
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

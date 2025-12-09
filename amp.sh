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
AMP_BRANCH="${AMP_BRANCH:-amplifier-claude}"  # Branch to track
UPDATE_CHECK_INTERVAL=$((24 * 3600))  # 24 hours in seconds

# Version file configuration
AMP_VERSION_FILE="$AMP_HOME/.amp_version"
AMP_REMOTE_VERSION_FILE="$AMP_HOME/.amp_remote_version"
REMOTE_VERSION_CACHE_TTL=3600  # 1 hour in seconds

# Update configuration
AMP_UPDATE_MODE="${AMP_UPDATE_MODE:-auto}"  # auto|quick|full|off
AMP_CHECK_INTERVAL="${AMP_CHECK_INTERVAL:-3600}"  # 1 hour default
AMP_GITHUB_TIMEOUT="${AMP_GITHUB_TIMEOUT:-1}"  # 1 second timeout for GitHub API
AMP_UPDATE_ASYNC="${AMP_UPDATE_ASYNC:-true}"  # Background updates by default

# State files
AMP_READY_FLAG="$AMP_HOME/.amp_ready"
AMP_LAST_CHECK="$AMP_HOME/.amp_last_check"
AMP_LOG="$AMP_HOME/.amp.log"
AMP_MIGRATED_FLAG="$AMP_HOME/.amp_migrated"  # Tracks if branch migration completed

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
# Version File Management
# ============================================================================

_amp_get_version_string() {
    # Generate version string: YYYYMMDD-HHMMSS-SHA7
    local sha="${1:-}"
    if [[ -z "$sha" ]]; then
        sha=$(cd "$AMP_AMPLIFIER_DIR" && git rev-parse --short=7 HEAD 2>/dev/null || echo "unknown")
    fi
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    echo "${timestamp}-${sha}"
}

_amp_write_version_file() {
    local sha="${1:-}"
    local version
    version="$(_amp_get_version_string "$sha")"
    echo "$version" > "$AMP_VERSION_FILE"
    _amp_log "Updated version file: $version"
}

_amp_read_version_file() {
    if [[ -f "$AMP_VERSION_FILE" ]]; then
        cat "$AMP_VERSION_FILE"
    else
        echo ""
    fi
}

_amp_get_local_sha() {
    # Extract SHA from version file or get from git
    local version
    version="$(_amp_read_version_file)"
    if [[ -n "$version" ]]; then
        # Extract SHA7 from version string (last component)
        echo "${version##*-}"
    else
        # Fallback to git
        (cd "$AMP_AMPLIFIER_DIR" && git rev-parse --short=7 HEAD 2>/dev/null || echo "")
    fi
}

_amp_get_remote_sha() {
    # Get remote SHA from GitHub API with timeout
    local api_url="https://api.github.com/repos/microsoft/amplifier/commits/main"
    local response

    response=$(curl -sS --max-time "$AMP_GITHUB_TIMEOUT" "$api_url" 2>/dev/null)
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        # Extract SHA and get first 7 characters
        local sha
        sha=$(echo "$response" | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4)
        if [[ -n "$sha" ]]; then
            echo "${sha:0:7}"
            return 0
        fi
    fi

    # Fallback to git fetch
    _amp_log "GitHub API failed, falling back to git fetch"
    return 1
}

_amp_cache_remote_version() {
    # Cache remote version with timestamp
    local remote_sha="${1:-}"
    if [[ -z "$remote_sha" ]]; then
        remote_sha="$(_amp_get_remote_sha)"
        if [[ -z "$remote_sha" ]]; then
            return 1
        fi
    fi

    local timestamp
    timestamp=$(date +%s)
    echo "${timestamp}:${remote_sha}" > "$AMP_REMOTE_VERSION_FILE"
    _amp_log "Cached remote version: $remote_sha"
}

_amp_read_cached_remote_version() {
    # Read cached remote version if still valid (within TTL)
    if [[ ! -f "$AMP_REMOTE_VERSION_FILE" ]]; then
        return 1
    fi

    local cached
    cached=$(cat "$AMP_REMOTE_VERSION_FILE")
    local cache_time="${cached%%:*}"
    local remote_sha="${cached##*:}"

    local current_time
    current_time=$(date +%s)
    local age=$((current_time - cache_time))

    if [[ $age -lt $REMOTE_VERSION_CACHE_TTL ]]; then
        echo "$remote_sha"
        return 0
    fi

    return 1
}

# ============================================================================
# Quick Version Check
# ============================================================================

_amp_quick_check() {
    # Fast version check using cached or API
    local local_sha
    local remote_sha

    # Get local version
    local_sha="$(_amp_get_local_sha)"
    if [[ -z "$local_sha" ]]; then
        _amp_log "Quick check: No local version"
        return 2  # Unknown state
    fi

    # Try cached remote version first
    remote_sha="$(_amp_read_cached_remote_version)"
    if [[ -z "$remote_sha" ]]; then
        # Cache expired, fetch fresh
        remote_sha="$(_amp_get_remote_sha)"
        if [[ -z "$remote_sha" ]]; then
            _amp_log "Quick check: Cannot determine remote version"
            return 2  # Unknown state
        fi
        _amp_cache_remote_version "$remote_sha"
    fi

    if [[ "$local_sha" == "$remote_sha" ]]; then
        return 0  # Up to date
    else
        _amp_log "Quick check: Update available ($local_sha -> $remote_sha)"
        return 1  # Update available
    fi
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
# Branch Migration
# ============================================================================

_amp_migrate_branch() {
    # Migrate from old main branch to new amplifier-claude branch
    # Skip if already migrated (unless --force flag is passed)
    local force_migrate="${1:-false}"

    if [[ -f "$AMP_MIGRATED_FLAG" ]] && [[ "$force_migrate" != "true" ]]; then
        _amp_log "Migration already completed, skipping"
        return 0
    fi

    local current_dir
    current_dir=$(pwd)

    cd "$AMP_AMPLIFIER_DIR" || return 0

    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Handle case where already on target branch but it's diverged
    if [[ "$current_branch" == "$AMP_BRANCH" ]]; then
        # Fetch latest
        git fetch origin "$AMP_BRANCH" 2>/dev/null || true

        # Check if diverged
        local behind ahead
        behind=$(git rev-list --count HEAD..origin/$AMP_BRANCH 2>/dev/null || echo "0")
        ahead=$(git rev-list --count origin/$AMP_BRANCH..HEAD 2>/dev/null || echo "0")

        if [[ "$ahead" -gt 0 ]] && [[ "$behind" -gt 0 ]]; then
            _amp_log "Branch diverged (ahead: $ahead, behind: $behind), resetting to origin/$AMP_BRANCH"

            if git reset --hard "origin/$AMP_BRANCH" 2>/dev/null; then
                _amp_log "Reset to upstream $AMP_BRANCH"
                _amp_migrate_workspaces
            else
                _amp_log "Warning: Failed to reset during divergence fix"
            fi
        fi

        cd "$current_dir"
        # Mark as migrated if we're on the right branch
        touch "$AMP_MIGRATED_FLAG"
        return 0
    fi

    if [[ "$current_branch" == "main" ]] && [[ "$AMP_BRANCH" != "main" ]]; then
        _amp_log "Detected main branch, migrating to $AMP_BRANCH"

        # Fetch the new branch
        if ! git fetch origin "$AMP_BRANCH" 2>/dev/null; then
            _amp_log "Warning: Failed to fetch $AMP_BRANCH during migration"
            cd "$current_dir"
            return 0
        fi

        # Check if local branch exists
        if git show-ref --verify --quiet "refs/heads/$AMP_BRANCH"; then
            # Local branch exists - switch to it
            if ! git checkout "$AMP_BRANCH" 2>/dev/null; then
                _amp_log "Warning: Failed to checkout existing $AMP_BRANCH during migration"
                cd "$current_dir"
                return 0
            fi

            # Set upstream
            git branch --set-upstream-to="origin/$AMP_BRANCH" "$AMP_BRANCH" 2>/dev/null

            # Check if diverged
            local behind ahead
            behind=$(git rev-list --count HEAD..origin/$AMP_BRANCH 2>/dev/null || echo "0")
            ahead=$(git rev-list --count origin/$AMP_BRANCH..HEAD 2>/dev/null || echo "0")

            if [[ "$ahead" -gt 0 ]] || [[ "$behind" -gt 0 ]]; then
                _amp_log "Branch diverged (ahead: $ahead, behind: $behind), resetting to origin/$AMP_BRANCH"

                if ! git reset --hard "origin/$AMP_BRANCH" 2>/dev/null; then
                    _amp_log "Warning: Failed to reset during migration"
                fi
            fi
        else
            # Local branch doesn't exist - create it from remote
            if ! git checkout -b "$AMP_BRANCH" "origin/$AMP_BRANCH" 2>/dev/null; then
                _amp_log "Warning: Failed to create $AMP_BRANCH during migration"
                cd "$current_dir"
                return 0
            fi
        fi

        _amp_log "Successfully migrated to $AMP_BRANCH"

        # Migrate all workspace branches
        _amp_migrate_workspaces

        # Mark as migrated
        touch "$AMP_MIGRATED_FLAG"
    fi

    cd "$current_dir"
}

_amp_migrate_workspaces() {
    # Migrate all workspace branches to track amplifier-claude (quiet mode)
    _amp_log "Migrating workspace branches to track $AMP_BRANCH"

    local workspace_branches
    workspace_branches=$(git branch --list 'workspace/*' --format='%(refname:short)')

    if [[ -z "$workspace_branches" ]]; then
        _amp_log "No workspace branches to migrate"
        return 0
    fi

    local count=0
    while IFS= read -r branch; do
        if [[ -n "$branch" ]]; then
            # Update the upstream for each workspace branch (silent)
            if git branch --set-upstream-to="origin/$AMP_BRANCH" "$branch" 2>/dev/null; then
                ((count++))
                _amp_log "Migrated workspace branch: $branch"
            fi
        fi
    done <<< "$workspace_branches"

    _amp_log "Migrated $count workspace branches"
}

# ============================================================================
# Clone
# ============================================================================

_amp_clone() {
    echo "📦 Cloning amplifier repository (branch: $AMP_BRANCH)..."

    if ! git clone -b "$AMP_BRANCH" "$AMP_REPO" "$AMP_AMPLIFIER_DIR"; then
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

    # Initialize version file
    local sha
    sha=$(cd "$AMP_AMPLIFIER_DIR" && git rev-parse --short=7 HEAD)
    _amp_write_version_file "$sha"

    _amp_log "Cloned repository to $AMP_AMPLIFIER_DIR"
    echo "✅ Repository cloned"
}

# ============================================================================
# Update
# ============================================================================

_amp_update() {
    local current_time
    current_time=$(date +%s)

    # Check if update check is needed based on mode
    if [[ "$AMP_UPDATE_MODE" == "off" ]]; then
        return 0
    fi

    # Use quick check if available
    if [[ "$AMP_UPDATE_MODE" == "auto" ]] || [[ "$AMP_UPDATE_MODE" == "quick" ]]; then
        # Check interval
        if [[ -f "$AMP_LAST_CHECK" ]]; then
            local last_check
            last_check=$(cat "$AMP_LAST_CHECK")
            local time_diff=$((current_time - last_check))

            if [[ $time_diff -lt $AMP_CHECK_INTERVAL ]]; then
                # No check needed yet
                return 0
            fi
        fi

        # Perform quick check
        _amp_quick_check
        local check_result=$?

        # Update last check timestamp
        echo "$current_time" > "$AMP_LAST_CHECK"

        if [[ $check_result -eq 0 ]]; then
            # Up to date
            return 0
        elif [[ $check_result -eq 2 ]]; then
            # Unknown state, skip update
            _amp_log "Quick check failed, skipping update"
            return 0
        fi

        # Update available - proceed with full update
        echo "📥 Update available..."
    fi

    # Full update flow
    echo "🔄 Updating amplifier..."

    # Use subshell to auto-restore directory
    (
        cd "$AMP_AMPLIFIER_DIR" || {
            _amp_error "Failed to change to amplifier directory" \
                "Check directory exists: $AMP_AMPLIFIER_DIR"
            exit 1
        }

        # Fetch latest changes
        if ! git fetch origin "$AMP_BRANCH" --quiet 2>&1; then
            _amp_log "Warning: Failed to fetch updates"
            exit 0
        fi

        # Check if update is available
        local local_sha
        local remote_sha
        local_sha=$(git rev-parse --short=7 HEAD)
        remote_sha=$(git rev-parse --short=7 "origin/$AMP_BRANCH")

        if [[ "$local_sha" != "$remote_sha" ]]; then
            echo "📥 Pulling changes..."

            # Check if dependency files changed
            local needs_install=false
            local changed_files
            changed_files=$(git diff --name-only HEAD "origin/$AMP_BRANCH")

            if echo "$changed_files" | grep -qE "pyproject.toml|uv.lock|Makefile"; then
                needs_install=true
                _amp_log "Dependency files changed, will reinstall"
            else
                _amp_log "No dependency changes detected, skipping reinstall"
            fi

            if ! git pull origin "$AMP_BRANCH" --quiet 2>&1; then
                # Check if this is an unrelated histories error
                if git pull origin "$AMP_BRANCH" --quiet 2>&1 | grep -q "refusing to merge unrelated histories"; then
                    echo "⚠️  Detected diverged histories, resetting to origin/$AMP_BRANCH..."
                    _amp_log "Git histories diverged in auto-update, performing hard reset"
                    if ! git reset --hard "origin/$AMP_BRANCH"; then
                        _amp_error "Failed to reset to origin/$AMP_BRANCH" \
                            "Try manually: cd $AMP_AMPLIFIER_DIR && git reset --hard origin/$AMP_BRANCH"
                        exit 1
                    fi
                else
                    _amp_error "Failed to pull updates" \
                        "Try manually updating: cd $AMP_AMPLIFIER_DIR && git pull"
                    exit 1
                fi
            fi

            # Update version file immediately
            _amp_write_version_file "$remote_sha"
            _amp_cache_remote_version "$remote_sha"

            _amp_log "Updated from $local_sha to $remote_sha"

            # Re-install dependencies
            if $needs_install; then
                if [[ "$AMP_UPDATE_ASYNC" == "true" ]]; then
                    echo "🔧 Installing dependencies in background..."
                    # Run make install in background
                    (make install >> "$AMP_LOG" 2>&1 &)
                    echo "✅ Updated (installing in background)"
                else
                    echo "🔧 Installing dependencies..."
                    if ! make install >> "$AMP_LOG" 2>&1; then
                        _amp_error "Failed to reinstall after update" \
                            "Check log: $AMP_LOG"
                        exit 1
                    fi
                    echo "✅ Updated and reinstalled"
                fi
            else
                echo "✅ Updated (no reinstall needed)"
            fi
        fi

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
        echo "📦 Amplifier already exists, fetching latest..."
        _amp_log "Updating existing amplifier installation"

        pushd "$AMP_AMPLIFIER_DIR" > /dev/null || {
            _amp_error "Failed to change to amplifier directory" \
                "Check directory exists: $AMP_AMPLIFIER_DIR"
            return 1
        }

        echo "📥 Fetching latest changes..."
        if ! git fetch origin "$AMP_BRANCH"; then
            echo "⚠️  Warning: Failed to fetch updates, using existing version"
            _amp_log "Warning: Failed to fetch during bootstrap"
            popd > /dev/null
        else
            local local_sha
            local remote_sha
            local needs_install=false
            local_sha=$(git rev-parse --short=7 HEAD)
            remote_sha=$(git rev-parse --short=7 "origin/$AMP_BRANCH")

            if [[ "$local_sha" != "$remote_sha" ]]; then
                echo "📥 Pulling latest changes..."

                # Check if dependency files will change
                local changed_files
                changed_files=$(git diff --name-only HEAD "origin/$AMP_BRANCH")
                if echo "$changed_files" | grep -qE "pyproject.toml|uv.lock|Makefile"; then
                    needs_install=true
                    _amp_log "Dependency files changed during bootstrap, will reinstall"
                fi

                if ! git pull origin "$AMP_BRANCH"; then
                    echo "⚠️  Warning: Failed to pull updates, using existing version"
                    _amp_log "Warning: Failed to pull during bootstrap"
                else
                    # Update version file
                    _amp_write_version_file "$remote_sha"
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
    # Check for updates (uses quick check with configurable interval)
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

Whenever we execute any tools, we should assume $workspace_dir is the root directory.

# CRITICAL Context Clarifications

1. **The working directory IS the project directory**: $workspace_dir is the actual project directory where all the user's work lives. This is what matters most.

2. **Git operations focus on the project directory**: All git operations (commits, status, branches, PRs, etc.) should operate on $workspace_dir, NOT on the amplifier dev environment ($worktree_path).

3. **Amplifier dev environment should fade into background**: The amplifier dev environment at $worktree_path is supporting infrastructure that should be invisible to the user. When discussing \"the project\" or \"your repository,\" always refer to $workspace_dir. The dev environment is just scaffolding—the user's repo is what truly matters."

    _amp_log "Launching claude from worktree $worktree_path with project dir $workspace_dir"

    # Change to worktree directory and launch claude with project directory added
    pushd "$worktree_path" > /dev/null || {
        _amp_error "Failed to change to worktree directory" \
            "Check worktree exists: $worktree_path"
        return 1
    }

    # Execute claude with workspace context as system prompt and add project directory
    # Export PROJECT_DIR so git plugin commands can use it
    export PROJECT_DIR="$workspace_dir"
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
            local workspace_script="$AMP_HOME/amp-workspace.sh"
            if [[ -f "$workspace_script" ]]; then
                # shellcheck disable=SC1090
                source "$workspace_script"
                amp_workspace "$@"
            else
                echo "❌ Error: amp-workspace.sh not found at $workspace_script"
                echo "💡 Try reinstalling: curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash"
                return 1
            fi
            return
            ;;
        quick-check)
            # Explicit quick version check
            echo "🔍 Checking version..."

            _amp_quick_check
            local result=$?

            if [[ $result -eq 0 ]]; then
                local local_sha
                local_sha="$(_amp_get_local_sha)"
                echo "✅ Up to date ($local_sha)"
                return 0
            elif [[ $result -eq 1 ]]; then
                local local_sha
                local remote_sha
                local_sha="$(_amp_get_local_sha)"
                remote_sha="$(_amp_get_remote_sha)"
                echo "📥 Update available: $local_sha → $remote_sha"
                echo ""
                echo "Run 'amp update' to update"
                return 1
            else
                echo "⚠️  Cannot determine version status"
                return 2
            fi
            ;;
        update)
            shift
            # Update both amplifier and amp scripts
            echo "🔄 Updating amp..."
            echo ""

            # Parse flags
            local wait_for_install=false
            local sync_mode=false
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --wait)
                        wait_for_install=true
                        shift
                        ;;
                    --no-async)
                        sync_mode=true
                        shift
                        ;;
                    *)
                        echo "Unknown flag: $1"
                        echo "Usage: amp update [--wait] [--no-async]"
                        return 1
                        ;;
                esac
            done

            # Override async mode if requested
            if $sync_mode; then
                AMP_UPDATE_ASYNC=false
            fi

            # Save original directory to return to after update
            local original_dir
            original_dir="$(pwd)"

            # Part 1: Update amplifier repository (optimized with parallelization)
            echo "📦 Updating amplifier repository..."
            rm -f "$AMP_LAST_CHECK"  # Force update check

            if [[ ! -d "$AMP_AMPLIFIER_DIR" ]]; then
                echo "❌ Error: Amplifier not installed yet"
                echo "💡 Run 'amp' first to bootstrap"
                return 1
            fi

            pushd "$AMP_AMPLIFIER_DIR" > /dev/null || return 1

            # Perform branch migration if needed (only during explicit update)
            _amp_migrate_branch

            # Parallel fetch
            if ! git fetch origin "$AMP_BRANCH" --quiet 2>&1; then
                echo "❌ Error: Failed to fetch updates"
                popd > /dev/null
                return 1
            fi

            local local_sha
            local remote_sha
            local_sha=$(git rev-parse --short=7 HEAD)
            remote_sha=$(git rev-parse --short=7 "origin/$AMP_BRANCH")

            if [[ "$local_sha" != "$remote_sha" ]]; then
                # Check if dependency files changed
                local changed_files
                changed_files=$(git diff --name-only HEAD "origin/$AMP_BRANCH")
                local needs_install=false

                if echo "$changed_files" | grep -qE "pyproject.toml|uv.lock|Makefile"; then
                    needs_install=true
                fi

                if ! git pull origin "$AMP_BRANCH" --quiet 2>&1; then
                    # Check if this is an unrelated histories error
                    if git pull origin "$AMP_BRANCH" --quiet 2>&1 | grep -q "refusing to merge unrelated histories"; then
                        echo "   ⚠️  Detected diverged histories, resetting to origin/$AMP_BRANCH..."
                        _amp_log "Git histories diverged, performing hard reset"
                        if ! git reset --hard "origin/$AMP_BRANCH"; then
                            echo "❌ Error: Failed to reset to origin/$AMP_BRANCH"
                            popd > /dev/null
                            return 1
                        fi
                    else
                        echo "❌ Error: Failed to pull updates"
                        popd > /dev/null
                        return 1
                    fi
                fi

                # Update version file immediately
                _amp_write_version_file "$remote_sha"
                _amp_cache_remote_version "$remote_sha"

                if $needs_install; then
                    if $wait_for_install || [[ "$AMP_UPDATE_ASYNC" != "true" ]]; then
                        echo "   • Installing dependencies..."
                        if ! make install >> "$AMP_LOG" 2>&1; then
                            echo "❌ Error: Installation failed"
                            popd > /dev/null
                            return 1
                        fi
                        echo "   ✅ Dependencies installed"
                    else
                        echo "   • Installing dependencies in background..."
                        (make install >> "$AMP_LOG" 2>&1 &)
                    fi
                fi

                echo "   ✅ Amplifier updated ($local_sha → $remote_sha)"
            else
                echo "   ✅ Amplifier already up to date"
            fi

            popd > /dev/null

            # Part 2: Update amp scripts (can run in parallel)
            echo ""
            echo "📝 Updating amp scripts..."

            # Check if GitHub is reachable (quick timeout)
            if ! curl -s --head --max-time "$AMP_GITHUB_TIMEOUT" https://github.com > /dev/null 2>&1; then
                echo "   ⚠️  GitHub unreachable, skipping script update"
            else
                # Use install.sh in update mode
                local install_script="$(dirname "${BASH_SOURCE[0]}")/install.sh"
                if [[ ! -f "$install_script" ]]; then
                    # Download install.sh if missing
                    echo "   • Downloading install.sh..."
                    curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh \
                         -o "$install_script" 2>/dev/null
                    chmod +x "$install_script"
                fi

                # Run install.sh in update mode (suppresses most output)
                if "$install_script" --update >> "$AMP_LOG" 2>&1; then
                    echo "   ✅ Scripts updated"
                else
                    echo "   ⚠️  Script update failed (see $AMP_LOG)"
                    echo "   Your current scripts continue working"
                fi
            fi

            # Part 3: Update current workspace settings (if in a project directory)
            echo ""
            echo "🔧 Updating workspace settings..."

            # Source workspace functions for _amp_configure_marketplace
            local workspace_script="$AMP_HOME/amp-workspace.sh"
            if [[ -f "$workspace_script" ]]; then
                # shellcheck disable=SC1090
                source "$workspace_script"

                # Get workspace for current directory (if exists)
                local current_dir
                current_dir="$(pwd)"
                local workspace_name
                workspace_name="$(_amp_workspace_name "$current_dir")"
                local worktree_path="$AMP_HOME/w/$workspace_name"

                if [[ -d "$worktree_path" ]] && [[ -f "$worktree_path/.git" ]]; then
                    _amp_configure_marketplace "$worktree_path"
                else
                    echo "   ℹ️  No workspace for current directory yet"
                    echo "   Run 'amp' to create one"
                fi
            else
                echo "   ⚠️  Workspace script not found, skipping settings update"
            fi

            # Part 4: Update plugin marketplaces
            echo ""
            echo "🔌 Updating plugin marketplaces..."
            if [[ -d "$worktree_path" ]] && command -v claude &> /dev/null; then
                pushd "$worktree_path" > /dev/null 2>&1
                if claude plugin marketplace update 2>/dev/null; then
                    echo "   ✅ Plugin marketplaces updated"
                else
                    echo "   ⚠️  Plugin marketplace update failed"
                fi
                popd > /dev/null 2>&1
            else
                echo "   ⚠️  Plugin marketplace update skipped (no workspace or claude not found)"
            fi

            # Success message with reload instructions
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "✅ Update complete!"
            echo ""

            if $wait_for_install || [[ "$AMP_UPDATE_ASYNC" != "true" ]]; then
                echo "⚡ To use updated scripts, reload your shell:"
            else
                echo "⚡ Dependencies installing in background"
                echo ""
                echo "To use updated scripts, reload your shell:"
            fi

            echo ""
            echo -e "${GREEN}  source ~/.${SHELL##*/}rc${NC}"
            echo ""
            echo "Or just restart your terminal."
            echo ""

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

                                # Create initial commit and push
                                echo "📤 Pushing initial commit..."
                                (
                                    cd "$target_dir"
                                    # Ensure we're on main branch
                                    git branch -M main
                                    git add -A
                                    git commit -m "Initial commit with Amplifier setup

Generated by amp new command

- CLAUDE.md with Flow-Driven Development guidance
- Ready for development with Claude Code" > /dev/null 2>&1
                                    git push -u origin main > /dev/null 2>&1
                                    echo "✅ Pushed to GitHub"
                                )
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

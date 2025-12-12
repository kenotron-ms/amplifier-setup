#!/usr/bin/env bash
# amp-workspace.sh - Workspace worktree management for amp command
#
# Each workspace in ~/.amp/w/<workspace-name>/ is a full amplifier git worktree
# This allows isolated ai_working/, .data/, and .venv per project

# Configure the amplifier-setup marketplace in worktree settings.local.json
# Uses settings.local.json to avoid modifying the amplifier repo's committed settings
_amp_configure_marketplace() {
    local worktree_path="$1"
    local settings_file="$worktree_path/.claude/settings.local.json"

    # Ensure .claude directory exists
    mkdir -p "$worktree_path/.claude"

    # If settings.local.json doesn't exist, create minimal one
    if [[ ! -f "$settings_file" ]]; then
        echo '{}' > "$settings_file"
    fi

    # Detect local amplifier-setup directory
    local local_setup_path=""
    local use_local=false

    # Check if AMP_LOCAL_SETUP_PATH is set (from reload-amp.sh)
    if [[ -n "${AMP_LOCAL_SETUP_PATH:-}" ]] && [[ -d "$AMP_LOCAL_SETUP_PATH/.claude-plugin" ]]; then
        local_setup_path="$AMP_LOCAL_SETUP_PATH"
        use_local=true
    fi

    # Add/update marketplace and plugins using python for reliable JSON manipulation
    if command -v python3 &>/dev/null; then
        python3 << EOF
import json
import sys
import os

settings_file = "$settings_file"
use_local = "$use_local" == "true"
local_setup_path = "$local_setup_path"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except (json.JSONDecodeError, FileNotFoundError):
    settings = {}

changed = False

# Add extraKnownMarketplaces if not present
if 'extraKnownMarketplaces' not in settings:
    settings['extraKnownMarketplaces'] = {}

# Determine marketplace source (local directory or GitHub)
if use_local:
    marketplace_source = {
        "source": "directory",
        "path": local_setup_path
    }
    source_desc = f"local directory ({local_setup_path})"
else:
    marketplace_source = {
        "source": "github",
        "repo": "kenotron-ms/amplifier-setup"
    }
    source_desc = "GitHub (kenotron-ms/amplifier-setup)"

# Always update marketplace source when it changes (not just when missing)
# This allows switching between local dev and GitHub
current_source = settings['extraKnownMarketplaces'].get('amplifier-setup', {}).get('source', {})
if current_source != marketplace_source:
    settings['extraKnownMarketplaces']['amplifier-setup'] = {
        "source": marketplace_source
    }
    changed = True
    print(f"  🔄 Updated marketplace source to: {source_desc}")

# Add enabledPlugins if not present
if 'enabledPlugins' not in settings:
    settings['enabledPlugins'] = {}

# Migrate from old git-flow plugin to new git plugin
if 'git-flow@amplifier-setup' in settings['enabledPlugins']:
    del settings['enabledPlugins']['git-flow@amplifier-setup']
    settings['enabledPlugins']['git@amplifier-setup'] = True
    changed = True
    print("  🔄 Migrated git-flow plugin to git plugin")

# Enable git plugin from amplifier-setup marketplace
if 'git@amplifier-setup' not in settings['enabledPlugins']:
    settings['enabledPlugins']['git@amplifier-setup'] = True
    changed = True

# Enable dev-kit plugin from amplifier-setup marketplace
if 'dev-kit@amplifier-setup' not in settings['enabledPlugins']:
    settings['enabledPlugins']['dev-kit@amplifier-setup'] = True
    changed = True

if changed:
    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2)
        f.write('\n')
    print("  ✅ Configured amplifier-setup marketplace and plugins")
else:
    print("  ✅ Marketplace and plugins already configured")
EOF
    else
        echo "  ⚠️  Python not found, skipping marketplace configuration" >&2
    fi
}

# Convert path to safe directory name
# /home/user/projects/foo -> home-user-projects-foo
# /Users/ken/workspace/foo -> Users-ken-workspace-foo
_amp_workspace_name() {
    local path="$1"
    # Remove leading slash, replace / with -, keep only alphanumeric and dash/underscore
    # Use full paths to avoid PATH issues
    echo "$path" | /usr/bin/sed 's:^/::' | /usr/bin/tr '/' '-' | /usr/bin/tr -cd '[:alnum:]-_'
}

# Get or create worktree for current workspace
_amp_get_or_create_worktree() {
    # Save original directory to restore on any exit
    local original_dir
    original_dir="$(pwd)"

    # Get absolute path to handle relative directories properly
    local workspace_path
    workspace_path="$(cd "$original_dir" && pwd)"

    # Normalize AMP_HOME and AMP_AMPLIFIER_DIR to absolute paths for comparison
    local amp_home_abs
    local amp_amplifier_abs
    amp_home_abs="$(cd "$AMP_HOME" 2>/dev/null && pwd || echo "$AMP_HOME")"
    amp_amplifier_abs="$(cd "$AMP_AMPLIFIER_DIR" 2>/dev/null && pwd || echo "$AMP_AMPLIFIER_DIR")"

    # Don't create workspace for amplifier directories themselves
    if [[ "$workspace_path" == "$amp_home_abs"* ]] || [[ "$workspace_path" == "$amp_amplifier_abs"* ]]; then
        echo "❌ Error: Cannot create workspace for amplifier directory" >&2
        echo "💡 Run amp from your project directory, not from $AMP_HOME or $AMP_AMPLIFIER_DIR" >&2
        return 1
    fi

    local workspace_name
    workspace_name="$(_amp_workspace_name "$workspace_path")"

    local worktree_path="$AMP_HOME/w/$workspace_name"

    # If worktree already exists, return its path
    if [[ -d "$worktree_path" ]] && [[ -f "$worktree_path/.git" ]]; then
        echo "$worktree_path"
        return 0
    fi

    # Create new worktree
    echo "📦 Creating workspace worktree for: $workspace_path" >&2
    echo "   Worktree location: $worktree_path" >&2
    echo "" >&2

    # Ensure workspace directory exists
    mkdir -p "$AMP_HOME/w"

    # Create git worktree from main amplifier repo (in subshell to restore dir)
    (
        cd "$AMP_AMPLIFIER_DIR" || exit 1

        # Create a unique branch for this worktree (based on workspace name)
        local branch_name="workspace/$workspace_name"

        # Check if branch already exists (from previous worktree)
        if git show-ref --verify --quiet "refs/heads/$branch_name"; then
            # Branch exists, use it without creating new one
            git worktree add "$worktree_path" "$branch_name" 2>&1 | grep -v "^$" >&2
        else
            # Branch doesn't exist, create new one from current branch (amplifier-claude)
            git worktree add -b "$branch_name" "$worktree_path" "$AMP_BRANCH" 2>&1 | grep -v "^$" >&2
        fi
    ) || {
        echo "❌ Error: Failed to create worktree" >&2
        cd "$original_dir" 2>/dev/null || true
        return 1
    }

    echo "✅ Worktree created on branch: workspace/$workspace_name" >&2

    # Configure marketplace in worktree settings
    echo "🔧 Configuring marketplace..." >&2
    _amp_configure_marketplace "$worktree_path" >&2

    # Set up virtual environment for this worktree (in subshell)
    echo "🔧 Setting up virtual environment..." >&2
    (
        cd "$worktree_path" || exit 1
        make install >> "$AMP_LOG" 2>&1
    ) || {
        echo "⚠️  Warning: make install failed (check log: $AMP_LOG)" >&2
        echo "   You may need to run 'make install' manually in the worktree" >&2
    }

    # Explicitly return to original directory
    cd "$original_dir" 2>/dev/null || true

    echo "" >&2
    echo "✅ Workspace ready: $workspace_name" >&2
    echo "" >&2

    # Return worktree path
    echo "$worktree_path"
}

# List all workspace worktrees
_amp_list_workspaces() {
    local original_dir
    original_dir="$(pwd)"

    local workspace_base="$AMP_HOME/w"

    if [[ ! -d "$workspace_base" ]] || [[  -z "$(ls -A "$workspace_base" 2>/dev/null)" ]]; then
        echo "No workspaces created yet"
        echo ""
        echo "Run 'amp' in a project directory to create a workspace worktree."
        return
    fi

    echo "Workspace Worktrees:"
    echo ""

    # List all worktrees using git (in subshell to auto-restore)
    (
        cd "$AMP_AMPLIFIER_DIR" || exit 1
        git worktree list | grep "$workspace_base" | while read -r path branch rest; do
            workspace_name="${path##*/}"
            branch_name="${branch//[\[\]]/}"

            printf "%-30s %s\n" "$workspace_name" "$path"
            printf "  Branch: %s\n\n" "$branch_name"
        done
    )

    cd "$original_dir" 2>/dev/null || true
}

# Remove a workspace worktree
_amp_remove_worktree() {
    local original_dir
    original_dir="$(pwd)"

    local workspace_path="${1:-$original_dir}"
    local workspace_name
    workspace_name="$(_amp_workspace_name "$workspace_path")"
    local worktree_path="$AMP_HOME/w/$workspace_name"

    if [[ ! -d "$worktree_path" ]]; then
        echo "⚠️  Workspace not found: $workspace_path"
        return 1
    fi

    echo "🗑️  Removing workspace worktree: $workspace_name"

    # Get the branch name before removing
    local branch_name
    if [[ -d "$worktree_path" ]]; then
        branch_name=$(cd "$worktree_path" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    fi

    # Remove worktree and branch (in subshell)
    (
        cd "$AMP_AMPLIFIER_DIR" || exit 1

        if ! git worktree remove "$worktree_path" --force; then
            echo "❌ Failed to remove worktree" >&2
            echo "   You may need to remove manually: rm -rf $worktree_path" >&2
            exit 1
        fi

        echo "✅ Worktree removed: $workspace_path"

        # Also delete the branch if it was a workspace branch
        if [[ -n "$branch_name" ]] && [[ "$branch_name" == workspace/* ]]; then
            echo "🗑️  Removing branch: $branch_name"
            if git branch -D "$branch_name" 2>/dev/null; then
                echo "✅ Branch removed"
            fi
        fi
    ) || {
        cd "$original_dir" 2>/dev/null || true
        return 1
    }

    cd "$original_dir" 2>/dev/null || true
}

# Show info for current workspace worktree
_amp_workspace_info() {
    local workspace_path
    workspace_path="$(pwd)"

    local workspace_name
    workspace_name="$(_amp_workspace_name "$workspace_path")"

    local worktree_path="$AMP_HOME/w/$workspace_name"

    echo "Current Directory: $workspace_path"
    echo "Workspace Name: $workspace_name"
    echo "Worktree Path: $worktree_path"
    echo ""

    if [[ -d "$worktree_path" ]]; then
        echo "Status: Workspace exists"

        if [[ -d "$worktree_path/.venv" ]]; then
            echo "Python venv: ✅ Installed"
        else
            echo "Python venv: ⚠️  Not found"
        fi

        if [[ -d "$worktree_path/ai_working" ]]; then
            echo "AI working dir: ✅ Present"
        else
            echo "AI working dir: Not created yet"
        fi

        # Show git branch
        if [[ -d "$worktree_path/.git" ]]; then
            local branch
            branch=$(cd "$worktree_path" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
            echo "Git branch: $branch"
        fi
    else
        echo "Status: Workspace not created yet"
        echo ""
        echo "Run 'amp' to create the workspace worktree."
    fi
}

# Prune orphaned workspace worktrees
_amp_prune_workspaces() {
    local workspace_base="$AMP_HOME/w"

    if [[ ! -d "$workspace_base" ]]; then
        echo "No workspaces found to prune"
        return 0
    fi

    echo "🔍 Scanning for orphaned workspaces..."
    echo ""

    local orphaned=()
    local checked=0

    # Check each worktree directory
    for worktree_path in "$workspace_base"/*; do
        [[ -d "$worktree_path" ]] || continue

        checked=$((checked + 1))
        local workspace_name="${worktree_path##*/}"

        # A worktree is orphaned if git worktree list doesn't show it
        # (meaning git already knows it's broken/missing)
        if ! (cd "$AMP_AMPLIFIER_DIR" && git worktree list) | grep -q "$worktree_path"; then
            orphaned+=("$worktree_path:$workspace_name")
        fi
    done

    if [[ ${#orphaned[@]} -eq 0 ]]; then
        echo "✅ No orphaned workspaces found ($checked checked)"
        return 0
    fi

    echo "Found ${#orphaned[@]} orphaned workspace(s):"
    echo ""

    for item in "${orphaned[@]}"; do
        local path="${item%%:*}"
        local name="${item##*:}"
        local size
        if command -v du >/dev/null 2>&1; then
            size=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
        else
            size="unknown"
        fi
        echo "  • $name ($size)"
    done

    echo ""
    echo -n "Remove these orphaned workspaces? [y/N]: "
    read -r REPLY
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled - no workspaces removed"
        return 0
    fi

    # Remove orphaned workspaces
    local removed=0
    for item in "${orphaned[@]}"; do
        local path="${item%%:*}"
        local name="${item##*:}"

        echo "🗑️  Removing $name..."

        # Try to remove from git worktree list (may already be gone)
        (cd "$AMP_AMPLIFIER_DIR" && git worktree remove "$path" --force 2>/dev/null) || true

        # Remove directory
        rm -rf "$path"
        removed=$((removed + 1))
    done

    echo ""
    echo "✅ Removed $removed orphaned workspace(s)"
}

# Command dispatcher for workspace subcommands
amp_workspace() {
    local subcommand="${1:-list}"
    [[ $# -gt 0 ]] && shift

    case "$subcommand" in
        list)
            _amp_list_workspaces
            ;;
        info)
            _amp_workspace_info
            ;;
        remove)
            _amp_remove_worktree "$@"
            ;;
        prune)
            _amp_prune_workspaces
            ;;
        *)
            echo "Usage: amp workspace <command>"
            echo ""
            echo "Commands:"
            echo "  list              List all workspace worktrees"
            echo "  info              Show info for current workspace"
            echo "  remove [path]     Remove a workspace worktree (default: current directory)"
            echo "  prune             Remove orphaned workspaces (interactive)"
            echo ""
            echo "Note: Each workspace is a full amplifier git worktree with isolated:"
            echo "  • .venv (Python virtual environment)"
            echo "  • ai_working/ (session-specific work)"
            echo "  • .data/ (workspace-specific data)"
            echo ""
            return 1
            ;;
    esac
}

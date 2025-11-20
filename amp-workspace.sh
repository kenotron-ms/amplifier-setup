#!/usr/bin/env bash
# amp-workspace.sh - Workspace worktree management for amp command
#
# Each workspace in ~/.amp/w/<workspace-name>/ is a full amplifier git worktree
# This allows isolated ai_working/, .data/, and .venv per project

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
            # Branch doesn't exist, create new one from main
            git worktree add -b "$branch_name" "$worktree_path" main 2>&1 | grep -v "^$" >&2
        fi
    ) || {
        echo "❌ Error: Failed to create worktree" >&2
        cd "$original_dir" 2>/dev/null || true
        return 1
    }

    echo "✅ Worktree created on branch: workspace/$workspace_name" >&2

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
            local workspace_name
            workspace_name="$(basename "$path")"
            local branch_name
            branch_name=$(echo "$branch" | /usr/bin/sed 's/[\[\]]//g')

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

# Command dispatcher for workspace subcommands
amp_workspace() {
    local subcommand="${1:-list}"
    shift || true

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
        *)
            echo "Usage: amp workspace <command>"
            echo ""
            echo "Commands:"
            echo "  list              List all workspace worktrees"
            echo "  info              Show info for current workspace"
            echo "  remove [path]     Remove a workspace worktree (default: current directory)"
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

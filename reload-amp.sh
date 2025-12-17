#!/usr/bin/env bash
# reload-amp.sh - Reinstall local amplifier-setup changes and reload shell
#
# Usage:
#   ./reload-amp.sh                    # Use local marketplace (for development)
#   ./reload-amp.sh --github           # Switch back to GitHub marketplace
#   ./reload-amp.sh --keep-cache       # Skip clearing Claude Code snapshot cache
#   ./reload-amp.sh --github --keep-cache  # Combine options
#
# This script:
# 1. Installs amplifier-setup from local directory
# 2. Clears Claude Code snapshot cache (unless --keep-cache is used)
# 3. Updates workspace configurations (local or GitHub mode)
# 4. Returns to the directory where you ran it from
# 5. Reloads shell configuration to pick up changes
#
# Note: Active Claude Code sessions must be restarted to use updated scripts

set -e

# Parse arguments
USE_GITHUB=false
KEEP_CACHE=false

while [[ $# -gt 0 ]]; do
    case "${1:-}" in
        --github)
            USE_GITHUB=true
            shift
            ;;
        --keep-cache)
            KEEP_CACHE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--github] [--keep-cache]"
            echo ""
            echo "Options:"
            echo "  --github      Use GitHub marketplace instead of local"
            echo "  --keep-cache  Skip clearing Claude Code snapshot cache"
            exit 1
            ;;
    esac
done

# Save the directory where the script was called from
ORIGINAL_DIR="$(pwd)"
# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
if $USE_GITHUB; then
    echo -e "${BLUE}🔄 Reloading amplifier-setup (GitHub mode)...${NC}"
else
    echo -e "${BLUE}🔄 Reloading amplifier-setup (local mode)...${NC}"
fi
echo ""

# Run install from amplifier-setup directory
cd "$SCRIPT_DIR"
echo "📁 Installing from: $SCRIPT_DIR"

# Export local setup path for local development mode only
if ! $USE_GITHUB; then
    export AMP_LOCAL_SETUP_PATH="$SCRIPT_DIR"
fi

./install.sh --update

# Return to original directory
cd "$ORIGINAL_DIR"
echo ""
echo "📁 Returned to: $ORIGINAL_DIR"
echo ""

# Reload shell config
if [[ "$SHELL" == */zsh ]]; then
    source ~/.zshrc
    echo -e "${GREEN}✅ Reloaded ~/.zshrc${NC}"
elif [[ "$SHELL" == */bash ]]; then
    source ~/.bashrc
    echo -e "${GREEN}✅ Reloaded ~/.bashrc${NC}"
else
    source ~/.amp/amp.sh
    echo -e "${GREEN}✅ Reloaded ~/.amp/amp.sh${NC}"
fi

# Clear marketplace cache to force refresh
echo ""
echo "🧹 Clearing marketplace cache..."
if [[ -d ~/.claude/plugins/marketplaces/amplifier-setup ]]; then
    rm -rf ~/.claude/plugins/marketplaces/amplifier-setup
    echo "   ✅ Cleared amplifier-setup marketplace cache"
else
    echo "   ℹ️  No cache to clear"
fi

# Clear Claude Code shell snapshot cache (important for dev workflow)
if ! $KEEP_CACHE; then
    echo ""
    echo "🧹 Clearing Claude Code shell snapshots..."
    if [[ -d ~/.claude/shell-snapshots ]]; then
        # Count snapshots before deleting
        snapshot_count=$(find ~/.claude/shell-snapshots -name "snapshot-*.sh" 2>/dev/null | wc -l | tr -d ' ')

        if [[ $snapshot_count -gt 0 ]]; then
            rm -f ~/.claude/shell-snapshots/snapshot-*.sh
            echo "   ✅ Cleared $snapshot_count shell snapshot(s)"
            echo "   ℹ️  Active Claude Code sessions need to be restarted"
        else
            echo "   ℹ️  No snapshots to clear"
        fi
    else
        echo "   ℹ️  No snapshot directory found"
    fi
else
    echo ""
    echo "ℹ️  Skipping snapshot cache clearing (--keep-cache flag used)"
    echo "   Note: Active Claude sessions may not see changes until restarted"
fi

# Update existing workspace configurations
echo ""
if $USE_GITHUB; then
    echo "🔧 Switching workspaces to GitHub marketplace..."
else
    echo "🔧 Switching workspaces to local marketplace..."
fi

# Source workspace functions
if [[ -f ~/.amp/amp-workspace.sh ]]; then
    source ~/.amp/amp-workspace.sh

    # Set AMP_LOCAL_SETUP_PATH for local mode, unset for GitHub mode
    if ! $USE_GITHUB; then
        export AMP_LOCAL_SETUP_PATH="$SCRIPT_DIR"
    else
        unset AMP_LOCAL_SETUP_PATH
    fi

    # Update workspace for current directory if it exists
    if [[ -d "$ORIGINAL_DIR" ]] && [[ "$ORIGINAL_DIR" != "$HOME/.amp"* ]]; then
        workspace_name="$(_amp_workspace_name "$ORIGINAL_DIR")"
        worktree_path="$HOME/.amp/w/$workspace_name"

        if [[ -d "$worktree_path" ]] && [[ -f "$worktree_path/.git" ]]; then
            echo "   Updating: $workspace_name"
            _amp_configure_marketplace "$worktree_path"
        fi
    fi

    # Update all existing workspaces
    if [[ -d "$HOME/.amp/w" ]]; then
        for worktree_path in "$HOME/.amp/w"/*; do
            if [[ -d "$worktree_path" ]] && [[ -f "$worktree_path/.git" ]]; then
                workspace_name="${worktree_path##*/}"
                # Skip the current directory workspace (already updated above)
                if [[ "$workspace_name" != "$(_amp_workspace_name "$ORIGINAL_DIR")" ]]; then
                    echo "   Updating: $workspace_name"
                    _amp_configure_marketplace "$worktree_path"
                fi
            fi
        done
    fi
fi

echo ""
echo -e "${GREEN}✅ amp command updated and ready to use!${NC}"
echo ""

# Check if we're likely in a Claude Code session
if [[ -n "${CLAUDE_SESSION_ID:-}" ]] || [[ -n "${ANTHROPIC_CHAT_SESSION_ID:-}" ]]; then
    echo "⚠️  You're in an active Claude Code session"
    echo ""
    echo "💡 To use updated amp.sh:"
    echo "   1. Exit Claude Code (type 'exit' in that session)"
    echo "   2. In your terminal: source ~/.zshrc"
    echo "   3. Run: cd $ORIGINAL_DIR && amp"
    echo ""
else
    echo "💡 If you have Claude Code sessions running:"
    echo "   • Exit those sessions (type 'exit')"
    echo "   • In your terminal: source ~/.zshrc"
    echo "   • Start fresh: cd $ORIGINAL_DIR && amp"
    echo ""
fi

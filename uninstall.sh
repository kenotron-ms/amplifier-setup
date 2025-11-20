#!/usr/bin/env bash
# uninstall.sh - Uninstall the amp command
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/uninstall.sh | bash
#   OR
#   ./uninstall.sh
#
# What it does:
# 1. Removes amp source lines from shell RC files
# 2. Optionally removes ~/.amp directory (with confirmation)
# 3. Provides cleanup verification

set -e

# Usage documentation
usage() {
    cat << 'EOF'
Usage: amp uninstall [OPTIONS]
   or: uninstall.sh [OPTIONS]

Remove amp command from your system.

Options:
    --data          Also remove ~/.amp directory (workspace data, logs, etc.)
    --no-confirm    Skip confirmation prompts (use with caution!)
    -h, --help      Show this help message

By default, only removes amp from shell configuration files.
Your workspace data in ~/.amp/ will be preserved.

Examples:
    amp uninstall              # Remove amp, keep data
    amp uninstall --data       # Remove amp AND data
    ./uninstall.sh --data      # Direct script execution
EOF
}

# Parse arguments
REMOVE_DATA=false
NO_CONFIRM=false

for arg in "$@"; do
    case "$arg" in
        --data)
            REMOVE_DATA=true
            ;;
        --no-confirm)
            NO_CONFIRM=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo ""
            usage
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "🗑️  Uninstalling amp command..."
echo ""

# Configuration
AMP_HOME="${AMP_HOME:-$HOME/.amp}"

# Step 1: Remove from shell RC files
echo "🔧 Removing from shell configuration..."

REMOVED_COUNT=0
for RC_FILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$RC_FILE" ]]; then
        # Check if amp is configured
        if grep -q "source.*amp.sh" "$RC_FILE" 2>/dev/null || grep -q "# Amplifier (amp command)" "$RC_FILE" 2>/dev/null; then
            # Create backup
            cp "$RC_FILE" "${RC_FILE}.amp-backup"

            # Remove amp-related lines
            sed -i.tmp '/# Amplifier (amp command)/d' "$RC_FILE" 2>/dev/null || true
            sed -i.tmp '/source.*amp\.sh/d' "$RC_FILE" 2>/dev/null || true
            sed -i.tmp '/source.*\.amp/d' "$RC_FILE" 2>/dev/null || true

            # Clean up temp file
            rm -f "${RC_FILE}.tmp"

            echo -e "  ✅ Removed from $(basename "$RC_FILE") ${BLUE}(backup: ${RC_FILE}.amp-backup)${NC}"
            REMOVED_COUNT=$((REMOVED_COUNT + 1))
        else
            echo "  ✓ $(basename "$RC_FILE") - nothing to remove"
        fi
    fi
done

if [[ $REMOVED_COUNT -eq 0 ]]; then
    echo "  ℹ️  No shell configuration found"
fi

# Step 2: Check amp directory
echo ""
if [[ -d "$AMP_HOME" ]]; then
    # Calculate size
    AMP_SIZE=$(du -sh "$AMP_HOME" 2>/dev/null | cut -f1)

    if $REMOVE_DATA; then
        echo -e "${YELLOW}📂 Will remove amp directory:${NC} $AMP_HOME ($AMP_SIZE)"
        echo ""
        echo "This directory contains:"
        echo "  • Main amplifier repository (~/.amp/main)"
        echo "  • All workspace worktrees (~/.amp/w/)"
        echo "  • Virtual environments and dependencies"
        echo "  • AI working files and data"
        echo ""

        if $NO_CONFIRM; then
            # No confirmation, just remove
            echo "🗑️  Removing $AMP_HOME..."
            rm -rf "$AMP_HOME"
            echo -e "${GREEN}✅ Removed amp directory${NC}"
        elif [[ -t 0 ]]; then
            # Interactive - prompt for confirmation
            read -p "Really remove this directory and ALL data? (y/N): " -n 1 -r
            echo ""

            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "🗑️  Removing $AMP_HOME..."
                rm -rf "$AMP_HOME"
                echo -e "${GREEN}✅ Removed amp directory${NC}"
            else
                echo -e "${BLUE}ℹ️  Kept amp directory${NC}"
            fi
        else
            # Piped mode - show instructions
            echo -e "${BLUE}ℹ️  Cannot prompt in non-interactive mode${NC}"
            echo "To remove amp directory, run:"
            echo "  rm -rf $AMP_HOME"
        fi
    else
        echo -e "${BLUE}ℹ️  Keeping amp directory:${NC} $AMP_HOME ($AMP_SIZE)"
        echo ""
        echo "Your workspace data is preserved. To remove it later, run:"
        echo "  amp uninstall --data"
        echo "  OR"
        echo "  rm -rf $AMP_HOME"
    fi
else
    echo "ℹ️  No amp directory found at $AMP_HOME"
fi

# Success message
echo ""
echo -e "${GREEN}✅ Uninstall complete!${NC}"
echo ""
echo "📝 What was done:"
echo "  • Removed amp source lines from shell RC files"
if [[ -d "$AMP_HOME" ]]; then
    echo "  • Amp directory still exists at $AMP_HOME"
else
    echo "  • Removed amp directory"
fi
echo ""
echo "💡 Note:"
echo "  • The 'amp' command will remain available in THIS terminal session"
echo "  • New terminals will not have the 'amp' command"
echo "  • To remove from current session: unset -f amp"
echo ""
echo "💡 Next steps:"
echo "  • Reload your shell or open a new terminal"
if [[ $REMOVED_COUNT -gt 0 ]]; then
    echo "  • RC file backups saved with .amp-backup extension"
fi
echo ""

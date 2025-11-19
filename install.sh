#!/usr/bin/env bash
# install.sh - Install/Update the amp command
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kenotron/amplifier-setup/main/install.sh | bash
#
# This script is idempotent - safe to run multiple times to get latest version.
#
# What it does:
# 1. Downloads latest amp.sh and amp-workspace.sh from GitHub
# 2. Installs them to ~/.amp/
# 3. Adds source line to shell RC files (if not already present)
# 4. Sources for current session

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "🚀 Installing amp command..."
echo ""

# Configuration
AMP_HOME="${AMP_HOME:-$HOME/.amp}"
AMP_SCRIPT="$AMP_HOME/amp.sh"
DOWNLOAD_URL="https://raw.githubusercontent.com/kenotron/amplifier-setup/main/amp.sh"

# Clean up old versions if they exist
if [[ -f "$AMP_SCRIPT" ]]; then
    echo "🧹 Cleaning up old installation..."
    rm -f "$AMP_SCRIPT" "$AMP_HOME/amp-workspace.sh"
    echo "✅ Old version removed"
    echo ""
fi

# Create installation directory
echo "📁 Creating installation directory..."
mkdir -p "$AMP_HOME"

# Check if we're running from a local clone (amp.sh in same directory as install.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_AMP_SCRIPT="$SCRIPT_DIR/amp.sh"
LOCAL_WORKSPACE_SCRIPT="$SCRIPT_DIR/amp-workspace.sh"

if [[ -f "$LOCAL_AMP_SCRIPT" ]]; then
    # Use local copy (development mode)
    echo "📦 Using local scripts from repository..."
    cp -f "$LOCAL_AMP_SCRIPT" "$AMP_SCRIPT"
    if [[ -f "$LOCAL_WORKSPACE_SCRIPT" ]]; then
        cp -f "$LOCAL_WORKSPACE_SCRIPT" "$AMP_HOME/amp-workspace.sh"
    fi
    chmod +x "$AMP_SCRIPT" "$AMP_HOME/amp-workspace.sh"
    echo "✅ Installed local scripts"
else
    # Always download latest from GitHub (idempotent updates)
    echo "📥 Downloading latest scripts from GitHub..."

    if command -v curl &> /dev/null; then
        # Download amp.sh
        if ! curl -fsSL "$DOWNLOAD_URL" -o "$AMP_SCRIPT.tmp"; then
            echo -e "${RED}❌ Failed to download amp.sh${NC}" >&2
            echo -e "${YELLOW}💡 Check your internet connection and try again${NC}" >&2
            exit 1
        fi
        mv "$AMP_SCRIPT.tmp" "$AMP_SCRIPT"

        # Download amp-workspace.sh
        if curl -fsSL "https://raw.githubusercontent.com/kenotron/amplifier-setup/main/amp-workspace.sh" -o "$AMP_HOME/amp-workspace.sh.tmp" 2>/dev/null; then
            mv "$AMP_HOME/amp-workspace.sh.tmp" "$AMP_HOME/amp-workspace.sh"
        fi

    elif command -v wget &> /dev/null; then
        # Download amp.sh
        if ! wget -q "$DOWNLOAD_URL" -O "$AMP_SCRIPT.tmp"; then
            echo -e "${RED}❌ Failed to download amp.sh${NC}" >&2
            echo -e "${YELLOW}💡 Check your internet connection and try again${NC}" >&2
            exit 1
        fi
        mv "$AMP_SCRIPT.tmp" "$AMP_SCRIPT"

        # Download amp-workspace.sh
        if wget -q "https://raw.githubusercontent.com/kenotron/amplifier-setup/main/amp-workspace.sh" -O "$AMP_HOME/amp-workspace.sh.tmp" 2>/dev/null; then
            mv "$AMP_HOME/amp-workspace.sh.tmp" "$AMP_HOME/amp-workspace.sh"
        fi

    else
        echo -e "${RED}❌ Neither curl nor wget found${NC}" >&2
        echo -e "${YELLOW}💡 Install curl or wget and try again${NC}" >&2
        exit 1
    fi

    chmod +x "$AMP_SCRIPT" "$AMP_HOME/amp-workspace.sh"
    echo "✅ Downloaded latest scripts"
fi

# Add to shell RC files
echo ""
echo "🔧 Configuring shell..."

# Clean up old references first (from previous versions)
for RC_FILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$RC_FILE" ]]; then
        # Remove old .amplifier references
        if grep -q "\.amplifier" "$RC_FILE" 2>/dev/null; then
            echo "  🧹 Removing old .amplifier references from $(basename "$RC_FILE")..."
            sed -i.bak '/\.amplifier/d' "$RC_FILE"
            rm -f "${RC_FILE}.bak"
        fi
        # Remove old amp comment lines
        sed -i.bak '/# Amplifier (amp command)/d' "$RC_FILE" 2>/dev/null || true
        rm -f "${RC_FILE}.bak"
    fi
done

SOURCE_LINE="source $AMP_SCRIPT"
COMMENT_LINE="# Amplifier (amp command)"

for RC_FILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
    # Only modify if the file exists or is the primary shell
    SHOULD_UPDATE=false

    if [[ -f "$RC_FILE" ]]; then
        SHOULD_UPDATE=true
    elif [[ "$RC_FILE" == "$HOME/.bashrc" ]] && [[ "$SHELL" == */bash ]]; then
        SHOULD_UPDATE=true
        touch "$RC_FILE"
    elif [[ "$RC_FILE" == "$HOME/.zshrc" ]] && [[ "$SHELL" == */zsh ]]; then
        SHOULD_UPDATE=true
        touch "$RC_FILE"
    fi

    if $SHOULD_UPDATE; then
        # Check if already configured
        if grep -q "source.*amp.sh" "$RC_FILE" 2>/dev/null; then
            echo "  ✓ $(basename "$RC_FILE") already configured"
        else
            # Add source line
            {
                echo ""
                echo "$COMMENT_LINE"
                echo "$SOURCE_LINE"
            } >> "$RC_FILE"
            echo "  ✅ Added to $(basename "$RC_FILE")"
        fi
    fi
done

# Source for current session
echo ""
echo "🔄 Loading amp command for current session..."
# shellcheck disable=SC1090
source "$AMP_SCRIPT"
echo "✅ amp command loaded"

# Show success message
echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "📝 Usage:"
echo "  amp              - Start Claude Code with amplifier in current directory"
echo "  amp --help       - Show Claude Code help"
echo "  amp \"do X\"       - Run Claude Code with a prompt"
echo ""
echo "💡 Notes:"
echo "  • On first run, amp will automatically:"
echo "    - Check prerequisites (git, make, python3, uv, claude)"
echo "    - Clone amplifier repository to ~/.amp/main"
echo "    - Create a workspace worktree for your project"
echo "    - Install dependencies"
echo "  • Updates are checked once per 24 hours"
echo "  • Each project gets its own isolated worktree in ~/.amp/w/"
echo ""
echo "🎯 Try it now:"
echo "  amp"
echo ""

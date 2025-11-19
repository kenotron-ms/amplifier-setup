#!/usr/bin/env bash
# install.sh - Install the amp command
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/microsoft/amplifier-setup/main/install.sh | bash
#
# This script:
# 1. Downloads amp.sh
# 2. Installs it to ~/.amplifier/amp.sh
# 3. Adds source line to shell RC files
# 4. Sources it for current session

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
AMP_HOME="${AMP_HOME:-$HOME/.amplifier}"
AMP_SCRIPT="$AMP_HOME/amp.sh"
DOWNLOAD_URL="https://raw.githubusercontent.com/microsoft/amplifier-setup/main/amp.sh"

# Create installation directory
echo "📁 Creating installation directory..."
mkdir -p "$AMP_HOME"

# Check if we're running from a local clone (amp.sh in same directory as install.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_AMP_SCRIPT="$SCRIPT_DIR/amp.sh"

if [[ -f "$LOCAL_AMP_SCRIPT" ]]; then
    # Use local copy
    echo "📦 Using local amp.sh from repository..."
    if ! cp "$LOCAL_AMP_SCRIPT" "$AMP_SCRIPT"; then
        echo -e "${RED}❌ Failed to copy amp.sh${NC}" >&2
        exit 1
    fi
    chmod +x "$AMP_SCRIPT"
    echo "✅ Installed local amp.sh"
else
    # Download from GitHub
    echo "📥 Downloading amp.sh from GitHub..."
    if command -v curl &> /dev/null; then
        if ! curl -fsSL "$DOWNLOAD_URL" -o "$AMP_SCRIPT"; then
            echo -e "${RED}❌ Failed to download amp.sh${NC}" >&2
            echo -e "${YELLOW}💡 Check your internet connection and try again${NC}" >&2
            exit 1
        fi
    elif command -v wget &> /dev/null; then
        if ! wget -q "$DOWNLOAD_URL" -O "$AMP_SCRIPT"; then
            echo -e "${RED}❌ Failed to download amp.sh${NC}" >&2
            echo -e "${YELLOW}💡 Check your internet connection and try again${NC}" >&2
            exit 1
        fi
    else
        echo -e "${RED}❌ Neither curl nor wget found${NC}" >&2
        echo -e "${YELLOW}💡 Install curl or wget and try again${NC}" >&2
        exit 1
    fi
    chmod +x "$AMP_SCRIPT"
    echo "✅ Downloaded amp.sh"
fi

# Add to shell RC files
echo ""
echo "🔧 Configuring shell..."

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
echo "    - Check prerequisites (git, make, uv, claude)"
echo "    - Clone amplifier repository"
echo "    - Install dependencies"
echo "  • Updates are checked once per 24 hours"
echo "  • All files are stored in: $AMP_HOME"
echo ""
echo "🎯 Try it now:"
echo "  amp"
echo ""

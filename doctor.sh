#!/usr/bin/env bash
# doctor.sh - Diagnose amp installation health
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/doctor.sh | bash
#
# What it checks:
# 1. Prerequisites (Python, Git, uv, Claude Code)
# 2. amp command availability
# 3. Script versions (local vs remote)
# 4. Main amplifier repo branch (should be amplifier-claude)
# 5. All worktree branches (should be amplifier-claude)
# 6. Worktree origins (should point to amplifier repo)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AMP_HOME="${AMP_HOME:-$HOME/.amp}"
BASE_URL="https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main"
EXPECTED_BRANCH="amplifier-claude"

# Counters
ERRORS=0
WARNINGS=0
SUCCESS=0

echo ""
echo "🏥 amp Doctor - Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# =============================================================================
# Helper Functions
# =============================================================================

error() {
    echo -e "${RED}❌ $1${NC}"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
    SUCCESS=$((SUCCESS + 1))
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# =============================================================================
# 1. Prerequisites Check
# =============================================================================

echo "📋 Checking Prerequisites"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Python
if command -v python3 &> /dev/null; then
    VERSION=$(python3 --version 2>&1)
    MAJOR=$(echo "$VERSION" | grep -oE '[0-9]+' | head -1)
    MINOR=$(echo "$VERSION" | grep -oE '[0-9]+' | head -2 | tail -1)

    if [ "$MAJOR" -lt 3 ] || ([ "$MAJOR" -eq 3 ] && [ "$MINOR" -lt 11 ]); then
        warn "Python version $MAJOR.$MINOR found (3.11+ recommended)"
    else
        success "Python $VERSION"
    fi
else
    error "Python not found"
fi

# Git
if command -v git &> /dev/null; then
    VERSION=$(git --version)
    success "Git installed: $VERSION"
else
    error "Git not found"
fi

# uv
if command -v uv &> /dev/null; then
    VERSION=$(uv --version)
    success "uv installed: $VERSION"
else
    warn "uv not found (Python package manager)"
fi

# Claude Code
if command -v claude &> /dev/null; then
    VERSION=$(claude --version 2>&1 | head -1)
    success "Claude Code: $VERSION"
else
    warn "Claude Code not found"
fi

echo ""

# =============================================================================
# 2. amp Command Availability
# =============================================================================

echo "🔧 Checking amp Installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ -d "$AMP_HOME" ]]; then
    success "AMP_HOME exists: $AMP_HOME"
else
    error "AMP_HOME not found: $AMP_HOME"
fi

if [[ -f "$AMP_HOME/amp.sh" ]]; then
    success "amp.sh found"
else
    error "amp.sh not found at $AMP_HOME/amp.sh"
fi

if [[ -f "$AMP_HOME/amp-workspace.sh" ]]; then
    success "amp-workspace.sh found"
else
    error "amp-workspace.sh not found"
fi

# Check if amp function can be loaded
if bash -c "source '$AMP_HOME/amp.sh' 2>/dev/null && command -v amp" &> /dev/null; then
    success "amp function can be loaded successfully"

    # Check if it's in shell RC files
    RC_CONFIGURED=false
    for RC_FILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$RC_FILE" ]] && grep -q "source.*amp.sh" "$RC_FILE" 2>/dev/null; then
            RC_CONFIGURED=true
            break
        fi
    done

    if $RC_CONFIGURED; then
        success "amp configured in shell RC file"
    else
        warn "amp not configured in shell RC file"
        info "Run install.sh to configure: curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash"
    fi
else
    error "amp function cannot be loaded"
    info "amp.sh may be corrupted or invalid"
    info "Reinstall: curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash"
fi

echo ""

# =============================================================================
# 3. Script Version Check (Local vs Remote)
# =============================================================================

echo "📦 Checking Script Versions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SCRIPTS=("amp.sh" "amp-workspace.sh" "install.sh" "doctor.sh")

for script in "${SCRIPTS[@]}"; do
    LOCAL_FILE="$AMP_HOME/$script"

    if [[ ! -f "$LOCAL_FILE" ]] && [[ "$script" != "doctor.sh" ]]; then
        warn "$script not found locally"
        continue
    fi

    # Download remote version to temp
    REMOTE_CONTENT=$(curl -fsSL "$BASE_URL/$script" 2>/dev/null || echo "")

    if [[ -z "$REMOTE_CONTENT" ]]; then
        warn "Could not fetch remote $script"
        continue
    fi

    if [[ -f "$LOCAL_FILE" ]]; then
        LOCAL_CONTENT=$(cat "$LOCAL_FILE")

        if [[ "$LOCAL_CONTENT" == "$REMOTE_CONTENT" ]]; then
            success "$script is up to date"
        else
            warn "$script differs from remote version"
            info "Run 'amp update' to sync"
        fi
    else
        info "$script not installed locally (OK for doctor.sh)"
    fi
done

echo ""

# =============================================================================
# 4. Main Amplifier Repo Branch Check
# =============================================================================

echo "🌿 Checking Amplifier Repository Branch"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Use the same amplifier directory that amp uses
# Check environment variable first, then try common locations
if [[ -n "$AMP_AMPLIFIER_DIR" ]]; then
    AMPLIFIER_DIR="$AMP_AMPLIFIER_DIR"
elif [[ -d "$HOME/amplifier" ]]; then
    AMPLIFIER_DIR="$HOME/amplifier"
elif [[ -d "$AMP_HOME/main" ]]; then
    AMPLIFIER_DIR="$AMP_HOME/main"
else
    AMPLIFIER_DIR="$HOME/amplifier"  # Default fallback
fi

if [[ ! -d "$AMPLIFIER_DIR" ]]; then
    error "Amplifier repo not found (checked: $AMPLIFIER_DIR)"
    info "Run 'amp' to bootstrap"

    # Try to detect if it's in a different location
    if [[ -n "$AMP_AMPLIFIER_DIR" ]]; then
        info "AMP_AMPLIFIER_DIR is set to: $AMP_AMPLIFIER_DIR"
    fi

    # Show what was checked
    echo "  Checked locations:"
    [[ -n "$AMP_AMPLIFIER_DIR" ]] && echo "    - $AMP_AMPLIFIER_DIR (from AMP_AMPLIFIER_DIR)"
    echo "    - $HOME/amplifier"
    echo "    - $AMP_HOME/main"
else
    success "Amplifier repo found: $AMPLIFIER_DIR"
    pushd "$AMPLIFIER_DIR" > /dev/null 2>&1

    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)

    if [[ "$CURRENT_BRANCH" == "$EXPECTED_BRANCH" ]]; then
        success "Main repo on correct branch: $EXPECTED_BRANCH"
    else
        error "Main repo on wrong branch: $CURRENT_BRANCH (expected: $EXPECTED_BRANCH)"
        info "Fix with: cd $AMPLIFIER_DIR && git checkout $EXPECTED_BRANCH"
    fi

    # Check upstream tracking branch
    UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)

    if [[ -z "$UPSTREAM" ]]; then
        warn "No upstream tracking branch set for main repo"
        info "Fix with: cd $AMPLIFIER_DIR && git branch --set-upstream-to=origin/$EXPECTED_BRANCH"
    elif [[ "$UPSTREAM" == "origin/$EXPECTED_BRANCH" ]]; then
        success "Main repo upstream: $UPSTREAM ✓"
    else
        error "Main repo upstream: $UPSTREAM (expected: origin/$EXPECTED_BRANCH)"
        info "Fix with: cd $AMPLIFIER_DIR && git branch --set-upstream-to=origin/$EXPECTED_BRANCH"
    fi

    # Check if branch exists upstream
    if git rev-parse --verify "origin/$EXPECTED_BRANCH" &>/dev/null; then
        success "Branch $EXPECTED_BRANCH exists on remote"
    else
        error "Branch $EXPECTED_BRANCH not found on remote"
    fi

    # Check version relationship (same as amp quick-check)
    git fetch origin "$EXPECTED_BRANCH" --quiet 2>&1 || true
    LOCAL_SHA=$(git rev-parse --short=7 HEAD 2>/dev/null)
    REMOTE_SHA=$(git rev-parse --short=7 "origin/$EXPECTED_BRANCH" 2>/dev/null)

    if [[ "$LOCAL_SHA" == "$REMOTE_SHA" ]]; then
        success "Main repo is up to date: $LOCAL_SHA"
    else
        # Use git ancestry to determine relationship
        if git merge-base --is-ancestor HEAD "origin/$EXPECTED_BRANCH" 2>/dev/null; then
            warn "Main repo behind remote: $LOCAL_SHA → $REMOTE_SHA"
            info "Run 'amp update' to update"
        elif git merge-base --is-ancestor "origin/$EXPECTED_BRANCH" HEAD 2>/dev/null; then
            success "Main repo ahead of remote: $LOCAL_SHA (development mode)"
        else
            warn "Main repo diverged from remote: $LOCAL_SHA ↔ $REMOTE_SHA"
            info "Run 'amp update' to sync (may require merge/rebase)"
        fi
    fi

    popd > /dev/null 2>&1
fi

echo ""

# =============================================================================
# 5. Worktree Branch and Origin Checks
# =============================================================================

echo "🌲 Checking Project Worktrees"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

WORKTREE_DIR="$AMP_HOME/w"

if [[ ! -d "$WORKTREE_DIR" ]]; then
    info "No worktrees found (none created yet)"
else
    WORKTREES=()
    while IFS= read -r -d '' worktree; do
        WORKTREES+=("$worktree")
    done < <(find "$WORKTREE_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

    if [[ ${#WORKTREES[@]} -eq 0 ]]; then
        info "No worktrees found"
    else
        echo "Found ${#WORKTREES[@]} worktree(s):"
        echo ""

        for worktree in "${WORKTREES[@]}"; do
            WORKTREE_NAME=$(basename "$worktree")
            echo "  📁 $WORKTREE_NAME"

            pushd "$worktree" > /dev/null 2>&1

            # Check if it's a valid git worktree
            if [[ ! -f ".git" ]] || ! grep -q "gitdir:" ".git" 2>/dev/null; then
                error "    Not a valid git worktree"
                popd > /dev/null 2>&1
                continue
            fi

            # Check current branch
            CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)

            # Workspace branches are named like "workspace/{path}" and are valid
            if [[ "$CURRENT_BRANCH" == "$EXPECTED_BRANCH" ]]; then
                success "    Branch: $EXPECTED_BRANCH ✓"
            elif [[ "$CURRENT_BRANCH" == workspace/* ]]; then
                success "    Branch: $CURRENT_BRANCH (workspace branch) ✓"
            else
                error "    Branch: $CURRENT_BRANCH (expected: $EXPECTED_BRANCH or workspace/*)"
                info "    Fix with: cd $worktree && git checkout $EXPECTED_BRANCH"
            fi

            # Check upstream tracking branch
            UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)

            if [[ -z "$UPSTREAM" ]]; then
                warn "    No upstream tracking branch set"
                info "    Fix with: cd $worktree && git branch --set-upstream-to=origin/$EXPECTED_BRANCH"
            elif [[ "$UPSTREAM" == "origin/$EXPECTED_BRANCH" ]]; then
                success "    Upstream: $UPSTREAM ✓"
            else
                error "    Upstream: $UPSTREAM (expected: origin/$EXPECTED_BRANCH)"
                info "    Fix with: cd $worktree && git branch --set-upstream-to=origin/$EXPECTED_BRANCH"
            fi

            # Check origin URL
            ORIGIN_URL=$(git remote get-url origin 2>/dev/null || echo "")

            if [[ -z "$ORIGIN_URL" ]]; then
                error "    No origin remote configured"
            elif [[ "$ORIGIN_URL" == *"amplifier"* ]]; then
                success "    Origin: $ORIGIN_URL ✓"
            else
                warn "    Origin: $ORIGIN_URL (unexpected URL)"
                info "    Expected URL containing 'amplifier'"
            fi

            # Check if worktree is in sync with main repo
            if [[ -d "$AMPLIFIER_DIR/.git" ]]; then
                WORKTREE_SHA=$(git rev-parse HEAD 2>/dev/null)
                MAIN_SHA=$(cd "$AMPLIFIER_DIR" && git rev-parse HEAD 2>/dev/null)

                if [[ "$WORKTREE_SHA" == "$MAIN_SHA" ]]; then
                    success "    In sync with main repo"
                else
                    warn "    Out of sync with main repo"
                    info "    Run 'amp update' to sync"
                fi
            fi

            # Check Claude Code settings configuration
            SETTINGS_FILE="$worktree/.claude/settings.local.json"

            if [[ ! -f "$SETTINGS_FILE" ]]; then
                warn "    settings.local.json not found"
                info "    Run 'amp' in this workspace to configure"
            else
                # Check if marketplace and plugin are configured
                SETTINGS_OK=true

                # Check for amplifier-setup marketplace
                if ! grep -q "amplifier-setup" "$SETTINGS_FILE" 2>/dev/null; then
                    warn "    amplifier-setup marketplace not configured"
                    SETTINGS_OK=false
                fi

                # Check for git plugin enabled
                if ! grep -q "git@amplifier-setup" "$SETTINGS_FILE" 2>/dev/null; then
                    warn "    git plugin not enabled"
                    SETTINGS_OK=false
                fi

                if $SETTINGS_OK; then
                    success "    Claude Code settings configured ✓"
                else
                    info "    Run 'amp' in this workspace to fix settings"
                fi
            fi

            popd > /dev/null 2>&1
            echo ""
        done
    fi
fi

echo ""

# =============================================================================
# 6. Git Plugin Verification (via amp)
# =============================================================================

echo "🔌 Verifying Git Plugin via amp"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if ! command -v amp &> /dev/null; then
    warn "amp command not available, skipping plugin verification"
else
    # Create a temporary verification script
    VERIFY_SCRIPT=$(mktemp)
    cat > "$VERIFY_SCRIPT" <<'EOF'
#!/usr/bin/env bash
# Verify git plugin is installed and working

# Check if git plugin is installed
if ! claude plugin list 2>/dev/null | grep -q "git"; then
    echo "ERROR: git plugin not installed"
    exit 1
fi

# Check if submit-pr command exists
if ! claude plugin list 2>/dev/null | grep -A 20 "git" | grep -q "submit-pr"; then
    echo "ERROR: submit-pr command not found in git plugin"
    exit 1
fi

# Read the submit-pr command to verify phases
PLUGIN_DIR=""
if [[ -d "$HOME/.claude/plugins" ]]; then
    PLUGIN_DIR=$(find "$HOME/.claude/plugins" -type d -name "git" | head -1)
fi

if [[ -z "$PLUGIN_DIR" ]] && [[ -d ".claude/plugins" ]]; then
    PLUGIN_DIR=$(find ".claude/plugins" -type d -name "git" | head -1)
fi

if [[ -z "$PLUGIN_DIR" ]]; then
    # Try in current workspace
    if [[ -d "$AMP_HOME/w" ]]; then
        WORKSPACE_PLUGINS=$(find "$AMP_HOME/w" -type d -path "*/.claude/plugins/git" | head -1)
        if [[ -n "$WORKSPACE_PLUGINS" ]]; then
            PLUGIN_DIR="$WORKSPACE_PLUGINS"
        fi
    fi
fi

if [[ -z "$PLUGIN_DIR" ]]; then
    echo "ERROR: Could not locate git plugin directory"
    exit 1
fi

SUBMIT_PR_CMD="$PLUGIN_DIR/commands/submit-pr.md"

if [[ ! -f "$SUBMIT_PR_CMD" ]]; then
    echo "ERROR: submit-pr.md not found at $SUBMIT_PR_CMD"
    exit 1
fi

# Verify expected phases/steps
EXPECTED_STEPS=(
    "Step 1: Verify Git State"
    "Step 2: Handle Uncommitted Changes"
    "Step 3: Ensure Documentation Compliance"
    "Step 4: Push to Remote"
    "Step 5: Discover Repository PR Standards"
    "Step 6: Create Pull Request"
    "Step 7:"
    "Step 8:"
)

MISSING_STEPS=()
for step in "${EXPECTED_STEPS[@]}"; do
    if ! grep -q "$step" "$SUBMIT_PR_CMD" 2>/dev/null; then
        MISSING_STEPS+=("$step")
    fi
done

if [[ ${#MISSING_STEPS[@]} -gt 0 ]]; then
    echo "ERROR: Missing expected steps in submit-pr command:"
    for step in "${MISSING_STEPS[@]}"; do
        echo "  - $step"
    done
    exit 1
fi

# Check for key features
FEATURES=(
    "auto-merge"
    "continuous monitoring"
    "autonomous issue fixing"
    "sleep.*gh pr"
)

MISSING_FEATURES=()
for feature in "${FEATURES[@]}"; do
    if ! grep -qiE "$feature" "$SUBMIT_PR_CMD" 2>/dev/null; then
        MISSING_FEATURES+=("$feature")
    fi
done

if [[ ${#MISSING_FEATURES[@]} -gt 0 ]]; then
    echo "WARNING: Missing expected features:"
    for feature in "${MISSING_FEATURES[@]}"; do
        echo "  - $feature"
    done
fi

echo "SUCCESS"
EOF

    chmod +x "$VERIFY_SCRIPT"

    # Run verification in a subshell with amp context
    VERIFICATION_OUTPUT=$(bash -c "
        export AMP_HOME='$AMP_HOME'
        source '$AMP_HOME/amp.sh' 2>/dev/null
        $VERIFY_SCRIPT
    " 2>&1)

    VERIFICATION_EXIT=$?

    if [[ $VERIFICATION_EXIT -eq 0 ]] && [[ "$VERIFICATION_OUTPUT" == *"SUCCESS"* ]]; then
        success "git plugin installed and configured correctly"

        # Show features found
        if [[ "$VERIFICATION_OUTPUT" != *"WARNING"* ]]; then
            success "All expected features present (auto-merge, monitoring, autonomous fixing)"
        else
            warn "Some features may be missing"
            info "$(echo "$VERIFICATION_OUTPUT" | grep -A 100 "WARNING:")"
        fi
    else
        if echo "$VERIFICATION_OUTPUT" | grep -q "ERROR:"; then
            error "git plugin verification failed"
            info "$(echo "$VERIFICATION_OUTPUT" | grep "ERROR:")"
        else
            warn "Could not verify git plugin"
            info "$VERIFICATION_OUTPUT"
        fi
    fi

    # Cleanup
    rm -f "$VERIFY_SCRIPT"
fi

echo ""

# =============================================================================
# 7. Summary
# =============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Health Check Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo -e "${GREEN}✅ Success: $SUCCESS${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo -e "${RED}❌ Errors: $ERRORS${NC}"

echo ""

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}🎉 All systems go! Your amp setup is healthy.${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚡ Your amp setup is working but has minor issues.${NC}"
    echo ""
    echo "Recommended action:"
    echo "  amp update"
    exit 0
else
    echo -e "${RED}🚨 Your amp setup has issues that need attention.${NC}"
    echo ""
    echo "Recommended actions:"

    if command -v amp &> /dev/null; then
        echo "  1. Run: amp update"
        echo "  2. If issues persist: curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash"
    else
        echo "  1. Reinstall: curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash"
    fi

    echo ""
    exit 1
fi

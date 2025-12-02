#!/usr/bin/env bash
# test_amp_workspace.sh - Integration tests for amp-workspace.sh
#
# Usage:
#   ./tests/test_amp_workspace.sh
#
# Tests:
#   - Script sourcing without errors
#   - Marketplace configuration on fresh settings
#   - Marketplace configuration preserves existing settings
#   - Marketplace configuration is idempotent
#   - Workspace name generation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Test temp directory
TEST_DIR=""

# ============================================================================
# Test Helpers
# ============================================================================

setup() {
    TEST_DIR=$(mktemp -d)
    echo "Test directory: $TEST_DIR"
}

teardown() {
    if [[ -n "$TEST_DIR" ]] && [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

pass() {
    local test_name="$1"
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

fail() {
    local test_name="$1"
    local message="${2:-}"
    echo -e "${RED}✗${NC} $test_name"
    if [[ -n "$message" ]]; then
        echo -e "  ${RED}$message${NC}"
    fi
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$expected' but got '$actual'}"

    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo "$message" >&2
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected to find '$needle' in output}"

    if echo "$haystack" | grep -q "$needle"; then
        return 0
    else
        echo "$message" >&2
        return 1
    fi
}

assert_file_contains() {
    local file="$1"
    local needle="$2"
    local message="${3:-Expected to find '$needle' in $file}"

    if grep -q "$needle" "$file" 2>/dev/null; then
        return 0
    else
        echo "$message" >&2
        return 1
    fi
}

# ============================================================================
# Tests
# ============================================================================

test_scripts_source_without_errors() {
    local test_name="Scripts source without errors"

    if source "$REPO_DIR/amp-workspace.sh" 2>/dev/null; then
        pass "$test_name"
    else
        fail "$test_name" "Failed to source amp-workspace.sh"
    fi
}

test_workspace_name_generation() {
    local test_name="Workspace name generation"

    source "$REPO_DIR/amp-workspace.sh"

    local result
    result=$(_amp_workspace_name "/Users/ken/workspace/my-project")

    if assert_equals "Users-ken-workspace-my-project" "$result"; then
        pass "$test_name"
    else
        fail "$test_name" "Got: $result"
    fi
}

test_workspace_name_strips_leading_slash() {
    local test_name="Workspace name strips leading slash"

    source "$REPO_DIR/amp-workspace.sh"

    local result
    result=$(_amp_workspace_name "/home/user/projects/foo")

    # Should not start with a dash
    if [[ "$result" != -* ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Name starts with dash: $result"
    fi
}

test_configure_marketplace_fresh_settings() {
    local test_name="Configure marketplace on fresh settings"

    source "$REPO_DIR/amp-workspace.sh"

    # Create test worktree with minimal settings
    local worktree="$TEST_DIR/fresh-worktree"
    mkdir -p "$worktree/.claude"
    echo '{}' > "$worktree/.claude/settings.local.json"

    # Run configuration
    _amp_configure_marketplace "$worktree" > /dev/null 2>&1

    # Verify marketplace was added
    if assert_file_contains "$worktree/.claude/settings.local.json" "extraKnownMarketplaces"; then
        if assert_file_contains "$worktree/.claude/settings.local.json" "kenotron-ms/amplifier-setup"; then
            pass "$test_name"
        else
            fail "$test_name" "Marketplace repo not found in settings"
        fi
    else
        fail "$test_name" "extraKnownMarketplaces not found in settings"
    fi
}

test_configure_marketplace_preserves_existing() {
    local test_name="Configure marketplace preserves existing settings"

    source "$REPO_DIR/amp-workspace.sh"

    # Create test worktree with existing settings
    local worktree="$TEST_DIR/existing-worktree"
    mkdir -p "$worktree/.claude"
    cat > "$worktree/.claude/settings.local.json" << 'EOF'
{
  "permissions": {
    "allow": ["Bash", "Read"],
    "deny": ["Write"]
  },
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command", "command": "echo hello"}]}]
  }
}
EOF

    # Run configuration
    _amp_configure_marketplace "$worktree" > /dev/null 2>&1

    # Verify existing settings preserved
    local settings
    settings=$(cat "$worktree/.claude/settings.local.json")

    if assert_contains "$settings" '"allow"' && \
       assert_contains "$settings" '"Bash"' && \
       assert_contains "$settings" '"deny"' && \
       assert_contains "$settings" '"hooks"' && \
       assert_contains "$settings" "extraKnownMarketplaces"; then
        pass "$test_name"
    else
        fail "$test_name" "Existing settings not preserved"
    fi
}

test_configure_marketplace_idempotent() {
    local test_name="Configure marketplace is idempotent"

    source "$REPO_DIR/amp-workspace.sh"

    # Create test worktree
    local worktree="$TEST_DIR/idempotent-worktree"
    mkdir -p "$worktree/.claude"
    echo '{}' > "$worktree/.claude/settings.local.json"

    # Run configuration twice
    _amp_configure_marketplace "$worktree" > /dev/null 2>&1
    local first_run
    first_run=$(cat "$worktree/.claude/settings.local.json")

    _amp_configure_marketplace "$worktree" > /dev/null 2>&1
    local second_run
    second_run=$(cat "$worktree/.claude/settings.local.json")

    # Verify output is identical
    if assert_equals "$first_run" "$second_run"; then
        # Also verify only one marketplace entry (check for the key, not the repo name)
        local count
        count=$(grep -c '"amplifier-setup":' "$worktree/.claude/settings.local.json")
        if [[ "$count" -eq 1 ]]; then
            pass "$test_name"
        else
            fail "$test_name" "Found $count marketplace entries (expected 1)"
        fi
    else
        fail "$test_name" "Settings changed on second run"
    fi
}

test_configure_marketplace_creates_claude_dir() {
    local test_name="Configure marketplace creates .claude directory"

    source "$REPO_DIR/amp-workspace.sh"

    # Create test worktree without .claude dir
    local worktree="$TEST_DIR/no-claude-dir"
    mkdir -p "$worktree"

    # Run configuration
    _amp_configure_marketplace "$worktree" > /dev/null 2>&1

    # Verify .claude dir and settings.local.json created
    if [[ -d "$worktree/.claude" ]] && [[ -f "$worktree/.claude/settings.local.json" ]]; then
        pass "$test_name"
    else
        fail "$test_name" ".claude directory or settings.local.json not created"
    fi
}

test_configure_marketplace_handles_malformed_json() {
    local test_name="Configure marketplace handles malformed JSON"

    source "$REPO_DIR/amp-workspace.sh"

    # Create test worktree with malformed JSON
    local worktree="$TEST_DIR/malformed-worktree"
    mkdir -p "$worktree/.claude"
    echo 'not valid json {{{' > "$worktree/.claude/settings.local.json"

    # Run configuration (should recover)
    _amp_configure_marketplace "$worktree" > /dev/null 2>&1

    # Verify valid JSON was written
    if python3 -c "import json; json.load(open('$worktree/.claude/settings.local.json'))" 2>/dev/null; then
        if assert_file_contains "$worktree/.claude/settings.local.json" "extraKnownMarketplaces"; then
            pass "$test_name"
        else
            fail "$test_name" "Marketplace not configured after recovery"
        fi
    else
        fail "$test_name" "settings.local.json is not valid JSON"
    fi
}

test_configure_marketplace_enables_gitflow_plugin() {
    local test_name="Configure marketplace enables git-flow plugin"

    source "$REPO_DIR/amp-workspace.sh"

    # Create test worktree with minimal settings
    local worktree="$TEST_DIR/gitflow-worktree"
    mkdir -p "$worktree/.claude"
    echo '{}' > "$worktree/.claude/settings.local.json"

    # Run configuration
    _amp_configure_marketplace "$worktree" > /dev/null 2>&1

    # Verify enabledPlugins was added with git-flow
    if assert_file_contains "$worktree/.claude/settings.local.json" "enabledPlugins"; then
        if assert_file_contains "$worktree/.claude/settings.local.json" "git-flow@amplifier-setup"; then
            pass "$test_name"
        else
            fail "$test_name" "git-flow@amplifier-setup not found in enabledPlugins"
        fi
    else
        fail "$test_name" "enabledPlugins not found in settings"
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo ""
    echo "Running amp-workspace.sh tests..."
    echo "================================="
    echo ""

    # Setup
    setup
    trap teardown EXIT

    # Run tests
    test_scripts_source_without_errors
    test_workspace_name_generation
    test_workspace_name_strips_leading_slash
    test_configure_marketplace_fresh_settings
    test_configure_marketplace_preserves_existing
    test_configure_marketplace_idempotent
    test_configure_marketplace_creates_claude_dir
    test_configure_marketplace_handles_malformed_json
    test_configure_marketplace_enables_gitflow_plugin

    # Summary
    echo ""
    echo "================================="
    echo "Tests run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
        exit 1
    else
        echo -e "Failed: $TESTS_FAILED"
        echo ""
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

main "$@"

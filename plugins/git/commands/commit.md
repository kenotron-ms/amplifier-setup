---
description: Create a well-formatted git commit with proper hygiene and standards
category: version-control-git
allowed-tools: Bash, Read, Grep, Glob, Task
argument-hint: [optional commit message]
---

# Git Commit

Create a well-formatted git commit following repository conventions with proper commit hygiene.

**🎯 Smart Standards Discovery**: This command automatically discovers and follows repository-specific commit standards by reading documentation files (`CLAUDE.md`, `CONTRIBUTING.md`, `MAINTENANCE.md`). It adapts commit messages to match each repository's conventions.

## Important: Project Directory

**All git commands must run in the actual project directory, not the Claude worktree.**

The commands will use `PROJECT_DIR` environment variable if set, otherwise fall back to the current directory (`$PWD`).

**At the start of this command, set PROJECT_DIR:**
```bash
# Use PROJECT_DIR if set, otherwise use current directory
PROJECT_DIR="${PROJECT_DIR:-$PWD}"
echo "Working in: $PROJECT_DIR"
```

**Then for all git commands, use:**
```bash
cd "$PROJECT_DIR"
git <command>
```

## Usage

```bash
# Interactive commit (analyze changes and suggest message)
/git:commit

# Commit with custom message
/git:commit "feat: add user authentication"
```

Commit message: $ARGUMENTS

---

## Workflow

Follow these steps in order:

### Step 1: Verify Git State

Run these commands to understand the current state:
```bash
cd "$PROJECT_DIR"
git status
git diff --stat
git diff --cached --stat
```

**Check:**
- If no changes (working tree clean), inform user nothing to commit
- Show both unstaged and staged changes
- Identify which files will be committed

### Step 2: Discover Commit Standards

Use **knowledge-archaeologist** agent to discover repository commit conventions:

```
Task knowledge-archaeologist: "Search for commit message standards in 
CLAUDE.md, CONTRIBUTING.md, MAINTENANCE.md. Extract:
- Commit message format (conventional commits, custom format)
- Prefix conventions (feat:, fix:, docs:, etc.)
- Message style guidelines
- Required elements (issue references, signatures)
- Examples of good commits from git log"
```

**Common patterns to look for:**
- Conventional Commits (feat:, fix:, docs:, refactor:, test:)
- Gitmoji (✨, 🐛, 📝)
- Custom prefixes
- Issue linking format (#123, Closes #123, Fixes #123)
- Sign-off requirements
- Co-author format

### Step 3: Analyze Changes

**Review git status and diff:**
```bash
cd "$PROJECT_DIR"
git status --porcelain
git diff --cached --stat
git log -5 --oneline  # See recent commit style
```

**Categorize changes:**
- New features added
- Bug fixes
- Documentation updates
- Refactoring
- Tests added/updated
- Configuration changes
- Dependencies updated

**Check for sensitive data:**
- Scan for potential secrets, API keys, credentials
- Warn if `.env`, `credentials.json`, or similar files are staged
- Ask user to confirm if sensitive files detected

### Step 4: Generate Commit Message

Based on repository standards and changes, generate appropriate commit message.

**Conventional Commits format (if repo uses it):**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `style`: Formatting, missing semicolons
- `perf`: Performance improvements
- `ci`: CI/CD changes
- `build`: Build system changes

**Example commit messages:**

```bash
# Feature with body
feat: add JWT authentication

Implement JWT-based authentication for API endpoints.
Includes token generation, validation, and refresh mechanism.

- Add JWT utilities module
- Update authentication middleware
- Add tests for token flow

# Bug fix
fix: resolve memory leak in cache implementation

The cache was not properly cleaning up expired entries,
causing memory usage to grow over time.

Closes #123

# Documentation
docs: update API documentation for auth endpoints

# Refactoring
refactor: simplify user authentication logic

# Multiple changes
feat: implement user authentication

- Add JWT token generation
- Add authentication middleware
- Update API endpoints to require auth
- Add comprehensive test coverage

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Present suggested message to user:**
```
Suggested commit message:

---
feat: add user authentication with JWT

Implement JWT-based authentication system including:
- Token generation and validation
- Refresh token mechanism  
- Authentication middleware
- Comprehensive test coverage

Files changed:
- src/auth.py (new file, 245 lines)
- src/middleware.py (modified, +67 lines)
- tests/test_auth.py (new file, 156 lines)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
---

Accept this message? 
1. Yes, commit with this message
2. Edit the message
3. Cancel commit

Your choice: _
```

### Step 5: Stage Files

**If files are already staged:**
```bash
cd "$PROJECT_DIR"
git diff --cached --name-only
echo "Files already staged"
```

**If no files staged (stage all changes):**
```bash
cd "$PROJECT_DIR"
git add .
echo "Staged all changes"
```

**Verify what's staged:**
```bash
cd "$PROJECT_DIR"
git status --short
```

### Step 6: Create Commit

**Commit with message:**
```bash
cd "$PROJECT_DIR"

# Use heredoc for multi-line messages
git commit -m "$(cat <<'COMMIT_MSG'
feat: add user authentication with JWT

Implement JWT-based authentication system including:
- Token generation and validation
- Refresh token mechanism
- Authentication middleware
- Comprehensive test coverage

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
COMMIT_MSG
)"
```

**Handle pre-commit hook results:**

If hooks modify files:
```bash
# Check if pre-commit modified files
cd "$PROJECT_DIR"
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Pre-commit hooks modified files"
    echo "Modified files:"
    git status --short
    
    echo ""
    echo "Options:"
    echo "1. Amend commit with hook changes"
    echo "2. Review changes first"
    echo "3. Abort commit"
    echo ""
    echo "Your choice: _"
fi
```

If user chooses to amend:
```bash
cd "$PROJECT_DIR"
# Check authorship of last commit
AUTHOR=$(git log -1 --format='%an %ae')
echo "Last commit author: $AUTHOR"

# Only amend if it's safe
if git status | grep -q "Your branch is ahead"; then
    git add .
    git commit --amend --no-edit
    echo "✓ Commit amended with pre-commit changes"
else
    echo "⚠️  Cannot amend - commit may have been pushed or is not yours"
    echo "Creating new commit instead..."
    git add .
    git commit -m "chore: apply pre-commit hook fixes"
fi
```

### Step 7: Verify Commit

**Show commit details:**
```bash
cd "$PROJECT_DIR"
echo ""
echo "✓ Commit created successfully!"
echo ""
git log -1 --stat
echo ""
git show --name-status HEAD
```

### Step 8: Next Steps

**Inform user:**
```
✓ Changes committed successfully!

Commit: <commit-hash>
Branch: <branch-name>

Next steps:
1. Push to remote: git push
2. Create PR: /git:submit-pr
3. Continue working on feature

What would you like to do?
```

---

## Safety Checks

### Check for Sensitive Data

Before committing, scan for potential secrets:

```bash
cd "$PROJECT_DIR"

# Check staged files for common secret patterns
git diff --cached | grep -iE "(password|api_key|secret|token|credential|private_key)" 

# Warn about specific files
git diff --cached --name-only | grep -E "(.env|credentials|secrets|.*\.pem|.*\.key)$"
```

If found, warn user:
```
⚠️  Potential sensitive data detected!

Found in staged files:
- .env (environment variables)
- config/credentials.json (credentials file)

Patterns detected:
- Line 45: API_KEY = "sk-..."
- Line 67: PASSWORD = "..."

Are you sure you want to commit these files?
1. No, unstage sensitive files (git reset)
2. Yes, I've verified they're safe
3. Cancel commit

Your choice: _
```

### Prevent Committing to Main

```bash
cd "$PROJECT_DIR"
CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo "⚠️  WARNING: You're on the '$CURRENT_BRANCH' branch!"
    echo ""
    echo "It's recommended to commit on a feature branch."
    echo ""
    echo "Options:"
    echo "1. Create feature branch now (recommended)"
    echo "2. Continue committing to $CURRENT_BRANCH"
    echo "3. Cancel commit"
    echo ""
    echo "Your choice: _"
fi
```

### Large File Warning

```bash
cd "$PROJECT_DIR"

# Check for large files (>1MB)
git diff --cached --name-only | while read file; do
    if [ -f "$file" ]; then
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
        if [ "$size" -gt 1048576 ]; then
            size_human=$(numfmt --to=iec-i --suffix=B $size 2>/dev/null || echo "$size bytes")
            echo "⚠️  Large file detected: $file ($size_human)"
        fi
    fi
done
```

---

## Commit Message Guidelines

### Good Commit Messages

✅ **Clear and concise:**
```
feat: add user authentication with JWT

Implement JWT-based authentication including token generation,
validation, and refresh mechanism.
```

✅ **Explains why, not just what:**
```
fix: resolve memory leak in cache implementation

The cache was not properly cleaning up expired entries,
causing memory to grow unbounded over time.
```

✅ **Groups related changes:**
```
refactor: simplify authentication logic

- Extract JWT utilities to separate module
- Remove duplicate validation code
- Add comprehensive error handling
```

### Poor Commit Messages

❌ **Too vague:**
```
fix bug
update code
changes
```

❌ **Too detailed (should be in code):**
```
change variable name from userAuth to userAuthentication and 
update all references in auth.py lines 45, 67, 89...
```

❌ **Multiple unrelated changes:**
```
add auth + fix cache + update docs + refactor utils
```

---

## Integration with /new-feature Workflow

This command works seamlessly with the `/new-feature` workflow:

- Call `/git:commit` at any phase to commit progress
- Commit message will reflect current phase and changes
- Works with progress.md tracking
- Safe to use incrementally during feature development

**Example usage during feature development:**
```bash
# After Phase 2 (Design)
/git:commit "feat: complete architecture design for user auth"

# After Phase 4 (Implementation) - Chunk 1
/git:commit "feat: implement core authentication module"

# After Phase 4 (Implementation) - Chunk 2  
/git:commit "feat: add authentication API endpoints"

# After Phase 6 (Verification)
/git:commit "feat: complete user authentication feature

All tests passing, documentation updated, ready for deployment."
```

---

Ready to create well-formatted commits following repository standards!

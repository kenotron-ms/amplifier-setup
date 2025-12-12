---
description: Check current progress on feature development
category: development
allowed-tools: Read, Bash
---

# New Feature - Status

Check current progress on feature development and see what's been completed.

## Usage

```bash
# Check status of current feature
/new-feature:status
```

---

## Process

### Find Working Directories

```bash
echo "Searching for feature working directories..."
ls -dt ai_working/*/ 2>/dev/null | head -5
```

### Read Progress File

If multiple directories found, ask user which one.

If single directory found:

```bash
WORK_DIR=$(ls -dt ai_working/*/ 2>/dev/null | head -1)
PROGRESS_FILE="${WORK_DIR}progress.md"

if [ -f "$PROGRESS_FILE" ]; then
    cat "$PROGRESS_FILE"
else
    echo "No progress.md found. Checking for phase files..."
    ls -1 "$WORK_DIR"
fi
```

### Analyze Progress

Parse progress.md and show:
- Feature name
- Started date
- Last updated
- Overall completion percentage
- Current phase
- Completed tasks [✓]
- In-progress tasks [◐]
- Pending tasks [ ]
- Blockers

### Suggest Next Action

Based on current phase and completion status:

```
Current Status:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature: User Authentication
Started: 2025-01-05
Progress: 45% complete

Phases:
✓ 0. Discovery
✓ 1. Requirements
✓ 2. Design
✓ 3. Test Planning
◐ 4. Implementation (60% - in progress)
  Phase 5-8 pending...

Current Task: JWT token generation (Chunk 1)

Next Actions:
1. Continue implementation: /new-feature:4-implement
2. Check what's complete: cat ai_working/user-auth-2025-01-05/04-implementation.md
3. Commit progress: /git:commit

Blockers: None
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**If Phase 7 complete but Phase 8 not done:**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Phase 7 complete - Documentation done!

Next: Archive working documents
→ /new-feature:8-cleanup

This will preserve development history:
- All decisions and reasoning
- Design alternatives considered
- Complete session history

Progress: 95% → 100% after archiving
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Show Available Commands

```
Available Commands:
• /new-feature:0-discover     - Phase 0: Discovery
• /new-feature:1-requirements - Phase 1: Requirements
• /new-feature:2-design       - Phase 2: Design
• /new-feature:3-tests        - Phase 3: Test Planning
• /new-feature:4-implement    - Phase 4: Implementation
• /new-feature:5-refactor     - Phase 5: Refactoring
• /new-feature:6-verify       - Phase 6: Verification
• /new-feature:7-document     - Phase 7: Documentation
• /new-feature:8-cleanup      - Phase 8: Cleanup
• /new-feature:status         - Check progress
• /new-feature                - Root orchestrator
```

---

## No Progress Found

If no ai_working directories exist:

```
No feature development in progress.

To start a new feature:
/new-feature Add user authentication

This will guide you through the complete SDLC workflow.
```

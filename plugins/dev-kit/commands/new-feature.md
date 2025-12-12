---
description: End-to-end TDD SDLC workflow for adding features (orchestrator)
category: development
allowed-tools: TodoWrite, Read, Bash
argument-hint: [feature description or empty to resume]
---

# New Feature - Orchestrator

Complete Software Development Lifecycle (SDLC) workflow using Test-Driven Development (TDD) methodology for adding features.

## Usage

```bash
# Start new feature
/new-feature Add user authentication with JWT

# Resume existing feature
/new-feature

# Check progress
/new-feature:status
```

Feature: $ARGUMENTS

---

## Workflow Overview

```
Setup:  0. Discovery → 1. Requirements → 2. Design 
TDD:    3. Tests (RED) → 4. Implement (GREEN) → 5. Refactor
Finish: 6. Verify → 7. Document → 8. Cleanup
```

**Visual Grouping:**
```
┌─────────────────────────┐
│ SETUP                   │
│ 0→1→2                   │
└─────────────────────────┘
           ↓
┌─────────────────────────┐
│ TDD CYCLE               │
│ 3(RED)→4(GREEN)→5(REF)  │
└─────────────────────────┘
           ↓
┌─────────────────────────┐
│ FINALIZE                │
│ 6→7→8                   │
└─────────────────────────┘
```

**TDD Cycle**: RED (write tests) → GREEN (make pass) → REFACTOR (improve quality)

---

## Commands Available

Individual phase commands:

- `/new-feature:0-discover` - Phase 0: Discovery
- `/new-feature:1-requirements` - Phase 1: Requirements
- `/new-feature:2-design` - Phase 2: Design
- `/new-feature:3-tests` - Phase 3: Test Planning (TDD RED)
- `/new-feature:4-implement` - Phase 4: Implementation (TDD GREEN)
- `/new-feature:5-refactor` - Phase 5: Refactoring (TDD REFACTOR)
- `/new-feature:6-verify` - Phase 6: Verification
- `/new-feature:7-document` - Phase 7: Documentation
- `/new-feature:8-cleanup` - Phase 8: Cleanup (archive working docs)
- `/new-feature:status` - Check progress

---

## Process

### Step 1: Set Project Directory

**All operations must run in the actual project directory, not the Claude worktree.**

The commands will use `PROJECT_DIR` environment variable if set, otherwise fall back to the current directory (`$PWD`).

**At the start of this command, set PROJECT_DIR:**
```bash
# Use PROJECT_DIR if set, otherwise use current directory
PROJECT_DIR="${PROJECT_DIR:-$PWD}"
echo "Working in: $PROJECT_DIR"
```

### Step 2: Check for Existing Work

Always check for existing features first (regardless of $ARGUMENTS):

```bash
# Find existing feature directories
EXISTING=$(find ai_working -maxdepth 1 -type d -name "*-20*" 2>/dev/null | sort -r)
```

For each existing feature, read `progress.md` to extract:
- Feature name
- Started date
- Completion percentage
- Current phase

### Step 3: Clarify User Intent (Remove Ambiguity)

Use **AskUserQuestion** to determine what user wants to work on.

**Scenario A: Existing features found AND $ARGUMENTS provided**

Check if $ARGUMENTS matches any existing feature (fuzzy match).

```
question: "I found existing features. You also specified: '$ARGUMENTS'. Which would you like to work on?"
header: "Feature"
multiSelect: false
options:
  - label: "[Feature 1 Name] (XX% complete, YYYY-MM-DD)"
    description: "Resume this feature. Current phase: [Phase Name]"
  - label: "[Feature 2 Name] (XX% complete, YYYY-MM-DD)" [SIMILAR if matches $ARGUMENTS]
    description: "Resume this feature. Current phase: [Phase Name]"
  - label: "NEW: $ARGUMENTS"
    description: "Start a new feature with the description you provided"
```

**Scenario B: Existing features found, NO $ARGUMENTS**

**Even if only ONE feature exists, always ask for confirmation:**

```
question: "Which feature would you like to work on?"
header: "Feature"
multiSelect: false
options:
  - label: "[Feature 1 Name] (XX% complete, YYYY-MM-DD)"
    description: "Resume this feature. Current phase: [Phase Name]"
  - label: "[Feature 2 Name] (XX% complete, YYYY-MM-DD)" (if multiple features)
    description: "Resume this feature. Current phase: [Phase Name]"
  - (Other is automatically provided for new feature)
```

**Do NOT assume user wants to resume just because only one feature exists.**
**Always present choice, even for single feature.**

**Scenario C: NO existing features, $ARGUMENTS provided**

Confirm with user:

```
question: "Start new feature: '$ARGUMENTS'?"
header: "Confirm"
multiSelect: false
options:
  - label: "Yes, start this feature"
    description: "Begin Phase 0 (Discovery) for this feature"
  - (Other automatically provided for different description)
```

**Scenario D: NO existing features, NO $ARGUMENTS**

Ask for feature description (no AskUserQuestion needed, just prompt user).

### Step 4: Execute Based on Selection

**If user selected existing feature:**
- Load `ai_working/<feature>-<date>/progress.md`
- Show current status summary
- Identify next phase from progress
- Execute next phase command

**If user starts new feature:**
- Use provided/collected description
- Create `ai_working/<feature-name>-<YYYY-MM-DD>/`
- Execute Phase 0 (Discovery)
- Continue through phases with approval gates at Phases 1, 2, 6

### Approval Gates

**Phase 1 (Requirements)**:
- Must review and approve requirements
- Must verify assumptions
- Cannot proceed to design without approval

**Phase 2 (Design)**:
- Must review and approve architecture
- Must verify design assumptions
- Cannot proceed to test planning without approval

**Phase 6 (Verification)**:
- User must perform manual testing
- User must approve feature works correctly
- Cannot proceed to documentation without approval

---

## Philosophy

This workflow enforces:

### Test-Driven Development
- Tests written BEFORE implementation
- Implementation driven by failing tests
- Refactoring protected by passing tests

### Ruthless Simplicity
- Start minimal
- Avoid future-proofing
- Clear over clever

### Modular Design
- Self-contained modules (bricks)
- Clear interfaces (studs)
- Regeneratable from specs

---

## Working Directory Structure

```
ai_working/<feature-name>-YYYY-MM-DD/
├── progress.md              # Progress tracker
├── 00-discovery.md          # Phase 0
├── 01-requirements.md       # Phase 1
├── 02-design.md             # Phase 2
├── 03-test-plan.md          # Phase 3
├── 04-implementation.md     # Phase 4
├── 05-review.md             # Phase 5
├── 06-manual-test-plan.md   # Phase 6
├── 07-docs-checklist.md     # Phase 7
└── 08-cleanup-candidates.md # Phase 8 (optional)
```

**Temporary**: All files in ai_working/ are temporary brainstorming/tracking documents

**Permanent**: Final documentation created in Phase 7 following repository's structure
  - Content from 01, 02, 03 documented per repository patterns
  - May be combined in one doc or separate docs (adapts to repository)

---

## Tips

**For Users:**
- Review and approve at gates (Requirements, Design, Verification)
- Perform manual testing thoroughly in Phase 6
- Can commit at any phase using `/git:commit`

**For Claude Code:**
- Use TodoWrite to track each phase
- Update progress.md throughout
- Get approval before proceeding past gates
- Don't commit unless explicitly requested

---

## Troubleshooting

**"Which phase am I on?"**
- Run `/new-feature:status`

**"I want to skip a phase"**
- Not recommended, but can run specific phase command directly
- Phases have dependencies - may fail if prerequisites missing

**"I want to restart"**
- Delete or rename `ai_working/<feature>-<date>/`
- Run `/new-feature` again

---

Ready to build features following professional TDD SDLC practices!

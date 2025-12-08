# TEMPLATE for Phase Subcommands

This template shows the structure for each phase subcommand (1-9).

## File naming:
- 1-requirements.md
- 2-design.md
- 3-tests.md
- 4-implement.md
- 5-refactor.md
- 6-verify.md
- 7-document.md
- 8-deploy-prep.md
- 9-cleanup.md

## Standard Structure for Each:

```markdown
---
description: "Phase X: [Phase Name]"
category: development
allowed-tools: TodoWrite, Task, Read, Grep, Glob, Bash, Write, Edit
---

# New Feature - Phase X: [Phase Name]

[Brief description of what this phase does]

## Prerequisites

- Phase [X-1] must be complete
- Files required: ai_working/<feature>/<previous-phase-files>

## What This Phase Does

- [Key activity 1]
- [Key activity 2]
- [Key activity 3]

## Usage

```bash
/new-feature:X-[phase-name]
```

---

## Process

### Check Prerequisites

```bash
# Verify previous phase complete
WORK_DIR=$(ls -dt ai_working/*/ 2>/dev/null | head -1)
PREV_FILE="${WORK_DIR}0X-[prev-phase].md"

if [ ! -f "$PREV_FILE" ]; then
    echo "❌ Phase [X-1] must be complete first"
    echo "Run: /new-feature:[X-1]-[prev-phase]"
    exit 1
fi
```

### Update Progress

Read and update progress.md:
- Mark Phase [X-1] as complete [✓]
- Mark Phase X as in-progress [◐]
- Update overall completion %

### Execute Phase Tasks

[Phase-specific content from main workflow]

Key sections:
1. Primary task with agents
2. Create phase output file (0X-[phase].md)
3. TodoWrite tracking
4. User approval gates where needed

### Update Progress on Completion

```markdown
## Task Breakdown
X. [✓] Phase X: [Name] (100%)
```

### Present Completion

```
✓ Phase X: [Phase Name] Complete

Created: ai_working/<feature>/0X-[phase].md

Summary:
- [Achievement 1]
- [Achievement 2]
- [Achievement 3]

Next Phase: /new-feature:[X+1]-[next-phase]
```

---

## Output Files

- `ai_working/<feature>/0X-[phase].md` - Phase results
- `progress.md` - Updated progress

## Next Phase

```bash
/new-feature:[X+1]-[next-phase]
```
```

## Key Points for All Subcommands:

1. **Sequential numbering**: 0-discover, 1-requirements, 2-design, etc.
2. **Check prerequisites**: Verify previous phase complete
3. **Progress tracking**: Update progress.md at start and end
4. **Output files**: Create numbered phase file (00-discovery.md, 01-requirements.md, etc.)
5. **Next phase suggestion**: Tell user what to run next
6. **TodoWrite**: Track tasks within the phase
7. **Agent usage**: Use appropriate Amplifier agents
8. **User gates**: Get approval where needed (requirements, design)

Would you like me to create all remaining phase subcommands following this template?

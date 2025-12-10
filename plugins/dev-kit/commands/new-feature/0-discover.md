---
description: "Phase 0: Discover repository structure and context"
category: development
allowed-tools: TodoWrite, Task, Read, Grep, Glob, Bash, Write
---

# New Feature - Phase 0: Discovery

Understand the repository structure, load project-specific guidance, identify patterns and conventions.

## Template (MUST FOLLOW)

**This template MUST be followed when creating `00-discovery.md`.**

```markdown
# Discovery: Repository Context

**Created**: YYYY-MM-DD

## Project Overview

- **Name**: [from README]
- **Purpose**: [what the project does]
- **Tech Stack**: [languages, frameworks, tools]

## Repository Structure

[Directory tree with descriptions]

## Key Patterns & Conventions

### Code Organization
- [Pattern]: [how it's used]

### Naming Conventions
- Files: [convention]
- Classes: [convention]
- Functions: [convention]
- Tests: [convention]

### Testing Infrastructure

- **Framework**: [pytest, jest, etc.]
- **Test Location**: [where tests live]
- **Test Commands**: [unit, integration, e2e]
- **Coverage Tool**: [tool]
- **Coverage Target**: [X%]

## Architecture Patterns

- [Pattern]: [description and where used]

## Existing Infrastructure Systems

**CRITICAL**: Document existing systems to prevent reinventing the wheel.

### Settings/Preferences System
- **Status**: [✅ Found / ❌ Not Found]
- **Implementation**: [File-based / Database / API / None]
- **Location**: [file paths, API endpoints]
- **Interface**: [Settings type/schema - exact definition found]
- **Current usage**: [Code pattern observed in codebase]
- **Existing preferences**: [List what's already stored]

### Authentication/User System
- **Status**: [✅ Found / ❌ Not Found]
- **Implementation**: [JWT, Session, OAuth, etc. - what's currently used]
- **Location**: [file paths]
- **Current pattern**: [How it's currently implemented]

### Storage/Persistence Systems
- **Status**: [✅ Found / ❌ Not Found]
- **Database**: [PostgreSQL, SQLite, MongoDB, etc. - what exists]
- **File Storage**: [Local files, S3, etc. - what's used]
- **Caching**: [Redis, in-memory, etc. - what's in place]
- **Location**: [connections, services, file paths]

### State Management
- **Status**: [✅ Found / ❌ Not Found]
- **Library**: [Zustand, Redux, Context, Pinia, etc. - what's in use]
- **Store Location**: [file paths]
- **Current structure**: [How state is currently organized]
- **Observed pattern**: [How existing code uses the store]

### API Infrastructure
- **Status**: [✅ Found / ❌ Not Found]
- **Pattern**: [REST, GraphQL, tRPC, etc. - what's currently used]
- **Routes Location**: [where routes are defined]
- **Current endpoints**: [List existing endpoints as examples]
- **Observed patterns**: [How endpoints are currently structured]

## Project-Specific Guidelines

### From CLAUDE.md
[Key points for Claude Code development]

### From AGENTS.md
[Custom agents available and when to use them]

### From MAINTENANCE.md
[Maintenance practices and guidelines]

## Build & Deployment

- **Build Command**: [command]
- **Lint Command**: [command]
- **Format Command**: [command]
- **Deployment**: [approach]

## Dependencies & Constraints

- **Key Dependencies**: [libraries/frameworks]
- **Version Requirements**: [constraints]
- **Known Limitations**: [technical debt]

## Documentation Structure

- **Location**: [docs/, features/, in-module]
- **Format**: [markdown, rst, etc.]
- **Conventions**: [naming patterns]
- **ADRs**: [Architecture Decision Records location]
- **Examples**: [existing feature docs]

## Domain Knowledge

[Key domain concepts from README/docs]

## Development Workflow

- **Branch Strategy**: [git flow, trunk-based, etc.]
- **PR Process**: [requirements, reviewers]
- **CI/CD**: [what runs automatically]

## Feature-Specific Discoveries

**Based on feature**: [feature name/description]

### Related Existing Code Found
- [Component/Module]: [what it does, where it is]
- [Component/Module]: [what it does, where it is]

### Similar Patterns Observed
- [Pattern]: [how it's currently implemented, where found]
- [Pattern]: [how it's currently implemented, where found]

### Potentially Affected Code
- [File/Module]: [what it currently does, why feature might affect it]
- [File/Module]: [what it currently does, why feature might affect it]

### Existing Patterns Observed (Not Recommendations)
- [Pattern observed]: [description, where found, how it's currently used]
```

---

## Prerequisites

None - this is the first phase of feature development.

## What This Phase Does

- Loads project guidance files (CLAUDE.md, AGENTS.md, README.md, MAINTENANCE.md, etc.)
- Analyzes repository structure and organization
- Identifies testing infrastructure and patterns
- Discovers documentation conventions
- Maps architectural patterns
- Checks for custom Claude Code extensions

## Usage

```bash
# Start discovery for new feature
/new-feature:0-discover

# Or let root command guide you
/new-feature
```

---

## Process

Use TodoWrite to track discovery steps:

```markdown
- [ ] Working directory created
- [ ] Template loaded
- [ ] knowledge-archaeologist agent completed
- [ ] Explore agent (repo structure) completed
- [ ] Infrastructure discovery completed
- [ ] Feature-specific discovery completed
- [ ] Discovery document created from template
- [ ] Progress tracker initialized
```

### Step 1: Initialize Working Directory

Create `ai_working/<feature-name>-<YYYY-MM-DD>/` directory:

```bash
FEATURE_NAME="$(echo '$ARGUMENTS' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
DATE=$(date +%Y-%m-%d)
WORK_DIR="ai_working/${FEATURE_NAME}-${DATE}"
mkdir -p "$WORK_DIR"
echo "Created: $WORK_DIR"
```

### Step 2: Review Template FIRST

**REQUIRED**: Review the TEMPLATE section above before starting discovery.

The template defines ALL sections you MUST complete in `00-discovery.md`. Review it now to understand what information to gather.

### Step 3: Read Project Guidance Files (REQUIRED)

**REQUIRED**: Must READ these files (not just search).

**Find and READ these files:**
```bash
# Find guidance files
find . -maxdepth 3 -name "CLAUDE.md" -o -name "AGENTS.md" -o -name "README.md" \
  -o -name "MAINTENANCE.md" -o -name "CONTRIBUTING.md" -o -name "ARCHITECTURE.md"
```

**For EACH file found, use Read tool to load it into context.**

**Then use knowledge-archaeologist agent:**

```
Task knowledge-archaeologist: "I've loaded the project guidance files. Extract and
summarize key information:
- Project structure and conventions
- Development guidelines and rules
- Architectural patterns to follow
- Testing requirements
- Any files referenced with @ syntax (like @ai_context/IMPLEMENTATION_PHILOSOPHY.md)

If guidance files reference other important files (with @ or explicit mentions),
READ those files too and include their key points."
```

**Wait for agent to complete.**

**After agent completes:**
- If agent found referenced files (like @ai_context/IMPLEMENTATION_PHILOSOPHY.md), READ those files too
- Load all critical project rules and philosophies into context
- Document findings from all read files

### Step 4: Understand Repository Structure (REQUIRED AGENT)

**REQUIRED**: Must use **Explore** agent.

```
Task Explore: "Analyze repository structure to understand:
- Directory organization and module layout
- Language(s) and frameworks used
- Build and test infrastructure
- Configuration management approach
- Key architectural patterns
- Documentation structure and location

CRITICAL: Be purely OBSERVATIONAL. Document what exists, where it is,
how it's currently structured. Do NOT make recommendations or suggest
what to do. Just report facts about the current state.

thoroughness: medium"
```

**Wait for agent to complete.** Document findings OBSERVATIONALLY.

### Step 5: Discover Common Infrastructure (REQUIRED)

**REQUIRED**: Must search for common infrastructure systems.

Use **Grep** and **Glob** to search for:

**Settings/Preferences System**:
```bash
# Search for settings, preferences, config systems
grep -r "settings" --include="*.ts" --include="*.js" --include="*.py" src/ api/ backend/
grep -r "preferences" --include="*.ts" --include="*.js" --include="*.py" src/ api/ backend/
# Look for settings files
find . -name "*settings*" -o -name "*preferences*" -o -name "*config*"
```

**Authentication/User System**:
```bash
grep -r "auth" --include="*.ts" --include="*.js" --include="*.py" src/ api/ backend/
grep -r "user" --include="*.ts" --include="*.js" --include="*.py" src/ api/ backend/
```

**Storage/Persistence Systems**:
```bash
grep -r "storage" --include="*.ts" --include="*.js" --include="*.py" src/ api/ backend/
grep -r "persist" --include="*.ts" --include="*.js" --include="*.py" src/ api/ backend/
```

**State Management**:
```bash
# For React: Zustand, Redux, Context
grep -r "zustand\|redux\|createContext" --include="*.ts" --include="*.tsx" src/
```

**API Patterns**:
```bash
# Find API route definitions
find . -name "*routes*" -o -name "*api*" | grep -E "\.(ts|js|py)$"
```

**Document all findings** - you'll need them for the discovery document.

### Step 6: Discover Feature-Specific Patterns (REQUIRED AGENT)

**REQUIRED**: Must search for patterns relevant to this specific feature.

Extract keywords from feature description ($ARGUMENTS).

```
Task Explore: "Search for code related to [feature keywords extracted from '$ARGUMENTS'].
Find and DOCUMENT (observationally):
- Existing implementations related to this feature
- Patterns currently in use in the codebase
- Components that exist in this area

CRITICAL: Be purely OBSERVATIONAL. Document what exists, where it is, how it
currently works. Do NOT make recommendations, do NOT suggest what to use,
do NOT say 'should follow this pattern'. Just report facts.

thoroughness: medium"
```

**Wait for agent to complete.** Document findings OBSERVATIONALLY (no recommendations).

### Step 7: Create Discovery Document (FOLLOW TEMPLATE ABOVE)

**REQUIRED**: Must create `00-discovery.md` following the TEMPLATE section above.

**CRITICAL - Discovery is OBSERVATIONAL ONLY:**
- ✅ Document what EXISTS (factual)
- ✅ Document where things ARE LOCATED (factual)
- ✅ Document how things CURRENTLY WORK (observational)
- ✅ Document patterns OBSERVED in code (descriptive)
- ❌ Do NOT recommend what to use
- ❌ Do NOT suggest which pattern to follow
- ❌ Do NOT say "should use this approach"
- ❌ Do NOT make architecture decisions
- ❌ Do NOT include "Next Steps" section
- ❌ Do NOT include "Recommendations" section
- ❌ Do NOT say what actions to take
- ❌ Do NOT define implementation tasks

**Discovery documents WHAT IS, not WHAT TO DO.**

**Example of CORRECT (observational):**
```
- localStorage Pattern observed:
  - workspaceMode stored in localStorage (useStore.ts:85)
  - Retrieved on initialization, persisted on change (lines 163-166)
```

**Example of WRONG (prescriptive):**
```
- localStorage Pattern:
  - workspaceMode stored in localStorage
  - **Same pattern should be used for dock state** ← NO! This is design, not discovery
```

1. **Copy template structure** from TEMPLATE section above
2. **Create** `ai_working/<feature>-<date>/00-discovery.md`
3. **Fill in ALL sections** with FACTUAL OBSERVATIONS from Steps 3-6:
   - Project Overview (from Step 3)
   - Repository Structure (from Step 4)
   - Key Patterns & Conventions (from Step 4)
   - Testing Infrastructure (from Step 4)
   - Architecture Patterns (from Step 4)
   - **Existing Infrastructure Systems** (from Step 5)
   - Documentation Structure (from Step 4)
   - **Feature-Specific Discoveries** (from Step 6)
   - Build & Deployment, Dependencies, Domain Knowledge

**Verification**: Check that discovery document has ALL template sections completed.

### Step 8: Initialize Progress Tracking (REQUIRED)

**REQUIRED**: Always create `ai_working/<feature-name>-<YYYY-MM-DD>/progress.md`:

```markdown
# Feature Progress: [Feature Name]

**Started**: YYYY-MM-DD
**Last Updated**: YYYY-MM-DD
**Overall Completion**: 5%

## Summary
[Brief feature description from user request]

## Phase States

**Status Symbols:**
- `[ ]` = Not started
- `[→]` = In progress
- `[⏸]` = Pending approval
- `[✓]` = Completed

## Task Breakdown

### High-Level Tasks
1. [⏸] Phase 0: Discovery - PENDING APPROVAL (work complete, awaiting user confirmation)
2. [ ] Phase 1: Requirements (0%)
3. [ ] Phase 2: Design (0%)
4. [ ] Phase 3: Test Planning (0%)
5. [ ] Phase 4: Implementation (0%)
6. [ ] Phase 5: Refactoring (0%)
7. [ ] Phase 6: Verification (0%)
8. [ ] Phase 7: Documentation (0%)
9. [ ] Phase 8: Cleanup (0%)

## Current Session Notes

**Focus**: Discovery phase (in progress)

**Completed This Session**:
- Repository structure analyzed
- Project guidance loaded
- Testing infrastructure identified
- Documentation patterns discovered
- Discovery document created

**Status**: PENDING USER APPROVAL

**Next Actions**:
1. User to review discovery document
2. User to confirm ready to proceed
3. After approval: Mark Phase 0 complete, proceed to Phase 1

## Session History

### Session 1 (YYYY-MM-DD)
- Completed discovery work
- Status: Pending approval
- **Progress**: 0% → 5% (pending)
```

Progress tracking is created for ALL features to maintain consistency and enable easy resumption of work.

### Step 9: Present Summary and Request Approval

**REQUIRED**: Present summary and WAIT for user approval.

Update `progress.md` to mark Phase 0 as PENDING APPROVAL:
```markdown
1. [⏸] Phase 0: Discovery - PENDING APPROVAL
```

Share findings with user:

```
**Discovery Work Complete - Review Required**

I've analyzed the repository and loaded project context:

- **Project**: [name and purpose]
- **Tech Stack**: [key technologies]
- **Testing**: [framework and approach]
- **Documentation**: [where feature docs live and format]
- **Infrastructure Found**: [settings, auth, storage, state, API]
- **Feature-Specific**: [related code, patterns observed]
- **Guidelines**: [from CLAUDE.md/MAINTENANCE.md]

Discovery document: `ai_working/<feature-name>-<YYYY-MM-DD>/00-discovery.md`

Please review the discovery document.

Is the discovery complete and accurate?
1. Yes, approved - proceed to requirements
2. No, I see issues - let me provide corrections
3. Let me review the document first

Your choice: _
```

### Step 10: After User Approval

**ONLY after user approves:**

Update `progress.md`:
```markdown
1. [✓] Phase 0: Discovery (100%) - APPROVED
2. [→] Phase 1: Requirements (0%) - Starting
```

Then suggest:
```
✓ Phase 0 approved!

Next: /new-feature:1-requirements
```

---

## Output Files

- `ai_working/<feature-name>-<YYYY-MM-DD>/00-discovery.md` - Discovery findings
- `ai_working/<feature-name>-<YYYY-MM-DD>/progress.md` - Progress tracker

## Next Phase

After discovery is complete and approved:

```bash
/new-feature:1-requirements
```

Or continue with root orchestrator:

```bash
/new-feature
```

---
description: "Phase 2: Design architecture and technical approach"
category: development
allowed-tools: TodoWrite, Task, Read, Grep, Glob, Write
---

# New Feature - Phase 2: Design & Architecture

Plan the technical solution: architecture, modules, interfaces, and alternatives.

## Template (MUST FOLLOW)

**This template MUST be followed when creating `02-design.md`.**

```markdown
# Architecture Design: [Feature]

**Based on**: 01-requirements.md
**Created**: YYYY-MM-DD

## Quick Reference

**For quick lookup - full details below.**

- **Approach**: [One sentence summary]
- **Key Modules**: [Module1, Module2, Module3]
- **Key Technologies**: [Libraries/frameworks used]
- **Key Decisions**:
  - [Decision 1]: [Why]
  - [Decision 2]: [Why]
  - [Decision 3]: [Why]

---

## References

- **Requirements**: `[path to requirements doc in target repository]`
- **Related**: [Links to related design docs, ADRs, etc.]

---

## Executive Summary

[2-3 sentence summary of the chosen approach and why]

## Alternatives Considered

### Alternative 1: [Name]
- **Approach**: [Description]
- **Pros**: [benefits]
- **Cons**: [drawbacks]
- **Testability**: [assessment]
- **Complexity**: [Low/Medium/High]

### Alternative 2: [Name]
- **Approach**: [Description]
- **Pros**: [benefits]
- **Cons**: [drawbacks]
- **Testability**: [assessment]
- **Complexity**: [level]

...

## Recommended Approach

**Choice**: Alternative [X]

**Justification**:
- [Reason 1]
- [Reason 2]
- [Reason 3]

**Trade-offs accepted**:
- [Trade-off 1 and why it's acceptable]
- [Trade-off 2 and why it's acceptable]

---

## Architecture Overview

**Quick Reference**: High-level architecture at a glance.

### System Context Diagram

Use Mermaid to show high-level system components:

\`\`\`mermaid
graph LR
    Client[Client/User] -->|requests| System[Feature System]
    System --> DB[(Database)]
    System --> External[External Services]
\`\`\`

### Component Diagram

Show internal modules and relationships:

\`\`\`mermaid
graph TD
    ModuleA[Module A] --> ModuleB[Module B]
    ModuleA --> ModuleC[Module C]
    ModuleB --> DB[(Storage)]
\`\`\`

### Key Flows

Document 1-3 critical flows with sequence diagrams:

\`\`\`mermaid
sequenceDiagram
    User->>System: action
    System->>Module: process
    Module->>DB: store
    DB-->>User: result
\`\`\`

### Key Decisions Summary

Bullet list (5-7 items):
- [Technology choice]: [why]
- [Architecture pattern]: [why]
- [Data storage strategy]: [why]

---

## Module Design

### Module: [Name]
- **Purpose**: [Single responsibility]
- **Location**: `path/to/module.py`
- **Inputs**: [What it receives with types]
- **Outputs**: [What it produces with types]
- **Side Effects**: [DB writes, API calls, file operations]
- **Dependencies**: [What it needs]
- **Public Interface**: [Key functions/methods]

### Module: [Name 2]
[Repeat structure]

## Data Models

\`\`\`language
class ModelName:
    field1: Type  # description
    field2: Type  # description
\`\`\`

## API Contracts

\`\`\`language
def function_name(input: Type) -> OutputType:
    """Brief description"""
\`\`\`

## Integration Points

### Integration: [System Name]
- **Connection Point**: [Where/how they connect]
- **Data Flow**: [What's exchanged]
- **Dependencies**: [What's required]

## Philosophy Alignment

### Ruthless Simplicity
- Start minimal: [specific examples]
- Avoid future-proofing: [what we're NOT building]
- Clear over clever: [how we keep it simple]

### Modular Design
- Bricks: [self-contained modules]
- Studs: [connection points]
- Regeneratable: [can rebuild from specs]

## Files to Modify

- [ ] `path/to/file1.ext` - [what changes]
- [ ] `path/to/file2.ext` - [what changes]

## Files to Create

### Production Code
- [ ] `path/to/module/__init__.py` - [purpose]
- [ ] `path/to/module/core.py` - [purpose]

### Tests
- [ ] `tests/unit/test_module.py` - [purpose]
- [ ] `tests/integration/test_module.py` - [purpose]
- [ ] `tests/e2e/test_feature.py` - [purpose]

## Design Assumptions

**IMPORTANT**: Document all assumptions made during design.

### Architecture Assumptions
1. [Assumption]
   - **Why**: [Reasoning]
   - **Impact if wrong**: [What changes]
   - **Alternative**: [Other option]

### Integration Assumptions
1. [Assumption]
   - **Why**: [Reasoning]
   - **Impact if wrong**: [What changes]

### Performance Assumptions
1. [Assumption]
   - **Why**: [Reasoning]
   - **Impact if wrong**: [What changes]

### Security Assumptions
1. [Assumption]
   - **Why**: [Reasoning]
   - **Impact if wrong**: [What changes]

**Review all assumptions carefully. Correcting now prevents expensive redesign later.**

---

## Deployment Considerations

**Note**: If feature requires no special deployment, state: "No special deployment needed - standard code deployment applies."

### Configuration Changes
[Environment variables, config files that need updating]
[If none needed, state: "No configuration changes required"]

### Database Migrations
[Migration scripts needed, if any]
[If none needed, state: "No database changes"]

### Deployment Steps
[Any special steps beyond standard deployment]
[If none needed, state: "Standard deployment process applies"]

### Rollback Plan
[How to rollback if issues occur]
[Minimum: "Revert commit [hash]"]

### Monitoring & Verification
[Key metrics to watch post-deployment, verification steps]
[If standard monitoring sufficient, state: "Standard application monitoring applies"]
```

---

## Prerequisites

- Phase 1 (Requirements) must be complete and approved
- Required files:
  - `ai_working/<feature>-<date>/01-requirements.md`
  - `progress.md`

## Objectives

- Design the technical solution
- Plan module boundaries and interfaces
- Evaluate alternatives and tradeoffs
- Align with architectural principles
- Create testable design
- Document all design assumptions

---

## Process

Update TodoWrite:

```markdown
- [ ] Codebase analysis complete
- [ ] Architecture designed
- [ ] Design alternatives evaluated
- [ ] Architecture overview created
- [ ] Testability verified
- [ ] Design assumptions documented
- [ ] Design review approved
```

### Step 1: Analyze Codebase (REQUIRED AGENT)

**REQUIRED**: Must use **Explore** agent.

```
Task Explore: "Analyze the codebase to understand current architecture related
to [feature area]. Identify patterns, conventions, module structure, testing
approaches, and relevant files. thoroughness: medium"
```

**Wait for agent to complete.** Document findings.

### Step 2: Architecture Design (REQUIRED AGENT)

**REQUIRED**: Must use **zen-architect** agent.

```
Task zen-architect: "Design architecture for [feature] following
@ai_context/IMPLEMENTATION_PHILOSOPHY.md and @ai_context/MODULAR_DESIGN_PHILOSOPHY.md.
Consider multiple alternatives, evaluate tradeoffs, recommend best approach.
Ensure design is testable with clear contracts. Include high-level architecture
overview with Mermaid diagrams."
```

**Wait for agent to complete.** Review design proposals.

### Step 3: Create Design Document (FOLLOW TEMPLATE ABOVE)

**REQUIRED**: Must create `02-design.md` following the TEMPLATE section above.

1. **Copy template structure** from TEMPLATE section above
2. **Create** `ai_working/<feature>-<date>/02-design.md`
3. **Fill in ALL sections** with agent findings from Steps 1-2

**Sections to complete:**
- Executive summary (2-3 sentences)
- Alternatives considered (2-3 options minimum)
- Recommended approach with justification
- **Architecture Overview** (diagrams + key decisions)
- Module Design (each module with clear contracts)
- Data Models, API Contracts
- Integration Points
- Test Strategy (60/30/10 split)
- Philosophy Alignment
- Files to modify/create
- **Design Assumptions** (all assumptions with reasoning and impact)

**Focus on:**
- Clear Mermaid diagrams (system, components, 1-3 flows)
- Concrete modules with defined responsibilities
- Testable contracts
- Documenting ALL assumptions

### Step 4: Update Progress to Pending Approval

Update `progress.md` to mark Phase 2 as PENDING APPROVAL:
```markdown
2. [⏸] Phase 2: Design - PENDING APPROVAL
```

Update session notes:
- Work complete: architecture designed, alternatives evaluated
- Status: Pending user approval
- Overall completion: 20% (pending approval bump to 25%)

### Step 5: Present for Approval and WAIT

Present summary to user highlighting:
- File location
- Executive summary
- Architecture overview (diagrams)
- Number of modules, files to modify/create
- Alternatives evaluated and choice
- **All design assumptions** (by category with status: ✅ DISCOVERED, ✅ USER CONFIRMED, ❓ ASSUMPTION)
- Each assumption with: reasoning + impact if wrong

**WAIT for user response:**
```
Is the design approach approved?
1. Yes, approved - proceed to test planning
2. No, I want to correct some assumptions
3. No, I prefer a different alternative
4. Let me review the full document first

Your choice: _
```

### Step 6: After User Approval

**ONLY after user approves (option 1):**

Update `progress.md`:
```markdown
2. [✓] Phase 2: Design (100%) - APPROVED
3. [→] Phase 3: Test Planning (0%) - Starting
```

Update completion: `25%`

Then suggest:
```
✓ Phase 2 approved!

Next: /new-feature:3-tests
```

---

## Output Files

- `ai_working/<feature>-<date>/02-design.md` - Complete architecture design with diagrams and assumptions
- `progress.md` (updated) - Progress tracker

## Next Phase

After design is approved:

```bash
/new-feature:3-tests
```

---
description: "Phase 1: Define feature requirements and acceptance criteria"
category: development
allowed-tools: TodoWrite, Task, Read, Grep, Glob, Write
---

# New Feature - Phase 1: Requirements & Planning

Define what to build: user stories, acceptance criteria, scope, and constraints.

## Template (MUST FOLLOW)

**This template MUST be followed when creating `01-requirements.md`.**

```markdown
# Feature Requirements: [Name]

**Source**: [New / Based on docs/specs/file.md / User-provided / Issue #123]
**Created**: YYYY-MM-DD

## Problem Statement
[What problem are we solving and why it matters]

## User Stories
- As a [user type], I want [capability] so that [benefit]
- As a [user type], I want [capability] so that [benefit]

## Acceptance Criteria
- [ ] Criterion 1: [measurable, testable criterion]
- [ ] Criterion 2: [measurable, testable criterion]
- [ ] Criterion 3: [measurable, testable criterion]

## Success Metrics
- [Metric 1]: [Target value]
- [Metric 2]: [Target value]

## Functional Requirements
1. [Specific requirement]
2. [Specific requirement]

## Non-Functional Requirements
- Performance: [requirements]
- Security: [requirements]
- Scalability: [requirements]

## Constraints
- Technical: [constraints]
- Business: [constraints]
- Timeline: [constraints]

## Dependencies
- [System/Feature 1]: [how it's needed]
- [System/Feature 2]: [how it's needed]

## Out of Scope
[What we're explicitly NOT doing in this iteration]

## Assumptions & Verified Facts

**IMPORTANT**: Search for answers before assuming. Mark each item with status.

**Status Markers:**
- ✅ DISCOVERED = Found in 00-discovery.md
- ✅ USER CONFIRMED = User explicitly confirmed
- ✅ CONFIRMED BY CODE = Found in codebase
- ❓ ASSUMPTION = True assumption (no answer found, needs verification)

### Technical Assumptions

#### [Status] Item 1: [Topic]
**What**: [What we believe/discovered]
**Source**: [Discovery doc / Codebase / User confirmation / Educated guess]
**Impact if wrong**: [What would change]
**Verification**: [How to verify if marked ❓]

### User Behavior Assumptions

#### [Status] Item: [Topic]
**What**: [Behavior assumption]
**Source**: [Where confirmed / why assumed]
**Impact if wrong**: [What changes]

### Business Assumptions

#### [Status] Item: [Topic]
**What**: [Business logic]
**Source**: [Where confirmed / why assumed]
**Impact if wrong**: [What changes]

### Data Assumptions

#### [Status] Item: [Topic]
**What**: [Data format/structure]
**Source**: [Where confirmed / why assumed]
**Impact if wrong**: [What changes]

### Integration Assumptions

#### [Status] Item: [Topic]
**What**: [External system/API]
**Source**: [Where confirmed / why assumed]
**Impact if wrong**: [What changes]

### Scope Assumptions

#### [Status] Item: [Topic]
**What**: [Included/excluded]
**Source**: [Where confirmed / why assumed]
**Impact if wrong**: [What changes]

**Review all items. Items marked ❓ need verification before design phase.**

## References
[If based on existing documents, link them here]
- Original spec: docs/specs/feature.md
- Related issue: #123
- Previous discussion: link
```

---

## Prerequisites

- Phase 0 (Discovery) must be complete
- Required files:
  - `ai_working/<feature>-<date>/00-discovery.md`
  - `ai_working/<feature>-<date>/progress.md`

## Objectives

- Check for existing requirements documents
- Clarify feature requirements and acceptance criteria
- Define user stories and success metrics
- Understand scope and dependencies
- Document all assumptions
- Get stakeholder approval

---

## Process

Use TodoWrite to track all steps:

```markdown
- [ ] Check for existing requirements documents
- [ ] Requirements gathering complete
- [ ] User stories defined
- [ ] Acceptance criteria documented
- [ ] Scope boundaries clear
- [ ] Dependencies identified
- [ ] Assumptions documented
- [ ] Requirements approved
```

### Step 1: Check for Existing Requirements (REQUIRED AGENT)

**REQUIRED**: Must use **knowledge-archaeologist** agent to search for existing requirements.

```
Task knowledge-archaeologist: "Search for existing requirements documents,
specifications, or RFCs related to [feature name]. Look in:
- docs/ directory
- specs/ or requirements/ directories
- Issue tracker references
- Previous planning documents
- Architecture decision records (ADRs)
Extract any relevant requirements already documented."
```

**Wait for agent to complete.** Review findings.

**If existing documents found:**

```
Found potential requirements documents:
- docs/specs/user-authentication-RFC.md
- issues/#123 - User authentication feature request

Would you like to:
1. Use existing document as basis (I'll extract requirements)
2. Reference existing document but create new requirements
3. Ignore and start fresh

Your choice: _
```

**If user chooses option 1 (Use existing):**
- Read the existing document
- Extract requirements, user stories, acceptance criteria
- Ask user to fill in any gaps
- Create 01-requirements.md with extracted + new information

### Step 2: Check User-Provided Requirements

If user provided a requirements document via $ARGUMENTS or in chat:

```
I see you've provided requirements documentation.

Let me analyze it and ask clarifying questions for any gaps.
```

Use the provided document to answer initial questions before asking user.

### Step 3: Review Discovery Findings FIRST

**CRITICAL**: Before gathering requirements or making assumptions, read and review the discovery document.

Read `ai_working/<feature>-<date>/00-discovery.md` to understand:
- **Existing systems and infrastructure** - Don't assume something doesn't exist if discovery found it!
- Available APIs and services
- Current architecture and patterns
- Testing infrastructure
- Tech stack and frameworks

**When making assumptions later**, explicitly reference discovery findings:
- If discovery found a system: Acknowledge it exists, plan to extend it
- If discovery didn't find something: Note this as a discovery gap, verify with user
- Mark assumptions as "✅ DISCOVERED" vs "❓ NEEDS VERIFICATION"

### Step 4: Understand the Request

**CRITICAL - Requirements Focus on WHAT (User Needs), Not HOW (Implementation):**
- ✅ Ask about user needs and expected behavior
- ✅ Ask about business requirements (persist? sync across devices?)
- ✅ Ask about acceptance criteria and success metrics
- ❌ Do NOT ask technical implementation questions
- ❌ Do NOT ask "localStorage vs backend?" (that's Phase 2 Design)
- ❌ Do NOT ask "which API/library/pattern?" (that's Phase 2 Design)
- ❌ Do NOT include "Next Steps" or "Implementation Tasks"

**Examples:**

**CORRECT (product/user questions):**
- "Should the preference persist across browser sessions?" (user need)
- "Should it work across all user's devices?" (business requirement)
- "What should happen if save fails?" (user experience)

**WRONG (technical questions):**
- "Use localStorage or backend storage?" (implementation - decide in Phase 2)
- "Which API endpoint?" (implementation - design in Phase 2)

**If no existing requirements found**, gather user/business needs:

- What problem does this feature solve?
- Who are the users?
- What is the expected behavior?
- Should it persist across sessions? Across devices?
- What are the acceptance criteria?
- What are business/product constraints?

**If existing requirements found**, validate and fill gaps:
- Review existing requirements with user
- Identify what's clear vs unclear
- Ask only about missing PRODUCT/BUSINESS parts (not technical HOW)

### Step 5: Clarify Ambiguities (REQUIRED AGENT)

**REQUIRED**: Must use **ambiguity-guardian** agent.

```
Task ambiguity-guardian: "Review feature requirements for [feature], identify
ambiguities, contradictions, missing information, and areas needing clarification.

CRITICAL: Focus on PRODUCT/BUSINESS ambiguities, NOT technical implementation:
- ✅ Clarify user needs and expected behavior
- ✅ Clarify business rules (persist? sync? scope?)
- ✅ Clarify acceptance criteria
- ❌ Do NOT ask technical questions (storage mechanism, API choice, etc.)
- ❌ Technical decisions belong in Phase 2 (Design)

Map what we know and what we need to clarify about WHAT users need."
```

**Wait for agent to complete.** Address identified PRODUCT/BUSINESS ambiguities with user (not technical ones).

### Step 6: Verify Assumptions Before Making Them

**CRITICAL**: Before documenting ANY assumption, search for answers first.

For each potential assumption (technical, business, data, integration, scope):

**Search order:**
1. **Check discovery document** - Was this covered in 00-discovery.md?
2. **Search documentation** - Is there a doc that answers this?
   ```bash
   grep -r "[assumption topic]" docs/ README.md ARCHITECTURE.md
   ```
3. **Search codebase** - Does existing code answer this?
   ```bash
   grep -r "[assumption topic]" --include="*.ts" --include="*.py" src/ backend/
   ```
4. **Ask user if unclear** - If searches are inconclusive, ask user directly

**Document results:**
- If answer found: Mark as "✅ DISCOVERED" or "✅ CONFIRMED" (not an assumption!)
- If not found: Mark as "❓ ASSUMPTION" (needs verification)
- If user confirmed: Mark as "✅ USER CONFIRMED"

**Examples:**

Before assuming "No settings system exists":
1. Check 00-discovery.md → Found settings system ✅
2. Result: NOT an assumption, it's discovered fact!

Before assuming "Default state should be expanded":
1. Check discovery → No mention
2. Check docs → No specification
3. Ask user → User confirms "yes, expanded"
4. Result: ✅ USER CONFIRMED, not assumption

### Step 7: Create Requirements Document (FOLLOW TEMPLATE ABOVE)

**REQUIRED**: Must create `01-requirements.md` following the TEMPLATE section above.

1. **Copy template structure** from TEMPLATE section above
2. **Create** `ai_working/<feature>-<date>/01-requirements.md`
3. **Fill in ALL sections** with findings from Steps 1-6:

**Sections to complete:**
- Problem Statement
- User Stories (3-5 stories)
- Acceptance Criteria (measurable, testable)
- Success Metrics
- Functional & Non-Functional Requirements
- Constraints and Dependencies
- Out of Scope (what we're NOT doing)
- **Assumptions** (critical - but verify first!)

**When documenting "assumptions":**
- ✅ DISCOVERED = Found in discovery/docs/code
- ✅ USER CONFIRMED = User explicitly confirmed
- ✅ CONFIRMED BY CODE = Found in codebase
- ❓ ASSUMPTION = True assumption (couldn't find answer, making educated guess)

**Don't call something an assumption if you already found the answer!**

### Step 8: Update Progress to Pending Approval

Update `progress.md` to mark Phase 1 as PENDING APPROVAL:
```markdown
1. [✓] Phase 0: Discovery (100%)
2. [⏸] Phase 1: Requirements - PENDING APPROVAL
```

Update session notes:
- Work complete: requirements documented, assumptions verified
- Status: Pending user approval
- Overall completion: 10% (pending approval bump to 15%)

### Step 9: Present for Approval and WAIT

Present summary to user highlighting:
- File location
- Number of user stories, acceptance criteria
- **All assumptions made** (by category with status: ✅ DISCOVERED, ✅ USER CONFIRMED, ❓ ASSUMPTION)
- Each assumption with: reasoning + impact if wrong

**WAIT for user response:**
```
Are the requirements and assumptions correct?
1. Yes, approved - proceed to design phase
2. No, I need to correct some assumptions
3. Let me review the document first

Your choice: _
```

### Step 10: After User Approval

**ONLY after user approves (option 1):**

Update `progress.md`:
```markdown
2. [✓] Phase 1: Requirements (100%) - APPROVED
3. [→] Phase 2: Design (0%) - Starting
```

Update completion: `15%`

Then suggest:
```
✓ Phase 1 approved!

Next: /new-feature:2-design
```

---

## Output Files

- `ai_working/<feature>-<date>/01-requirements.md` - Requirements with assumptions
- `progress.md` (updated) - Progress tracker

## Next Phase

After requirements and assumptions are approved:

```bash
/new-feature:2-design
```

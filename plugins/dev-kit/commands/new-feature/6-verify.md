---
description: "Phase 6: Verify with automated and manual testing"
category: development
allowed-tools: TodoWrite, Task, Read, Write, Bash
---

# New Feature - Phase 6: Verification

Confirm all automated tests pass and generate manual test plan for user.

## Template (MUST FOLLOW)

**This template MUST be followed when creating `06-manual-test-plan.md`.**

```markdown
# Manual Test Plan: [Feature]

**Created**: YYYY-MM-DD
**For User Manual Testing**

## Prerequisites

- Environment: [development/staging]
- Setup required: [any setup steps]
- Test data: [any specific data needed]

## Test Scenarios

### Scenario 1: [Happy Path Name]

**Objective**: Verify primary user workflow

**Steps**:
1. [Step 1 with expected result]
2. [Step 2 with expected result]
3. [Step 3 with expected result]

**Expected Outcome**: [What success looks like]

**Acceptance Criteria Verified**: ✓ Criterion 1, ✓ Criterion 2

---

### Scenario 2: [Error Handling]

**Objective**: Verify error handling

**Steps**:
1. [Step to trigger error]
2. [Observe error handling]

**Expected Outcome**: [How error should be handled]

---

### Scenario 3: [Edge Case]

**Objective**: Test boundary conditions

**Steps**:
1. [Edge case steps]

**Expected Outcome**: [Expected behavior]

---

## Acceptance Criteria Checklist

- [ ] Criterion 1: [description] - Test in Scenario X
- [ ] Criterion 2: [description] - Test in Scenario Y
- [ ] Criterion 3: [description] - Test in Scenario Z

## Testing Notes

**Things to watch for**:
- [Specific behavior to observe]
- [Performance characteristics]
- [Error messages]

**Report any issues**:
- What you were doing
- What you expected
- What actually happened
- Any error messages or logs
```

---

## Prerequisites

- Phase 5 (Refactoring) must be complete (all automated tests verified GREEN in Phase 5)
- Required files:
  - `ai_working/<feature>-<date>/01-requirements.md`
  - `ai_working/<feature>-<date>/05-review.md`
  - `progress.md`

## Objectives

- Generate manual test plan for user
- User performs manual testing
- Fix any issues user finds
- Get user approval

---

## Process

Update TodoWrite:

```markdown
- [ ] Manual test plan generated
- [ ] User manual testing complete
- [ ] Issues fixed (if any)
- [ ] Acceptance criteria verified
```

**Note**: Automated tests already verified GREEN in Phase 5. This phase focuses on user manual testing.

### Step 1: Generate Manual Test Plan (FOLLOW TEMPLATE ABOVE)

**REQUIRED**: Create manual test plan for user.

1. **Copy template structure** from TEMPLATE section above
2. **Create** `ai_working/<feature>-<date>/06-manual-test-plan.md`
3. **Include**:
   - Test scenarios (happy path, errors, edge cases)
   - Step-by-step instructions for user
   - Expected outcomes
   - Acceptance criteria mapping

### Step 2: Update Progress to Pending Approval

Update `progress.md` to mark Phase 6 as PENDING APPROVAL:
```markdown
6. [⏸] Phase 6: Verification - PENDING APPROVAL (awaiting user manual testing)
```

### Step 3: Present Manual Test Plan and WAIT

Inform user:

```
All automated tests passing ✓

Manual test plan ready: ai_working/<feature>-<date>/06-manual-test-plan.md

Please test the feature as an end user and report results.

After testing, report:
1. Feature works correctly - all scenarios passed
2. I found issues (provide details)
3. Still testing

Your choice: _
```

**WAIT for user to complete manual testing.**

### Step 4: Analyze Issue and Route to Appropriate Phase

**If user reports issues (option 2), analyze root cause and route to correct phase:**

**REQUIRED**: Use **bug-hunter** agent to analyze and determine gap type.

```
Task bug-hunter: "Analyze user-reported issue and determine ROOT CAUSE.

USER REPORTED ISSUE:
[Paste user's issue description here]

ANALYSIS REQUIRED:
Read these documents to determine where the gap is:

1. ai_working/<feature>-<date>/01-requirements.md
   - Does a requirement exist for this behavior?
   - Is the expected behavior specified?

2. ai_working/<feature>-<date>/02-design.md
   - Does the design account for this scenario?
   - Is the architecture capable of handling this?

3. ai_working/<feature>-<date>/03-test-plan.md
   - Do tests exist for this behavior?
   - Is there test coverage for this scenario?

4. ai_working/<feature>-<date>/04-implementation.md
   - Is implementation following the design?
   - Where is the actual bug in the code?

5. ai_working/<feature>-<date>/00-discovery.md
   - For test commands and project context

DETERMINE GAP TYPE (pick ONE):

1. REQUIREMENTS GAP
   - Issue: Requirement doesn't specify this behavior
   - Evidence: [Quote what's missing from requirements]
   - Impact: Feature incomplete per user needs
   - Route to: Phase 1 → Update requirements → Cascade through 2,3,4

2. DESIGN GAP
   - Issue: Requirement exists but design doesn't account for it
   - Evidence: [Show requirement vs design gap]
   - Impact: Architecture can't support this
   - Route to: Phase 2 → Update design → Cascade through 3,4

3. TEST GAP
   - Issue: Requirement and design correct, but no test coverage
   - Evidence: [Show what's not tested]
   - Impact: Bug wasn't caught by tests
   - Route to: Phase 3 → Add tests

4. IMPLEMENTATION BUG
   - Issue: Tests correctly fail, implementation wrong
   - Evidence: [Show failing test]
   - Impact: Code doesn't match design
   - Route to: Phase 4 → Fix implementation

5. TEST BUG
   - Issue: Test expects wrong behavior
   - Evidence: [Show test vs requirements mismatch]
   - Impact: Test needs correction
   - Route to: Phase 3 → Fix test (requires user approval)

OUTPUT FORMAT:
Gap Type: [1-5]
Reasoning: [Your analysis]
Evidence: [Specific quotes/findings]
Recommended Route: Phase [X]
Cascade Needed: [List dependent phases that need updating]

If Phase 1 or 2, list what needs to be updated in those phases."
```

**Wait for bug-hunter analysis.**

### Step 4a: Route to Recommended Phase

Based on bug-hunter's recommendation:

**If Requirements Gap (Route to Phase 1):**
```
bug-hunter found REQUIREMENTS GAP.

Issue: [bug-hunter's findings]
Missing requirement: [what needs to be added]

Action: Update requirements in Phase 1, then cascade through ALL dependent phases.

CASCADE PATH: 1→2→3→4→5→6

Running: /new-feature:1-requirements
[After Phase 1 approved]
→ /new-feature:2-design (design reflects updated requirements)
[After Phase 2 approved]
→ /new-feature:3-tests (tests for new requirements)
[After Phase 3 complete - new tests RED]
→ /new-feature:4-implement (implement new requirements - make tests GREEN)
[After Phase 4 complete - 100% GREEN]
→ /new-feature:5-refactor (review new code for quality, security, requirements)
[After Phase 5 complete - all reviews passed]
→ Return to Phase 6 for user retest
```

**If Design Gap (Route to Phase 2):**
```
bug-hunter found DESIGN GAP.

Issue: [bug-hunter's findings]
Design needs: [what needs to be added/changed]

Action: Update design in Phase 2, then cascade.

CASCADE PATH: 2→3→4→5→6

Running: /new-feature:2-design
[After Phase 2 approved]
→ /new-feature:3-tests (tests for updated design)
[After Phase 3 complete]
→ /new-feature:4-implement (implement updated design)
[After Phase 4 complete]
→ /new-feature:5-refactor (review changes)
[After Phase 5 complete]
→ Return to Phase 6 for user retest
```

**If Test Gap (Route to Phase 3):**
```
bug-hunter found TEST GAP.

Issue: [bug-hunter's findings]
Missing tests: [what tests need to be added]

Action: Add tests in Phase 3, then cascade.

CASCADE PATH: 3→4→5→6

Running: /new-feature:3-tests
[After Phase 3 complete with new tests FAILING]
→ /new-feature:4-implement (implement to make new tests pass)
[After Phase 4 complete - 100% GREEN]
→ /new-feature:5-refactor (review new code)
[After Phase 5 complete]
→ Return to Phase 6 for user retest
```

**If Implementation Bug (Route to Phase 4):**
```
bug-hunter found IMPLEMENTATION BUG.

Issue: [bug-hunter's findings]
Bug location: [where in code]

Action: Fix implementation in Phase 4, then review in Phase 5.

CASCADE PATH: 4→5→6

Running: /new-feature:4-implement
[Fix bug until 100% GREEN]
→ /new-feature:5-refactor (review bug fix for quality/security)
[After Phase 5 complete]
→ Return to Phase 6 for user retest
```

**If Test Bug (Route to Phase 3):**
```
bug-hunter found TEST BUG.

Issue: [bug-hunter's findings]
Test expects: [wrong behavior]
Should expect: [correct behavior per requirements]

Action: Fix test in Phase 3 (requires user approval), then cascade.

CASCADE PATH: 3→4→5→6

Running: /new-feature:3-tests
[After test fixed and verified with user approval]
→ /new-feature:4-implement (if implementation needs adjustment)
[After Phase 4 complete]
→ /new-feature:5-refactor (review changes)
[After Phase 5 complete]
→ Return to Phase 6 for user retest
```

### Step 4b: Execute Phase and Cascade

**Execute the recommended phase with ALL its quality gates:**
- Phase must complete fully (all steps, all approvals)
- All dependent phases must also run (cascade)
- Return to Phase 6 only when cascade complete

**After cascade complete:**
- All changes went through proper quality gates
- All rules and checklists enforced
- Ready for user retest

### Step 4c: Return to User Retest

After phases complete, return to Step 3 (Present manual test plan and WAIT for user).

User retests with updated feature.

Iterate until user approves (option 1).

### Step 5: After User Approval

**ONLY after user confirms feature works (option 1):**

Update `progress.md`:
```markdown
6. [✓] Phase 6: Verification (100%) - APPROVED by user manual testing
7. [→] Phase 7: Documentation (0%) - Starting
```

Update completion: `85%`

Then suggest:
```
✓ Phase 6 approved! Feature verified working by user.

Next: /new-feature:7-document
```

---

## Output Files

- `ai_working/<feature>-<date>/06-manual-test-plan.md`
- All tests passing
- Acceptance criteria verified
- `progress.md` (updated)

## Next Phase

```bash
/new-feature:7-document
```

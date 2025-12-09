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

- Phase 5 (Refactoring) must be complete
- All tests must be passing
- Required files:
  - `ai_working/<feature>-<date>/05-review.md`
  - `progress.md`

## Objectives

- Verify all automated tests pass
- Generate manual test plan for user
- User performs manual testing
- Fix any issues found
- Verify acceptance criteria met

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

### Step 4: Address Issues (If Reported)

If user reports issues (option 2):
1. Analyze the problem
2. Add automated tests to reproduce (if not covered)
3. Fix the issue
4. Verify all tests still pass
5. Ask user to retest
6. Return to Step 3 (WAIT for user)

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

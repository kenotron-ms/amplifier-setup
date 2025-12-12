---
description: "Phase 4: Implement feature to make tests pass (TDD GREEN)"
category: development
allowed-tools: TodoWrite, Task, Read, Grep, Glob, Write, Edit, Bash
---

# New Feature - Phase 4: Implementation (TDD GREEN)

Write code to make all tests pass. Follow TDD cycle: RED → GREEN.

## Prerequisites

- Phase 3 (Test Planning) must be complete
- All tests must be failing (RED)
- Required files:
  - `ai_working/<feature>-<date>/01-requirements.md`
  - `ai_working/<feature>-<date>/02-design.md`
  - `ai_working/<feature>-<date>/03-test-plan.md`
  - `progress.md`

## Objectives

- Implement feature to make tests pass
- Follow TDD cycle (RED → GREEN for each test)
- Build incrementally and iteratively
- Keep implementation simple and focused

---

## Process

Update TodoWrite:

```markdown
- [ ] Verified all tests are RED (failing)
- [ ] Module 1 implemented (tests passing)
- [ ] Module 2 implemented (tests passing)
- [ ] Integration complete (tests passing)
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] All e2e tests passing
- [ ] Verified final GREEN state
```

### Step 1: VERIFY Starting in RED Phase

**CRITICAL**: Before implementing, confirm tests are failing.

Run all tests:

```bash
[test command from discovery]
```

**Must see:**
```
X unit tests FAILED
X integration tests FAILED
X e2e tests FAILED
Total: X/X tests FAILED (100% RED)
```

**If tests pass or don't run:**
- ❌ STOP - Phase 3 was not completed correctly
- ❌ Go back to Phase 3 and fix tests
- ❌ Cannot proceed with implementation

Document starting state in `04-implementation.md`:
```markdown
## Starting State (RED Phase Verified)
- Unit tests: 0/X passing (X failing) ✓
- Integration tests: 0/X passing (X failing) ✓
- E2E tests: 0/X passing (X failing) ✓

Total: 0/X passing - RED phase confirmed ✓
Ready to implement.
```

### Step 2: Implement Using TDD Cycle

Use **modular-builder** agent:

```
Task modular-builder: "Implement [module name] following 02-design.md specification.
Create self-contained module with clear contracts. Follow IMPLEMENTATION_PHILOSOPHY
and MODULAR_DESIGN_PHILOSOPHY.

TDD DISCIPLINE REQUIRED:
1. Pick ONE failing test
2. Write MINIMAL code to make THAT test pass
3. RUN the test - verify it passes
4. Document progress (X/Y tests passing)
5. Move to next failing test
6. Repeat until all tests pass

RUN tests after EVERY change. Track progress throughout.
Do NOT write all code then test - that's not TDD!"
```

**Enforce TDD cycle manually:**

For each test:
```bash
# 1. Confirm test fails
[test command] test_file.py::specific_test
# Output: FAILED ✓

# 2. Write code for that test
# (implement the function/feature)

# 3. Run test again
[test command] test_file.py::specific_test
# Output: PASSED ✓

# 4. Document progress
echo "Test specific_test: RED → GREEN ✓"
```

### Step 3: Track Implementation Progress

**CRITICAL**: Run tests frequently and track progress.

**After each function/method implemented:**
```bash
[test command] -v | grep -E "PASSED|FAILED"
```

Update `ai_working/<feature>-<date>/04-implementation.md` with current status:

```markdown
## Progress Tracking

### Module A
- [✓] test_function_1: RED → GREEN
- [✓] test_function_2: RED → GREEN
- [◐] test_function_3: Still RED (implementing now)
- [ ] test_function_4: Still RED

Tests: 2/4 passing (50%)

### Module B
- [ ] Not started yet

## Current Test Status
- Unit: 2/10 passing (20%)
- Integration: 0/5 passing (0%)
- E2E: 0/2 passing (0%)

Overall: 2/17 tests passing (12%)
```

### Step 4: Update Progress for Large Features

If feature has chunks, update `progress.md` throughout implementation:

```markdown
#### Chunk 1: [Name]
- [✓] Task 1 (tests passing)
- [◐] Task 2 (in progress, X/Y tests passing)
- [ ] Task 3
**Status**: 60% complete
```

### Step 5: Run Quality Checks (ITERATE UNTIL ALL PASS)

**REQUIRED**: Quality checks must pass before proceeding. ITERATE until all pass.

**Get commands from `00-discovery.md` → Build & Deployment section.**

**LOOP until all quality checks pass:**

**5.1. Run quality checks:**

**If unified command:**
```bash
[quality-check-command]  # e.g., npm run check, make check
```

**If separate commands:**
```bash
[type-check-command]  # e.g., tsc --noEmit, mypy
[lint-command]        # e.g., npm run lint, ruff
[format-check-command] # e.g., prettier --check, black --check
```

**5.2. Check results:**

**If ALL pass:**
```
✓ Type check: PASSED
✓ Lint: PASSED
✓ Format: PASSED

Quality checks complete → Proceed to Step 6
```

**If ANY fail:**

❌ **STOP - Do NOT proceed to Step 6**

```
Quality checks FAILED!

Failures:
- Type errors: [count]
- Lint violations: [count]
- Format issues: [count]

You MUST fix these before proceeding to test verification.

Fix now:
1. Fix type errors in code
2. Fix lint violations
3. Run formatter: [format-command]

After fixing, RETURN TO STEP 5.1 (re-run quality checks)
```

**5.3. After fixing, MUST re-run checks:**

**REQUIRED**: Re-run quality checks from 5.1 to verify fixes worked.

**Do NOT:**
- ❌ Claim "fixed" without re-running checks
- ❌ Move to Step 6 with failing quality checks
- ❌ Skip quality checks

**REPEAT Step 5.1-5.3 until ALL quality checks pass.**

**Only when ALL pass → Proceed to Step 6 (test verification).**

### Step 6: VERIFY Final GREEN State

**CRITICAL**: Run complete test suite and verify 100% passing - NO EXCEPTIONS.

Run with coverage and verbose output:

```bash
[test command with coverage and verbose]  # e.g., pytest -v --cov, npm test -- --coverage
```

**REQUIRED outcome:**
```
X unit tests PASSED
X integration tests PASSED
X e2e tests PASSED
Total: X/X tests PASSED (100% GREEN) ✓

Coverage: XX% (target: 60% unit, 30% integration, 10% e2e)
```

**Verify 100% GREEN:**
- [ ] ALL tests passing (100%, not 93% or 82%)
- [ ] Coverage targets met (60/30/10 split)
- [ ] No skipped or ignored tests
- [ ] **No flaky tests** (run multiple times to confirm - see Step 6a if flakiness detected)

**If ANY tests fail (even 1 test):**

❌ **STOP - Phase NOT complete. Do NOT mark as done.**

**Automatically attempt to fix failing tests:**

1. **Analyze failure messages** - understand what's wrong
2. **Determine root cause**:
   - Is implementation wrong? (most common)
   - Is test incorrectly written? (rare)

**CRITICAL - Do NOT change tests to match broken code:**

❌ **WRONG approach (taking shortcuts):**
```
Test expects: setDockExpanded(false)
Code does: setDockExpanded(true)
❌ Change test to expect true ← NO! This hides the bug!
```

✅ **CORRECT approach:**
```
Test expects: setDockExpanded(false)
Code does: setDockExpanded(true)
✅ Fix implementation to call setDockExpanded(false) ← YES! Fix the code!
```

**When to fix IMPLEMENTATION (99% of cases):**
- ✅ Test expects correct behavior per requirements
- ✅ Implementation doesn't match requirements
- ✅ Test is following design spec correctly
- ✅ **Default assumption: implementation is wrong**

**When to fix TEST (rare, requires careful analysis + USER APPROVAL):**
- ✅ Test has incorrect assertion (wrong expected value per requirements)
- ✅ Test doesn't match requirements document
- ✅ Test has syntax/logic errors
- ✅ Test is testing implementation details instead of behavior
- ✅ **Must verify against requirements AND get user approval before changing test!**

**Before changing ANY test, MUST consult user:**

1. **Analyze thoroughly**:
   - Re-read requirements (01-requirements.md)
   - Re-read design (02-design.md)
   - Verify test contradicts requirements

2. **Prepare justification**:
   ```
   Test needs to be changed:

   Test: [test name]
   Current assertion: [what test expects]
   Issue: [why this is wrong]

   Evidence from requirements:
   - Requirement says: [quote from 01-requirements.md]
   - Test expects: [current assertion]
   - Contradiction: [how they differ]

   Proposed fix:
   - Change: [current assertion]
   - To: [new assertion]
   - Reasoning: [why this matches requirements]

   Is this change correct?
   1. Yes, update the test
   2. No, the test is correct - fix implementation instead
   3. Let's review together

   Your choice: _
   ```

3. **WAIT for user approval** before changing test
4. **Only change test if user approves (option 1)**

**When in doubt, fix implementation, not test - ask user if unclear.**

3. **Fix implementation** (most common) - make code match test expectations (automatic)
4. **Fix tests** (rare) - only after user approves based on justification
5. **Re-run tests** to verify fix
6. **Repeat** until tests pass

**You CANNOT:**
- ❌ Mark phase complete with failing tests
- ❌ Say "functionally complete" when tests fail
- ❌ Make excuses ("test design limitations", "singleton issue", "mock interaction")
- ❌ Skip failing tests
- ❌ Proceed to Phase 5
- ❌ Ask user unless truly required

**Iterate automatically until 100% GREEN.**

**The ONLY valid exception - User Input Required:**

If tests fail because user input is truly required:

```
Tests failing due to missing user input:

[test name]: Requires API key for [service]
[test name]: Requires database connection string

REQUIRED from user:
1. [Specific input needed]: [Where to provide it]
2. [Specific input needed]: [Where to provide it]

After you provide these, I'll re-run tests to verify 100% GREEN.

Are you ready to provide this input?
1. Yes, here's the input: [user provides]
2. No, skip these tests for now (explain why)
3. Let's configure mocks instead

Your choice: _
```

**Valid user input needs:**
- ✅ API keys for external services
- ✅ Database connection strings
- ✅ Credentials only user knows

**NOT valid exceptions:**
- ❌ "Test design limitations"
- ❌ "Singleton pattern issues"
- ❌ "Mock interaction problems"

**After user provides input, re-run tests - must reach 100% GREEN.**

Document final state ONLY when 100% passing:
```markdown
## Final State (GREEN Phase Verified)
- Unit tests: X/X passing (100%) ✓
- Integration tests: X/X passing (100%) ✓
- E2E tests: X/X passing (100%) ✓

Total: X/X passing (100% GREEN) ✓
Coverage: XX%

Ready for refactoring phase.
```

**Only proceed to Phase 5 if 100% GREEN - absolutely no exceptions!**

### Step 6a: Investigate Flaky Tests (If Detected)

**If tests fail then pass on retry, this is a FLAKY test - investigate immediately and thoroughly.**

**Flaky test detected:**
```
Test: [test name]
Result: Failed on run 1, Passed on run 2
This is FLAKY behavior - NOT acceptable.
```

**REQUIRED**: Investigate root cause before proceeding.

**6a.1. Analyze the flaky test:**

Common causes of flakiness:
- Race conditions (parallel execution, async timing)
- Improper cleanup (leftover data from previous run)
- Shared state between tests
- Timing dependencies (waitForTimeout instead of conditions)
- External dependencies (network, filesystem)
- Non-deterministic test data

**6a.2. Review test code:**
- Check Test Design Checklist from Phase 3:
  - Proper cleanup in teardown?
  - Test isolation (no shared state)?
  - Condition-based waits (no arbitrary timeouts)?
  - Test-scoped resources?

**6a.3. Attempt to fix:**

Try fixes:
1. Add/improve cleanup in teardown
2. Remove shared state
3. Replace waitForTimeout with condition-based waits
4. Use test-scoped resources (separate DB per test)
5. Add proper async handling

**6a.4. Verify fix:**

Run flaky test multiple times (10x) to verify it's now deterministic:
```bash
for i in {1..10}; do
  [test-command] [specific-flaky-test]
done
```

If passes all 10 times → Fixed ✓

**6a.5. If cannot fix after multiple attempts:**

Ask user:
```
FLAKY TEST - Cannot fix after investigation

Test: [test name]
Behavior: Passes sometimes, fails sometimes
Attempts made:
- [What was tried]
- [What was tried]

Root cause suspected: [analysis]

This is generally UNACCEPTABLE as flaky tests:
- Hide real bugs
- Break CI randomly
- Indicate test quality issues

Options:
1. Let me investigate more (provide guidance)
2. Skip this test temporarily (NOT RECOMMENDED)
3. Mark test as known-flaky (add comment, create issue)

Your choice: _
```

**Do NOT:**
- ❌ Silently accept flaky tests
- ❌ Claim 100% GREEN with flaky tests
- ❌ Retry until pass and move on

**Must either FIX or get USER approval to proceed with known flakiness.**

### Step 7: Update Progress

Update `progress.md`:
- Mark Phase 4 complete: `[✓]`
- Update completion: `60%`
- Document: "All X tests passing (GREEN phase confirmed)"

---

## Output Files

- Implementation code (all modules)
- All tests passing (GREEN)
- `ai_working/<feature>-<date>/04-implementation.md`
- `progress.md` (updated)

## Next Phase

```bash
/new-feature:5-refactor
```

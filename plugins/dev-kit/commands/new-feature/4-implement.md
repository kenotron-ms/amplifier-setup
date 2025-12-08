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

### Step 5: VERIFY Final GREEN State

**CRITICAL**: Run complete test suite and verify ALL tests pass.

Run with coverage and verbose output:

```bash
[test command with coverage and verbose]  # e.g., pytest -v --cov, npm test -- --coverage
```

**Must see:**
```
X unit tests PASSED
X integration tests PASSED
X e2e tests PASSED
Total: X/X tests PASSED (100% GREEN) ✓

Coverage: XX% (target: 60% unit, 30% integration, 10% e2e)
```

**Verify GREEN phase:**
- [ ] ALL tests passing (not just some)
- [ ] Coverage targets met (60/30/10 split)
- [ ] No skipped or ignored tests
- [ ] No flaky tests (run twice to confirm)

**If any tests fail:**
- ❌ Implementation incomplete
- ❌ Fix failing tests before proceeding
- ❌ Cannot proceed to refactoring with failing tests

Document final state:
```markdown
## Final State (GREEN Phase Verified)
- Unit tests: X/X passing (100%) ✓
- Integration tests: X/X passing (100%) ✓
- E2E tests: X/X passing (100%) ✓

Total: X/X passing (100% GREEN) ✓
Coverage: XX%

Ready for refactoring phase.
```

**Only proceed to Phase 5 if 100% GREEN!**

### Step 6: Update Progress

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

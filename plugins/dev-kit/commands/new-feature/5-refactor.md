---
description: "Phase 5: Refactor and improve code quality (TDD REFACTOR)"
category: development
allowed-tools: TodoWrite, Task, Read, Grep, Edit, Bash
---

# New Feature - Phase 5: Refactoring (TDD REFACTOR)

Improve code quality while keeping all tests GREEN.

## Prerequisites

- Phase 4 (Implementation) must be complete
- All tests must be passing (GREEN)
- Required files:
  - `ai_working/<feature>-<date>/00-discovery.md`
  - `ai_working/<feature>-<date>/01-requirements.md`
  - `ai_working/<feature>-<date>/03-test-plan.md`
  - `ai_working/<feature>-<date>/04-implementation.md`
  - `progress.md`

## Objectives

- Refactor for simplicity and maintainability
- Address code quality issues
- Ensure security and performance standards
- Keep tests GREEN throughout

---

## Process

Update TodoWrite:

```markdown
- [ ] Read previous phase outputs
- [ ] Located all test files
- [ ] Verified tests GREEN
- [ ] Code refactored for simplicity
- [ ] Self-review complete
- [ ] Security review complete
- [ ] Performance review complete (if needed)
- [ ] All tests still passing
- [ ] Review feedback addressed
```

### Step 1: Read Previous Outputs and Load Context

**REQUIRED**: Read previous phase documents to load full context.

**Use Read tool to load these documents into context:**

1. **Read** `ai_working/<feature>-<date>/00-discovery.md`
   - Full project context (not just test commands)
   - Repository patterns and conventions
   - Infrastructure systems discovered
   - Test framework and patterns

2. **Read** `ai_working/<feature>-<date>/01-requirements.md`
   - Full requirements (zen-architect needs this for verification)
   - Acceptance criteria
   - Assumptions and verified facts

3. **Read** `ai_working/<feature>-<date>/03-test-plan.md`
   - All test files created
   - Test categories (new feature vs regression)

4. **Read** `ai_working/<feature>-<date>/04-implementation.md`
   - Implementation details
   - What was built

**After reading, extract:**
- Test file paths (from 03-test-plan.md)
- Test commands (from 00-discovery.md)
- Requirements to verify (from 01-requirements.md)

**Verify test files exist:**
```bash
# Check each test file from test plan exists
ls -la [test files listed in 03-test-plan.md]
```

**If ANY test files NOT found:**

❌ **FAIL the phase immediately - do NOT proceed:**
```
Cannot find test files - Phase 5 cannot proceed!

Expected test files from 03-test-plan.md:
- [file path] ❌ NOT FOUND
- [file path] ❌ NOT FOUND

This phase REQUIRES tests to verify refactoring doesn't break anything.

Investigate:
1. Check 03-test-plan.md for created test files
2. Check if files were deleted
3. Check if files are in different location

Cannot proceed until all tests are located.
```

**Do NOT say "review passed" if tests can't be found.**

**Run tests using commands from discovery:**
```bash
# Use actual test commands from 00-discovery.md
[unit test command from discovery]
[integration test command from discovery]
[e2e test command from discovery]
```

Must see: All tests PASSING. If any fail or not found, STOP and fix.

### Step 2: Comprehensive Review (REQUIRED AGENT)

**REQUIRED**: Must use **zen-architect** agent for comprehensive code and test review.

```
Task zen-architect: "Review implementation of [feature] comprehensively:

CODE REVIEW:
- Code quality and structure
- Philosophy alignment (check against IMPLEMENTATION_PHILOSOPHY and MODULAR_DESIGN_PHILOSOPHY)
- Complexity and maintainability
- Best practices adherence
- Clean code principles

REQUIREMENTS VERIFICATION:
- Read 01-requirements.md
- Verify ALL functional requirements are satisfied in code
- Verify ALL acceptance criteria are met
- Check for any requirements gaps
- Ensure no requirements were missed or partially implemented

TEST REVIEW:
- Tests follow Test Design Checklist from Phase 3:
  - Test Classification correct (unit/integration/e2e properly classified)
  - Test Isolation (self-contained, no order dependencies)
  - Test Cleanup (proper teardown, no data leakage)
  - Test Selectors (accessible roles, not brittle CSS/XPath)
  - Test Fixtures (reusable, with cleanup)
- Tests are meaningful (not trivial assertions like 'assert True')
- Tests verify behavior, not implementation details
- No violations of test rules and best practices
- Regression tests included to protect existing functionality

Identify all issues and suggest improvements. Ensure tests remain green throughout."
```

**Wait for agent to complete.** Review findings for:
- Code issues
- Requirements gaps
- Test quality issues

### Step 3: Security Review (REQUIRED AGENT)

**REQUIRED**: Must use **security-guardian** agent.

```
Task security-guardian: "Review [feature] implementation for security issues:
input validation, authentication, authorization, data exposure, injection
vulnerabilities, secret handling, error message leakage, etc."
```

**Wait for agent to complete.** Review findings.

### Step 4: Performance Review (REQUIRED AGENT if performance-critical)

If feature is performance-critical, use **performance-optimizer** agent:

```
Task performance-optimizer: "Review [feature] for performance issues:
inefficient algorithms, unnecessary operations, N+1 queries, resource usage,
bottlenecks. Suggest optimizations while keeping tests green."
```

**Wait for agent to complete.** Review findings.

### Step 5: Address Feedback

For each issue found:
1. Make improvement
2. **RUN tests** to verify behavior preserved
3. Iterate until quality standards met

### Step 6: Document Review (FOLLOW TEMPLATE)

Create `ai_working/<feature>-<date>/05-review.md` documenting findings and resolutions.

Include: Quality score, issues found & resolved, security findings, performance findings, final status.

### Step 7: Verify Tests Still GREEN (Including Parallel Execution)

**REQUIRED**: Run tests to confirm refactoring didn't break anything.

**Test 1: Run normally**
```bash
[test command]
```

Must see: All tests PASSING.

**Test 2: Run in parallel (verify isolation maintained)**
```bash
# Run with maximum parallelization
[test command with parallel workers]
# pytest: pytest -n auto
# jest: npm test -- --maxWorkers=100%
# vitest: npx vitest --threads
# playwright: npx playwright test --workers=4
```

Must see: All tests PASSING in parallel execution.

**If tests fail in parallel but pass sequentially:**
- ❌ Refactoring broke test isolation
- ❌ Revert changes
- ❌ Fix isolation issues
- ❌ Re-run parallel tests

**If any tests fail:** Revert changes and fix before proceeding.

**Tests MUST pass both sequentially AND in parallel.**

### Step 8: Update Progress

Update `progress.md`:
- Mark Phase 5 complete: `[✓]`
- Update completion: `75%`

---

## Output Files

- Refactored code (tests still passing)
- `ai_working/<feature>-<date>/05-review.md`
- `progress.md` (updated)

## Next Phase

```bash
/new-feature:6-verify
```

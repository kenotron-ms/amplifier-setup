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
- [ ] Code refactored for simplicity
- [ ] Self-review complete
- [ ] Security review complete
- [ ] Performance review complete (if needed)
- [ ] All tests still passing
- [ ] Review feedback addressed
```

### Step 1: Verify Tests Still GREEN

**REQUIRED**: Confirm starting with all tests passing.

```bash
[test command]
```

Must see: All tests PASSING. If any fail, fix them before refactoring.

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

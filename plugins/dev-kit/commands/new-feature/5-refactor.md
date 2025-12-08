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

### Step 2: Self-Review (REQUIRED AGENT)

**REQUIRED**: Must use **zen-architect** agent.

```
Task zen-architect: "Review implementation of [feature] for code quality,
philosophy alignment, complexity, and maintainability. Check against
IMPLEMENTATION_PHILOSOPHY for ruthless simplicity. Identify issues and
suggest improvements. Ensure tests remain green."
```

**Wait for agent to complete.** Review findings.

### Step 3: Security Review (REQUIRED AGENT)

**REQUIRED**: Must use **security-guardian** agent.

```
Task security-guardian: "Review [feature] implementation for security issues:
input validation, authentication, authorization, data exposure, injection
vulnerabilities, secret handling, error message leakage."
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

### Step 7: Verify Tests Still GREEN

**REQUIRED**: Run tests again to confirm refactoring didn't break anything.

```bash
[test command]
```

Must see: All tests PASSING. If any fail, revert changes and fix.

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

---
description: "Phase 3: Write tests FIRST (TDD RED phase)"
category: development
allowed-tools: TodoWrite, Task, Read, Write, Bash
---

# New Feature - Phase 3: Test Planning (TDD RED)

Write all tests BEFORE implementation. Tests should fail initially.

## Template (MUST FOLLOW)

**This template MUST be followed when creating `03-test-plan.md`.**

```markdown
# Test Plan: [Feature]

**Based on**: 02-design.md
**Created**: YYYY-MM-DD

## Test Strategy

- Unit tests: 60% coverage target
- Integration tests: 30% coverage target
- E2E tests: 10% coverage target

## Test Categories

### New Feature Tests
Tests for NEW functionality being added. These MUST fail in Phase 3 (RED).

### Regression Tests
Tests for EXISTING functionality to ensure it doesn't break. These should PASS in Phase 3.

## Unit Tests To Write

### New Feature Tests (will FAIL in Phase 3 - RED)
#### Module: [Module Name]
- [ ] test_new_function_with_valid_input
- [ ] test_new_function_with_invalid_input
- [ ] test_new_function_edge_case
- [ ] test_new_function_error_handling

**Total**: 0/[X] unit tests (expecting FAIL)

### Regression Tests (should PASS in Phase 3 - protecting existing code)
- [ ] test_existing_feature_still_works
- [ ] test_existing_api_not_broken
- [ ] test_existing_data_flow_preserved

**Total**: 0/[X] regression tests (expecting PASS)

## Integration Tests To Write

### New Feature Tests (will FAIL)
- [ ] test_new_module_integration
- [ ] test_new_data_flow

### Regression Tests (should PASS)
- [ ] test_existing_integration_not_broken

**Total**: 0/[X] integration tests

## E2E Tests To Write

### New Feature Tests (will FAIL)
- [ ] test_new_user_workflow
- [ ] test_new_feature_error_handling

### Regression Tests (should PASS)
- [ ] test_existing_user_flows_still_work

**Total**: 0/[X] e2e tests

## Current Status

Tests planned. Ready to write tests.

**Test Files To Create**:
- tests/unit/test_[module].py
- tests/integration/test_[feature].py
- tests/e2e/test_[feature].py
```

---

## Prerequisites

- Phase 2 (Design) must be complete and approved
- Required files:
  - `ai_working/<feature>-<date>/02-design.md`
  - `progress.md`

## Objectives

- Write tests before implementation (TDD discipline)
- Define expected behavior through tests
- Create failing tests (RED phase)
- Ensure comprehensive test coverage plan

---

## Process

Update TodoWrite:

```markdown
- [ ] Test design checklist reviewed
- [ ] Test plan created (what tests to write)
- [ ] Unit tests written per plan (failing)
- [ ] Integration tests written per plan (failing)
- [ ] E2E tests written per plan (failing)
- [ ] Tests verified to fail correctly (RED)
- [ ] Test cleanup verified
```

### Test Design Checklist (MUST-DO)

**CRITICAL**: All tests MUST follow these principles.

Before writing tests, ensure the test design includes:

#### Test Classification (CRITICAL - Avoid Misclassification)

**UNIT TEST** - Tests single unit in isolation with mocked dependencies:
- ✅ Tests ONE function/component/module
- ✅ ALL dependencies are mocked/stubbed
- ✅ No database, no network, no file system (all mocked)
- ✅ Fast (<10ms per test)
- ✅ Example: Component with mocked store, function with mocked DB

**Example UNIT test:**
```javascript
// Testing MinimizedDock component in isolation
mockStore = { dockExpanded: true, setDockExpanded: vi.fn() };
render(<MinimizedDock />);
await user.click(collapseButton);
expect(mockSetDockExpanded).toHaveBeenCalledWith(false); // Mocked function
```

**INTEGRATION TEST** - Tests multiple units working together with real dependencies:
- ✅ Tests MULTIPLE modules/components interacting
- ✅ Uses REAL dependencies (real store, real database, real APIs)
- ✅ Tests data flow between components
- ✅ Tests actual persistence (localStorage, database)
- ✅ Slower (<1s per test)
- ✅ Example: Component + real Zustand store + localStorage

**Example INTEGRATION test:**
```javascript
// Testing MinimizedDock with REAL store and localStorage
render(<App />); // Real Zustand provider, real localStorage
await user.click(collapseButton);
expect(useStore.getState().dockExpanded).toBe(false); // Real store state
expect(localStorage.getItem('settings')).toContain('dockExpanded":false'); // Real persistence
```

**E2E TEST** - Tests complete user journey through full system:
- ✅ Tests COMPLETE user workflow end-to-end
- ✅ Real browser, real backend, real database
- ✅ Tests across multiple pages/views
- ✅ Tests like a real user would use the app
- ✅ Slowest (seconds per test)
- ✅ Example: Full flow from login through feature use

**Example E2E test:**
```javascript
// Testing complete user flow
await page.goto('/'); // Real app
await page.getByRole('button', { name: 'Minimize Project' }).click();
await page.getByRole('button', { name: 'Collapse sidebar' }).click();
await page.reload(); // Test persistence across reload
expect(await page.getByRole('region', { name: 'Dock' })).toHaveAttribute('data-expanded', 'false');
```

**Quick Classification Guide:**
- Mocked dependencies? → **Unit test**
- Real store/DB but single flow? → **Integration test**
- Complete user journey across system? → **E2E test**

#### Test Isolation (CRITICAL)
- [ ] **Each test is completely self-contained**
  - Test creates its own test data
  - Test doesn't rely on other tests
  - Test can run in any order
  - Test can run alone: `pytest test_file.py::test_name`
- [ ] **No execution order dependencies**
  - Tests pass when run in any order
  - Tests pass when run individually
  - No "test A must run before test B"
- [ ] **No shared mutable state**
  - Each test creates its own instances
  - No global variables shared between tests
  - No class-level state that persists
- [ ] **Each test starts with clean slate**
  - Setup runs before EVERY test
  - No assumptions about prior state

#### Test Cleanup
- [ ] **Database**: Cleanup records created during test
  - Use transactions that rollback
  - Delete test records in teardown
  - Use separate test database
- [ ] **Files**: Remove any files created
  - Delete temp files in teardown
  - Use temp directories that auto-delete
- [ ] **API Calls**: Mock external APIs or clean up test data
  - Don't make real API calls in tests
  - If unavoidable, delete created resources
- [ ] **State**: Reset state after each test
  - Clear caches, reset singletons
  - Restore mocked functions
- [ ] **Browser/DOM**: Clean up in E2E tests
  - Clear localStorage/sessionStorage
  - Reset cookies
  - Close browser sessions

#### Test Fixtures
- [ ] Use test fixtures/factories for test data
- [ ] Don't hardcode test data in tests
- [ ] Fixtures are reusable across tests
- [ ] Fixtures include cleanup logic

#### Test Structure
- [ ] Setup (arrange) → Execute (act) → Assert → Teardown
- [ ] Use beforeEach/afterEach or setUp/tearDown
- [ ] Teardown runs even if test fails (try/finally, defer, etc.)

#### Test Selectors (CRITICAL)

**Selector Priority** (most to least resilient):

1. **Accessible roles and labels** (BEST - mirrors user interaction)
   ```javascript
   getByRole('button', { name: 'Submit' })
   getByLabelText('Email address')
   ```
   Use for: All tests

2. **Test IDs** (explicit contracts)
   ```javascript
   data-testid="workspace-create-button"
   getByTestId('workspace-create-button')
   ```
   Use for: Complex scenarios, dynamic content, when semantic queries fail

3. **User-visible text** (natural but fragile)
   ```javascript
   getByText('Welcome back')
   ```
   Use for: Simple unit tests

**AVOID (brittle, implementation-coupled):**
- ❌ CSS classes: `.btn-primary` (styling details)
- ❌ Element IDs for styling: `#header` (implementation)
- ❌ XPath: `//div[@class='foo']/span[2]` (brittle)
- ❌ Tag + position: `div > span:nth-child(2)` (breaks easily)
- ❌ Generic queries: `screen.queryByText('1')` (ambiguous, multiple matches)

**Guidelines:**
- [ ] Use semantic/accessible selectors by default
- [ ] Test IDs follow naming scheme: `[component]-[action]-[element]`
- [ ] If you can't find it accessibly, UI is likely inaccessible
- [ ] Prefer semantic meaning over exact text: `getByRole('button', { name: /submit/i })`
- [ ] Use specific, unique selectors (avoid `queryByText('1')` that could match multiple elements)

#### Async Waiting (CRITICAL - Avoid Timeouts)

**AVOID arbitrary timeouts** (flaky, slow, unreliable):
- ❌ `await page.waitForTimeout(1000)` (arbitrary wait)
- ❌ `await sleep(500)` (arbitrary delay)
- ❌ `setTimeout()` in tests (timing-based)

**USE condition-based waits** (reliable, fast, deterministic):

**Playwright:**
```javascript
✅ await page.waitForSelector('#element')
✅ await page.waitForLoadState('networkidle')
✅ await page.waitForResponse(url => url.includes('/api'))
✅ await expect(locator).toBeVisible()
```

**Testing Library:**
```javascript
✅ await waitFor(() => expect(element).toBeInTheDocument())
✅ await findByRole('button', { name: 'Submit' })
✅ await waitForElementToBeRemoved(() => screen.getByText('Loading'))
```

**Cypress:**
```javascript
✅ cy.get('[data-testid="item"]').should('be.visible')
✅ cy.contains('Success').should('exist')
```

**Guidelines:**
- [ ] Wait for specific elements, not arbitrary time
- [ ] Wait for network responses, not timeouts
- [ ] Wait for state changes, not delays
- [ ] Use framework's built-in wait utilities
- [ ] If absolutely must use timeout (last resort), add comment explaining why

**When instructing agents to write tests, explicitly require:**
- "Include proper cleanup in teardown/afterEach"
- "Use test fixtures with automatic cleanup"
- "Ensure tests are isolated and don't leak data"
- "Use transactions or test databases that rollback"

### Step 1: CREATE Test Plan FIRST (FOLLOW TEMPLATE ABOVE)

**REQUIRED**: Create test plan BEFORE writing any tests.

Review `02-design.md` to identify:
- Each module that needs testing
- Test scenarios for each module (normal, edge, error cases)
- Integration points to test
- User flows for E2E tests

1. **Copy template structure** from TEMPLATE section above
2. **Create** `ai_working/<feature>-<date>/03-test-plan.md`
3. **List all tests to write** (unit, integration, e2e) as unchecked items

This plan is your checklist - follow it exactly when writing tests!

### Step 2: Write Unit Tests Following Plan

**Use 03-test-plan.md as your checklist.** Write each test listed in the plan.

Use **test-coverage** agent:

```
Task test-coverage: "Create unit tests for [feature] following the test plan in
03-test-plan.md. Write EXACTLY the tests listed in the plan - no more, no less.
Tests should FAIL initially (no implementation yet).

Reference 02-design.md for module specifications.

CRITICAL TEST REQUIREMENTS:
- Include proper cleanup in teardown/afterEach/afterAll
- Use test fixtures with automatic cleanup
- Tests must be isolated (no shared state, no order dependencies)
- Database: Use transactions that rollback OR delete records in teardown
- Files: Delete any temp files created
- State: Reset mocks, clear caches after each test
- Each test must be self-contained and leave no trace

WRITE the actual test files using Write tool. Create:
- tests/unit/test_[module].py (or .js/.ts based on project)
- Include imports, test functions, assertions
- Include setup/teardown hooks

As you create each test, check it off in 03-test-plan.md!"
```

**Verify tests were created:**
```bash
ls -la tests/unit/test_*.*
```

**Check off tests in 03-test-plan.md** as created.

### Step 3: Write Integration Tests Following Plan

**Use 03-test-plan.md as your checklist.** Write each integration test listed.

Use **integration-specialist** agent:

```
Task integration-specialist: "Create integration tests for [feature] following
the test plan in 03-test-plan.md. Write EXACTLY the tests listed - no more, no less.
Tests should FAIL initially.

Reference 02-design.md for integration specifications.

CRITICAL TEST REQUIREMENTS:
- Include proper cleanup in teardown
- Use test database with cleanup/rollback
- Tests must be isolated, self-contained, and idempotent
- No execution order dependencies

WRITE the actual test files using Write tool. Create:
- tests/integration/test_[feature]_integration.py (or .js/.ts)
- Include setup/teardown with database cleanup

Check off each test in 03-test-plan.md as created!"
```

**Verify tests created and check off in plan.**

### Step 4: Write E2E Tests Following Plan

**Use 03-test-plan.md as your checklist.** Write each E2E test listed.

Use **test-coverage** agent:

```
Task test-coverage: "Create E2E tests for [feature] following the test plan in
03-test-plan.md. Write EXACTLY the tests listed in the plan.
Tests should FAIL initially.

Reference 02-design.md for user flow specifications.

CRITICAL TEST REQUIREMENTS:
- Include proper cleanup in teardown/afterAll
- Clear localStorage/sessionStorage after tests
- Tests must be isolated, self-contained, and repeatable
- No execution order dependencies

WRITE the actual test files using Write tool. Create:
- tests/e2e/test_[feature]_e2e.py (or .spec.js/.spec.ts)
- Include browser setup/teardown and data cleanup

Check off each test in 03-test-plan.md as created!"
```

**Verify tests created and check off in plan.**

### Step 4a: Verify Tests Are Correct (REQUIRED)

**REQUIRED**: Verify all tests are syntactically correct and properly structured BEFORE running them.

**Check each test file:**

```bash
# Check syntax
[language-specific syntax check command]
# Python: python -m py_compile tests/**/*.py
# JavaScript: npx eslint tests/ --max-warnings 0
# TypeScript: npx tsc --noEmit

# Verify test framework can discover tests
[test discovery command]
# pytest: pytest --collect-only
# jest: npm test -- --listTests
# vitest: npx vitest list
```

**Verify each test has:**
- [ ] Correct imports (no import errors)
- [ ] Proper setup/teardown hooks (beforeEach/afterEach, setUp/tearDown)
- [ ] Cleanup logic in teardown
- [ ] Assertions present
- [ ] No syntax errors
- [ ] Can be discovered by test framework

**Verify logical correctness:**
- [ ] Test actually has assertions (not just setup/teardown)
- [ ] Assertions are meaningful (not `assert True` or `assert 1 == 1`)
- [ ] Test name matches what's being tested
- [ ] Test covers stated scenario (valid input, invalid input, edge case, etc.)
- [ ] Not over-mocked (test still tests real behavior)
- [ ] Assertions use expected values (not hard-coded magic numbers)
- [ ] Edge cases actually test boundaries
- [ ] Error tests actually trigger errors

**If issues found:**
1. Fix syntax errors
2. Add missing imports
3. Add missing setup/teardown
4. Ensure cleanup logic present
5. Re-verify until all tests are correct

**Only proceed to run tests after ALL test files are verified correct.**

**If issues can't be auto-fixed, ask user:**
```
Test verification found issues that need your input:

[List of issues]

What would you like to do?
1. Let me fix these issues manually
2. Help me debug [specific issue]
3. Review the test files together

Your choice: _
```

### Step 4b: Configure E2E Framework for Auto-Server (If Supported)

**Check if E2E framework supports auto-starting dev server:**

Review `00-discovery.md` for E2E framework in use:
- **Playwright**: Supports `webServer` config in playwright.config
- **Cypress**: Supports `baseUrl` or use start-server-and-test
- **Puppeteer/Jest**: Use globalSetup/globalTeardown

**If framework supports auto-server, configure it:**

For Playwright:
```typescript
// playwright.config.ts
webServer: {
  command: '[dev server command from discovery]',
  port: [port],
  reuseExistingServer: !process.env.CI,
}
```

For Cypress:
```json
// cypress.config.js
{
  "baseUrl": "http://localhost:[port]",
  // Use start-server-and-test in package.json
}
```

**If configured, E2E tests will auto-start server. Skip Step 4b.**

### Step 4b: Manually Start Dev Server (If Auto-Server Not Configured)

**If E2E framework doesn't auto-start server, start it manually:**

Get dev server command from `00-discovery.md` (Build Command section).

```bash
# Start dev server in background
[dev server command from discovery] &
DEV_SERVER_PID=$!

# Wait for server to be ready
sleep 5  # Or use wait-on/wait-for-it

# Check if server started successfully
if ! curl -s http://localhost:[port] > /dev/null; then
    echo "❌ Dev server failed to start"
fi
```

**If server fails to start, ask user:**
```
Dev server failed to start.

Possible issues:
- Port [port] already in use
- Missing dependencies
- Configuration error
- [Error message from logs]

What would you like to do?
1. Fix the issue and retry
2. Use a different port
3. Skip E2E tests for now (NOT RECOMMENDED - breaks TDD)
4. Debug the issue together

Your choice: _
```

**Do NOT automatically skip E2E tests without user decision.**

**Keep server running for test execution if started successfully.**

### Step 5: RUN Tests and VERIFY They Fail (RED Phase)

**CRITICAL**: Must actually run tests and confirm they fail!

**Run unit and integration tests first:**
```bash
# Run without E2E initially
[unit test command]
[integration test command]
```

**Then run E2E tests (app should be running):**

```bash
[test command from discovery]  # e.g., pytest -v, npm test
```

**Expected outcomes:**
- **New feature tests**: FAIL (RED phase - feature doesn't exist yet)
- **Regression tests**: PASS (existing functionality works)

**Verify test results:**
```bash
[test command with verbose] | tee test_output.txt

# Analyze results
grep "PASSED" test_output.txt  # Should be regression tests only
grep "FAILED" test_output.txt  # Should be new feature tests only
```

**Check test output for:**
- [ ] All NEW FEATURE tests are in FAILED state (RED phase ✓)
- [ ] All REGRESSION tests are in PASSED state (existing code works ✓)
- [ ] Failure messages indicate missing implementation (ImportError, ModuleNotFoundError, etc.)
- [ ] No syntax errors in test files
- [ ] Tests can be discovered by test framework

**If NEW FEATURE tests PASS:**
- ❌ Implementation already exists (not truly new)
- ❌ Tests are not meaningful
- ❌ Review: Are you testing the new feature or existing code?

**If REGRESSION tests FAIL:**
- ❌ Existing functionality is broken
- ❌ Fix the regression tests or the existing code
- ❌ Cannot proceed with broken existing functionality

**If tests have errors (syntax, import issues, config problems):**

Ask user instead of assuming:
```
Tests failed to execute (not failed as in RED, but couldn't run):

Error: [error message]

Possible issues:
- Syntax errors in test files
- Missing test dependencies
- Test framework not configured
- Import errors

What would you like to do?
1. Fix the issue and retry
2. Debug the test configuration
3. Review test files for errors
4. Other (explain)

Your choice: _
```

**Do NOT skip tests or mark phase complete if tests can't execute.**

**Document test results:**

Create summary showing both categories:
```
Phase 3 Test Results (RED Phase):

NEW FEATURE TESTS (expecting FAIL):
✓ Unit tests: X/X failing (expected RED)
✓ Integration tests: X/X failing (expected RED)
✓ E2E tests: X/X failing (expected RED)

REGRESSION TESTS (expecting PASS):
✓ Unit tests: X/X passing (existing code works)
✓ Integration tests: X/X passing (existing code works)
✓ E2E tests: X/X passing (existing code works)

Total: X new feature tests FAILING (RED ✓), X regression tests PASSING ✓

RED phase confirmed for new feature - ready for implementation.
```

**Only proceed to Phase 4 if:**
- ✅ All NEW FEATURE tests are FAILING (RED)
- ✅ All REGRESSION tests are PASSING (existing code works)

This is proper TDD discipline with regression protection.

### Step 5a: Stop Dev Server (If Started Manually)

**If you started the dev server manually in Step 4b:**

```bash
# Stop the dev server
kill $DEV_SERVER_PID

# Or if PID not available
pkill -f "[dev server process name]"

echo "Dev server stopped"
```

**If E2E framework auto-manages server, skip this step.**

### Step 6: Verify Test Isolation and Cleanup

**CRITICAL**: Verify tests are self-contained and clean up properly.

**Test 1: Run twice (verify cleanup)**
```bash
# Run tests twice - both should pass/fail the same way
[test command]
[test command]
```

Check for:
- [ ] Second run has same results as first
- [ ] No leftover database records
- [ ] No leftover files
- [ ] No warnings about existing data

**Test 2: Run in different orders (verify independence)**
```bash
# Run tests in random order (if framework supports)
[test command with random order flag]  # e.g., pytest --random-order, npm test -- --randomize

# Or run individual tests
[test command] test_file.py::test_1
[test command] test_file.py::test_2
[test command] test_file.py::test_1  # Run test_1 again
```

Check for:
- [ ] Tests pass regardless of order
- [ ] Individual tests pass when run alone
- [ ] No "test must run after another test"

**Test 3: Run in parallel (verify true isolation)**
```bash
# Run tests with maximum parallelization
[test command with parallel workers]
# pytest: pytest -n auto (requires pytest-xdist)
# jest: npm test -- --maxWorkers=100%
# vitest: npx vitest --threads
# playwright: npx playwright test --workers=4
```

Check for:
- [ ] Tests pass with parallel execution
- [ ] No race conditions
- [ ] No shared state issues
- [ ] No database conflicts
- [ ] No file system conflicts

**If tests fail in parallel but pass sequentially:**
- ❌ Tests are not properly isolated
- ❌ Fix: Add proper cleanup
- ❌ Fix: Remove shared state
- ❌ Fix: Use test-scoped resources (separate test DB per worker)

**Tests MUST pass in parallel execution**

**Test 4: Verify cleanup in CI**
```bash
# Run full suite
[test command with verbose output]
```

Check for:
- [ ] No cleanup warnings or errors
- [ ] Database queries show clean state after tests
- [ ] Temp directories are empty

If issues found:
- Add missing teardown/cleanup code
- Fix shared state between tests
- Add fixtures with automatic cleanup
- Use test database transactions

### Step 7: Update Test Plan with Final Status

Update `03-test-plan.md`: Check off all tests as created and mark with FAILING status. Add "Current Status" noting all tests are RED and ready for implementation.

### Step 8: Update Progress

Update `progress.md`:
- Mark Phase 3 complete: `[✓]`
- Update completion: `35%`
- Note: "All X tests created and failing (RED phase confirmed), cleanup verified"

### Step 9: Confirm Ready for Implementation

Present to user:

```
Phase 3 Complete: Test Planning (RED Phase)

Created:
- X unit tests (all FAILING ✓)
- X integration tests (all FAILING ✓)
- X e2e tests (all FAILING ✓)

Total: X tests created, X failing (100% RED) ✓

Test plan: ai_working/<feature>-<date>/03-test-plan.md
All tests checked off and verified RED.

Ready to proceed to implementation (make tests GREEN).

Next: /new-feature:4-implement
```

---

## Output Files

- Test files (unit, integration, e2e) - all failing
- `ai_working/<feature>-<date>/03-test-plan.md`
- `progress.md` (updated)

## Next Phase

```bash
/new-feature:4-implement
```

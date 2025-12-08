---
description: "Phase 8: Prepare for production deployment"
category: development
allowed-tools: TodoWrite, Task, Read, Write
---

# New Feature - Phase 8: Deployment Preparation

Create deployment plan, rollback procedures, and monitoring strategy.

## Template (MUST FOLLOW)

**This template MUST be followed when creating `08-deployment.md`.**

```markdown
# Deployment Plan: [Feature]

**Created**: YYYY-MM-DD

## Prerequisites

- [Requirement 1]
- [Requirement 2]
- [Environment variables needed]

## Configuration Changes

### Environment Variables
\`\`\`bash
export FEATURE_ENABLED=true
export FEATURE_CONFIG=value
\`\`\`

### Configuration Files
\`\`\`yaml
# config/production.yaml
feature:
  enabled: true
  setting: value
\`\`\`

## Database Migrations

\`\`\`bash
# Run migrations if applicable
[migration command]
\`\`\`

## Deployment Steps

1. Backup current state
2. Deploy code
3. Run migrations
4. Update configuration
5. Restart services
6. Verify deployment

## Verification Steps

1. Health check: [command/URL]
2. Feature verification: [test steps]
3. Log verification: [what to check]

## Rollback Plan

**If issues occur:**

1. Identify severity (critical vs non-critical)
2. Rollback code: `git revert [commit]`
3. Rollback migrations (if needed): `[rollback command]`
4. Restore configuration
5. Restart services
6. Verify rollback successful

## Monitoring

### Metrics to Watch
- [Metric 1]: Expected range [X-Y]
- [Metric 2]: Expected range [X-Y]

### Logs to Monitor
\`\`\`bash
[log monitoring commands]
\`\`\`

### Alert Thresholds
- [Condition]: Alert/Warning

## Success Criteria

- [ ] Health checks passing
- [ ] Feature working as expected
- [ ] No increase in error rates
- [ ] Performance within acceptable range
```

---

## Prerequisites

- Phase 7 (Documentation) must be complete
- Required files:
  - `ai_working/<feature>-<date>/07-docs-checklist.md`
  - `progress.md`

## Objectives

- Verify pre-deployment checklist
- Create deployment plan
- Document rollback procedures
- Define monitoring strategy

---

## Process

Update TodoWrite:

```markdown
- [ ] Pre-deployment checklist complete
- [ ] Deployment plan created
- [ ] Rollback plan documented
- [ ] Monitoring strategy defined
```

### Step 1: Pre-Deployment Checklist

Verify:
- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Security review passed
- [ ] Documentation complete
- [ ] Configuration requirements documented

### Step 2: Create Deployment Plan (FOLLOW TEMPLATE ABOVE)

**REQUIRED**: Create deployment plan following TEMPLATE section above.

If CLI changes involved, use **amplifier-cli-architect** agent:

```
Task amplifier-cli-architect: "Review deployment requirements for [feature]
and create deployment plan including configuration, migrations, and verification."
```

**Wait for agent to complete** if used.

1. **Copy template structure** from TEMPLATE section above
2. **Create** `ai_working/<feature>-<date>/08-deployment.md`
3. **Fill in ALL sections**:
   - Prerequisites
   - Configuration changes
   - Database migrations (if any)
   - Deployment steps
   - Verification steps
   - Rollback plan
   - Monitoring strategy

### Step 3: Update Progress

Update `progress.md`:
- Mark Phase 8 complete: `[✓]`
- Update completion: `100%` (or 95% if cleanup planned)

### Step 4: Present Summary

Present deployment readiness:
- Pre-deployment checklist status
- Deployment plan location
- Rollback procedure documented
- Monitoring strategy defined

---

## Output Files

- `ai_working/<feature>-<date>/08-deployment.md`
- `progress.md` (updated)

## Next Phase (Optional)

```bash
# Optional cleanup phase
/new-feature:9-cleanup

# Or commit and create PR
/git:commit
/git:submit-pr
```

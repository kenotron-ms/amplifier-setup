# Configuration

## Environment Variables

### AMP_HOME

Override the state directory (default: `~/.amp`):

```bash
export AMP_HOME="$HOME/.my-amp"
amp
```

All amp state, logs, and worktrees will be stored in this location.

### AMP_AMPLIFIER_DIR

Override the amplifier clone location (default: `~/.amp/main`):

```bash
export AMP_AMPLIFIER_DIR="$HOME/.my-amp/main"
amp
```

The main amplifier repository will be cloned here.

## Update Frequency

By default, amp checks for updates once per 24 hours.

### Force Update Check

To bypass the 24-hour interval:

```bash
rm ~/.amp/.amp_last_check
amp
```

Or use the explicit update command:

```bash
amp update
```

## Logging

All operations are logged to `~/.amp/.amp.log`.

### View Logs

```bash
# Watch logs in real-time
tail -f ~/.amp/.amp.log

# View recent logs
tail -100 ~/.amp/.amp.log

# Search logs
grep ERROR ~/.amp/.amp.log
```

## Workspace Isolation

Each project gets its own workspace worktree with isolated:

- **Python environment** - `.venv/` with project-specific dependencies
- **AI working files** - `ai_working/` for project-specific AI work
- **Data files** - `.data/` for project data
- **Git branch** - Can be on different branches per project

Location pattern: `~/.amp/w/{sanitized-project-path}/`

Example: `/Users/ken/projects/myapp` → `~/.amp/w/Users-ken-projects-myapp/`

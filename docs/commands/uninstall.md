# amp uninstall

Remove amp from your system.

## Usage

```bash
# Remove amp from shell configuration (keeps workspace data)
amp uninstall

# Remove amp AND all workspace data
amp uninstall --data

# Silent uninstall (for scripts/automation)
amp uninstall --data --no-confirm

# View all options
amp uninstall --help
```

## Options

| Option | Description |
|--------|-------------|
| `--data` | Also remove `~/.amp` directory (workspace data, logs, etc.) |
| `--no-confirm` | Skip confirmation prompts (use with caution!) |
| `-h, --help` | Show help message |

## What Gets Removed

### By Default (No Flags)

- ✅ amp source lines from `~/.bashrc` and `~/.zshrc`
- ✅ Backups created with `.amp-backup` extension
- ⏸️ `~/.amp` directory is **preserved**

### With `--data` Flag

- ✅ amp source lines from shell RC files
- ✅ `~/.amp` directory **removed**, including:
  - Main amplifier repository
  - All workspace worktrees
  - Virtual environments and dependencies
  - AI working files and data

## Interactive Flow

```bash
$ amp uninstall

🗑️  Uninstalling amp command...

🔧 Removing from shell configuration...
  ✅ Removed from .zshrc (backup: .zshrc.amp-backup)

ℹ️  Keeping amp directory: ~/.amp (2.1G)

Your workspace data is preserved. To remove it later, run:
  amp uninstall --data
  OR
  rm -rf ~/.amp

✅ Uninstall complete!

💡 Note:
  • The 'amp' command will remain available in THIS terminal session
  • New terminals will not have the 'amp' command
  • To remove from current session: unset -f amp
```

## Complete Removal

To completely remove amp and all data:

```bash
$ amp uninstall --data

🗑️  Uninstalling amp command...

🔧 Removing from shell configuration...
  ✅ Removed from .zshrc

📂 Will remove amp directory: ~/.amp (2.1G)

This directory contains:
  • Main amplifier repository
  • All workspace worktrees
  • Virtual environments and dependencies
  • AI working files and data

Really remove this directory and ALL data? (y/N): y

🗑️  Removing ~/.amp...
✅ Removed amp directory

✅ Uninstall complete!
```

## Safety Features

- **Backups** - RC files are backed up before modification
- **Confirmation prompts** - Double-check before removing data
- **Preserves data by default** - Only removes data with `--data` flag
- **Current session** - amp function remains in current terminal until reload

## After Uninstall

1. **Restart your terminal** or run `unset -f amp` to remove from current session
2. New terminals will not have the `amp` command
3. Your project files are untouched (only amp setup is removed)

## Reinstalling

To reinstall later:

```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
```

# amp update

Update both the amplifier repository and amp scripts to the latest version.

## Usage

```bash
amp update
```

## What It Updates

1. **Amplifier repository** - Pulls latest from `microsoft/amplifier`
2. **amp scripts** - Downloads latest `amp.sh`, `amp-workspace.sh`, `uninstall.sh`

## Example Output

```bash
$ amp update

🔄 Updating amp...

📦 Updating amplifier repository...
   ✅ Amplifier updated (643d906 → 51715ed)

📝 Updating amp scripts...
   ✅ Scripts updated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Update complete!

⚡ To use updated scripts, reload your shell:

  source ~/.${SHELL##*/}rc

Or just restart your terminal.
```

## After Update

Reload your shell to use the updated scripts:

```bash
source ~/.${SHELL##*/}rc
```

Or just restart your terminal.

## Smart Updates

amp update is intelligent about when to reinstall dependencies:

**Only reinstalls when these files change:**
- `pyproject.toml`
- `uv.lock`
- `Makefile`

**Skips reinstall for:**
- Documentation changes
- Code-only changes
- Configuration updates

This makes updates much faster for most changes (instant vs 2-5 minutes).

## Graceful Fallback

If GitHub is unreachable:
- Amplifier repo update continues
- Script update is skipped with a warning
- Your current scripts continue working

## Update Frequency

Automatic update checks happen:
- Once per 24 hours
- When you run `amp update` (forces check)
- During bootstrap (first run)

To force an update check:
```bash
rm ~/.amp/.amp_last_check
amp
```

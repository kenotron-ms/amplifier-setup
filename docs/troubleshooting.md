# Troubleshooting

## Check the Log

If something goes wrong, check the operation log:

```bash
tail -f ~/.amp/.amp.log
```

## Common Issues

### "Missing required tools"

**Problem:** Prerequisites not installed

**Solution:** Install the missing tools:
- **git**: https://git-scm.com/downloads
- **make**: `xcode-select --install` (macOS) or via package manager (Linux)
- **python3**: https://www.python.org/downloads/
- **uv**: https://docs.astral.sh/uv/getting-started/installation/
- **claude**: https://docs.anthropic.com/en/docs/claude-code/install

### "Virtual environment not found"

**Problem:** Installation was interrupted

**Solution:** Force reinstall:

```bash
rm ~/.amp/.amp_ready
amp  # Will retry installation
```

### "Failed to pull updates"

**Problem:** Network issue or local changes in amplifier repo

**Solution:** Check for local changes and reset:

```bash
cd ~/.amp/main
git status  # Check for local changes
git reset --hard origin/main  # Reset to clean state
```

### amp command not found

**Problem:** Shell not reloaded after installation

**Solution:** Reload your shell:

```bash
source ~/.${SHELL##*/}rc
```

Or restart your terminal.

### "Directory exists and is not empty" (amp new)

**Problem:** Target directory already has files

**Behavior:** amp will still create CLAUDE.md in the directory alongside existing files

**Solution:** This is expected - amp new can initialize existing projects

## Force Reinstall

If the amplifier installation is corrupted:

```bash
rm ~/.amp/.amp_ready
amp  # Will trigger full bootstrap
```

## Complete Reinstall

To start from scratch:

```bash
# Remove everything
rm -rf ~/.amp

# Reinstall
amp  # Will re-clone and install everything
```

## Getting Help

- **Documentation**: https://kenotron-ms.github.io/amplifier-setup/
- **Issues**: https://github.com/kenotron-ms/amplifier-setup/issues
- **Amplifier docs**: https://github.com/microsoft/amplifier

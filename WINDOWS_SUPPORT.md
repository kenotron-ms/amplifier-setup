# Windows Support Summary

## Overview

Amplifier Setup now has **full Windows support** with automatic prerequisite installation via winget (Windows Package Manager).

## One-Liner Installation

### Windows
```powershell
irm https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.ps1 | iex
```

### Mac/Linux
```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
```

## What Gets Installed

### Automatically Installed

**Windows (via winget):**
- ✅ Python 3.12 (if not present)
- ✅ Git (if not present)
- ✅ uv (Python package manager)
- ✅ `amp.ps1` (PowerShell function)
- ✅ `amp.cmd` (CMD wrapper)

**Mac (via Homebrew):**
- ✅ Python 3.12 (if not present)
- ✅ Git (if not present)
- ✅ uv (Python package manager)
- ✅ `amp.sh` (Bash function)

**Linux:**
- ✅ uv (Python package manager)
- ✅ `amp.sh` (Bash function)
- ⚠️ Python & Git must be installed manually first

### User Must Install
- **Claude Code** - Required on all platforms

## Cross-Platform Shell Support

### Windows
- ✅ **CMD (Command Prompt)** - Uses `amp.cmd`, added to PATH
- ✅ **PowerShell 5.1** - Uses `amp` function from `amp.ps1`
- ✅ **PowerShell 7+ (pwsh)** - Uses `amp` function from `amp.ps1`

### Mac/Linux
- ✅ **Bash** - Uses `amp` function from `amp.sh`
- ✅ **Zsh** - Uses `amp` function from `amp.sh`

## Files Created

```
amplifier-setup/
├── install.sh              # Unix installer with bootstrapping
├── install.ps1             # Windows installer with bootstrapping
├── amp.sh                  # Unix shell function (existing)
├── amp.ps1                 # Windows PowerShell function (NEW)
├── amp.cmd                 # Windows CMD wrapper (NEW)
└── .github/workflows/
    ├── test-install.yml    # Full installation tests (NEW)
    └── test-scripts.yml    # Script syntax and basic tests (NEW)
```

## Installation Flow

### Windows

1. **Bootstrap Prerequisites**
   - Check for Python → Install via `winget install Python.Python.3.12`
   - Check for Git → Install via `winget install Git.Git`
   - Check for uv → Install via official installer
   - Check for Claude Code → Warn if missing

2. **Install amp Command**
   - Download `amp.ps1` to `~/.amp/`
   - Download `amp.cmd` to `~/.amp/`
   - Add `~/.amp` to user PATH (for CMD access)
   - Add sourcing line to PowerShell profile

3. **Usage**
   - CMD: Type `amp` (works immediately)
   - PowerShell: Reload profile with `. $PROFILE`, then type `amp`
   - pwsh: Same as PowerShell

### Mac/Linux

1. **Bootstrap Prerequisites**
   - Check for Python → Install via Homebrew on Mac
   - Check for Git → Install via Homebrew on Mac
   - Check for uv → Install via official installer
   - Check for Claude Code → Warn if missing

2. **Install amp Command**
   - Download `amp.sh` to `~/.amp/`
   - Add sourcing line to `.bashrc` and `.zshrc`

3. **Usage**
   - Reload shell with `source ~/.bashrc` or `source ~/.zshrc`
   - Type `amp`

## CI/CD Testing

Two GitHub Actions workflows test cross-platform support:

### 1. `test-install.yml`
- **Full installation test** on Windows, Mac, and Linux
- Tests bootstrap functionality
- Verifies all prerequisites are installed
- Tests `amp` command bootstrap
- Includes test with deliberately missing prerequisites

### 2. `test-scripts.yml`
- **Syntax validation** for all shell scripts
- Tests file installation
- Verifies PATH updates
- Tests `amp` function/command availability

## Technical Details

### Windows Architecture

**PowerShell Function (`amp.ps1`)**:
- Defines an `amp` function in PowerShell scope
- Handles bootstrap, updates, venv activation
- Works in both PowerShell 5.1 and PowerShell 7+

**CMD Wrapper (`amp.cmd`)**:
- Batch file that delegates to PowerShell
- Detects `pwsh` or `powershell` and uses available one
- Allows `amp` to work in Command Prompt

**Why Both?**
- PowerShell users get a native function (faster, better integration)
- CMD users get a batch file wrapper (added to PATH)
- Consistent `amp` command across all shells

### Path Handling

**Windows**:
- Uses backslashes: `$env:USERPROFILE\.amp\main`
- venv activation: `.venv\Scripts\Activate.ps1`
- PATH separator: `;`

**Unix**:
- Uses forward slashes: `~/.amp/main`
- venv activation: `.venv/bin/activate`
- PATH separator: `:`

## Known Limitations

1. **Linux**: Python & Git must be pre-installed (can't auto-install due to distro variety)
2. **Windows**: Requires Windows 10 1809+ for winget (older versions need manual Python/Git install)
3. **Claude Code**: Must be installed manually on all platforms

## Future Improvements

Potential enhancements:
- [ ] Chocolatey support for older Windows versions
- [ ] Linux distro detection for auto-install
- [ ] `amp update` command to refresh installer scripts
- [ ] `amp doctor` command to verify setup
- [ ] Windows Terminal integration

## Testing Locally

### Windows (PowerShell)
```powershell
# Test installation
.\install.ps1

# Verify amp works
. $PROFILE
amp --version
```

### Windows (CMD)
```cmd
REM Test installation
powershell -ExecutionPolicy Bypass -File install.ps1

REM Verify amp works (in new CMD window)
amp --version
```

### Mac/Linux
```bash
# Test installation
bash install.sh

# Verify amp works
source ~/.bashrc  # or ~/.zshrc
amp --version
```

## Troubleshooting

### Windows: "amp not found"
- **CMD**: Close and reopen Command Prompt
- **PowerShell**: Run `. $PROFILE`
- Check PATH: `echo $env:Path` should contain `.amp`

### Windows: "winget not found"
- Update Windows to version 1809 or later
- Install Python & Git manually from websites
- Re-run installer

### All Platforms: "Claude not found"
- Install Claude Code from: https://docs.anthropic.com/en/docs/claude-code/install
- Verify: `claude --version`

### Bootstrap fails
- Check logs: `~/.amp/.amp.log` (Unix) or `%USERPROFILE%\.amp\.amp.log` (Windows)
- Remove flag and retry: `rm ~/.amp/.amp_ready && amp`

## Questions?

Open an issue at: https://github.com/kenotron-ms/amplifier-setup/issues

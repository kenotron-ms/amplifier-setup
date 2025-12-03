# install.ps1 - Install/Update the amp command (Windows)
#
# Usage:
#   irm https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.ps1 | iex
#
# This script is idempotent - safe to run multiple times to get latest version.
#
# What it does:
# 1. Checks and installs prerequisites (Python, Git, uv)
# 2. Downloads latest amp.ps1 script from GitHub
# 3. Installs it to ~/.amp/
# 4. Adds amp function to PowerShell profile
# 5. Loads for current session

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# BOOTSTRAP: Check and Install Prerequisites
# =============================================================================

# Check if Python is installed
function Test-Python {
    try {
        $version = python --version 2>&1
        Write-Host "✓ Python found: $version" -ForegroundColor Green

        # Check version >= 3.11
        $versionNum = ($version -replace 'Python ', '').Split('.')
        $major = [int]$versionNum[0]
        $minor = [int]$versionNum[1]

        if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 11)) {
            Write-Host "  Warning: Python 3.11+ required (found $major.$minor)" -ForegroundColor Yellow
            return $false
        }
        return $true
    } catch {
        return $false
    }
}

# Install Python using winget
function Install-Python {
    Write-Host "Installing Python 3.12..." -ForegroundColor Yellow

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "✗ winget not found. Please install from Microsoft Store or update Windows." -ForegroundColor Red
        Write-Host "  Manual install: https://www.python.org/downloads/" -ForegroundColor Yellow
        exit 1
    }

    winget install Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements

    # Refresh PATH to pick up newly installed Python
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    # Clear PowerShell's command cache to force it to find the new python
    $ExecutionContext.InvokeCommand.CommandNotFoundAction = $null

    Write-Host "✓ Python installed" -ForegroundColor Green
}

# Check if Git is installed
function Test-Git {
    try {
        $version = git --version 2>&1
        Write-Host "✓ Git found: $version" -ForegroundColor Green
        return $true
    } catch {
        return $false
    }
}

# Install Git using winget
function Install-Git {
    Write-Host "Installing Git..." -ForegroundColor Yellow

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "✗ winget not found" -ForegroundColor Red
        Write-Host "  Manual install: https://git-scm.com/downloads" -ForegroundColor Yellow
        exit 1
    }

    winget install Git.Git --silent --accept-package-agreements --accept-source-agreements

    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    Write-Host "✓ Git installed" -ForegroundColor Green
}

# =============================================================================
# MAIN: Bootstrap and Hand Off to Python
# =============================================================================

try {
    Write-Host "Checking prerequisites..." -ForegroundColor Cyan
    Write-Host ""

    # Check/install Python
    if (-not (Test-Python)) {
        Install-Python
        # After winget install, the PATH may not be fully updated yet
        # Give the system a moment and try clearing the command cache
        Start-Sleep -Seconds 2
        # Force a fresh PATH check
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        # If still not found, trust winget's success (it takes time for PATH to fully propagate)
        if (-not (Test-Python)) {
            Write-Host "  Note: Python installed but not yet in PATH (will be available after restart)" -ForegroundColor Yellow
        }
    }

    # Check/install Git
    Write-Host ""
    if (-not (Test-Git)) {
        Install-Git
        # After winget install, the PATH may not be fully updated yet
        Start-Sleep -Seconds 2
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

        # If still not found, trust winget's success
        if (-not (Test-Git)) {
            Write-Host "  Note: Git installed but not yet in PATH (will be available after restart)" -ForegroundColor Yellow
        }
    }

    # Check uv
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        Write-Host "✓ uv already installed" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Installing uv..." -ForegroundColor Yellow
        irm https://astral.sh/uv/install.ps1 | iex

        # Add to PATH for current session
        $env:Path = "$env:USERPROFILE\.cargo\bin;$env:Path"

        Write-Host "✓ uv installed" -ForegroundColor Green
    }

    # Check/install Claude Code
    Write-Host ""
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        $claudeVersion = claude --version 2>&1 | Select-Object -First 1
        Write-Host "✓ Claude Code found: $claudeVersion" -ForegroundColor Green
    } else {
        Write-Host "Installing Claude Code..." -ForegroundColor Yellow
        Write-Host "  (Using native binary installer - no Node.js required)" -ForegroundColor Cyan

        try {
            # Download and run the official Claude Code installer
            irm https://claude.ai/install.ps1 | iex

            # Refresh PATH to pick up claude command
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            # Verify installation
            if (Get-Command claude -ErrorAction SilentlyContinue) {
                $claudeVersion = claude --version 2>&1 | Select-Object -First 1
                Write-Host "✓ Claude Code installed: $claudeVersion" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Claude Code installation completed but 'claude' command not found" -ForegroundColor Yellow
                Write-Host "   You may need to restart your terminal" -ForegroundColor Yellow
                Write-Host "   Or install manually: https://docs.anthropic.com/en/docs/claude-code/install" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "⚠️  Failed to install Claude Code automatically" -ForegroundColor Yellow
            Write-Host "   Error: $_" -ForegroundColor Red
            Write-Host "   Please install manually: https://docs.anthropic.com/en/docs/claude-code/install" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "✅ Prerequisites ready" -ForegroundColor Green
    Write-Host ""

    # =============================================================================
    # INSTALL: amp command for Windows
    # =============================================================================

    Write-Host "🚀 Installing amp command..." -ForegroundColor Cyan
    Write-Host ""

    # Configuration
    $AMP_HOME = if ($env:AMP_HOME) { $env:AMP_HOME } else { "$env:USERPROFILE\.amp" }
    $AMP_SCRIPT = "$AMP_HOME\amp.ps1"
    $BASE_URL = "https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main"

    # Create installation directory
    Write-Host "📁 Creating installation directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $AMP_HOME | Out-Null

    # Check if we're running from a local clone (for development/testing)
    $SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
    $LOCAL_AMP_PS1 = Join-Path $SCRIPT_DIR "amp.ps1"
    $LOCAL_AMP_CMD = Join-Path $SCRIPT_DIR "amp.cmd"

    if (Test-Path $LOCAL_AMP_PS1) {
        # Use local copy (development mode)
        Write-Host "📦 Using local scripts from repository..." -ForegroundColor Cyan
        Copy-Item -Force $LOCAL_AMP_PS1 $AMP_SCRIPT
        if (Test-Path $LOCAL_AMP_CMD) {
            Copy-Item -Force $LOCAL_AMP_CMD "$AMP_HOME\amp.cmd"
        }
        Write-Host "✅ Installed local scripts" -ForegroundColor Green
    } else {
        # Download from GitHub
        Write-Host "📥 Downloading amp.ps1..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri "$BASE_URL/amp.ps1" -OutFile $AMP_SCRIPT
        Write-Host "✅ Downloaded amp.ps1" -ForegroundColor Green

        Write-Host "📥 Downloading amp.cmd..." -ForegroundColor Cyan
        $AMP_CMD = "$AMP_HOME\amp.cmd"
        Invoke-WebRequest -Uri "$BASE_URL/amp.cmd" -OutFile $AMP_CMD
        Write-Host "✅ Downloaded amp.cmd" -ForegroundColor Green
    }

    # Add to PATH for CMD access
    Write-Host ""
    Write-Host "🔧 Adding to PATH..." -ForegroundColor Cyan

    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$AMP_HOME*") {
        $newPath = "$currentPath;$AMP_HOME"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        $env:Path = "$env:Path;$AMP_HOME"  # Update current session
        Write-Host "  ✅ Added $AMP_HOME to PATH" -ForegroundColor Green
    } else {
        Write-Host "  ✓ Already in PATH" -ForegroundColor Green
    }

    # Add to PowerShell profile (for PowerShell/pwsh users)
    Write-Host ""
    Write-Host "🔧 Configuring PowerShell profile..." -ForegroundColor Cyan

    # Ensure profile exists
    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Force -Path $PROFILE | Out-Null
    }

    # Check if already configured
    if (Select-String -Path $PROFILE -Pattern "amp\.ps1" -Quiet) {
        Write-Host "  ✓ Profile already configured" -ForegroundColor Green
    } else {
        # Add source line
        @"

# Amplifier (amp command)
. $AMP_SCRIPT
"@ | Add-Content -Path $PROFILE
        Write-Host "  ✅ Added to PowerShell profile" -ForegroundColor Green
    }

    # Load amp command for current session
    . $AMP_SCRIPT

    # Success message
    Write-Host ""
    Write-Host "✅ Installation complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🚀 Using amp:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  CMD:        Just type 'amp' (works immediately)" -ForegroundColor Green
    Write-Host "  PowerShell: Reload profile first, then type 'amp'" -ForegroundColor Green
    Write-Host ""
    Write-Host "To reload PowerShell profile:" -ForegroundColor Yellow
    Write-Host "  . `$PROFILE" -ForegroundColor Green
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then cd to any project folder and type:" -ForegroundColor Cyan
    Write-Host "  amp" -ForegroundColor Green
    Write-Host ""
    Write-Host "📖 Documentation: https://github.com/kenotron-ms/amplifier-setup#readme" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "✗ Installation failed: $_" -ForegroundColor Red
    exit 1
}

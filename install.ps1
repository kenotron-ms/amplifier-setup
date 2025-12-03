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

    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

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
        if (-not (Test-Python)) {
            throw "Python installation failed"
        }
    }

    # Check/install Git
    Write-Host ""
    if (-not (Test-Git)) {
        Install-Git
        if (-not (Test-Git)) {
            throw "Git installation failed"
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

    # Check Claude Code
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        Write-Host "✓ Claude Code installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Claude Code not found (will be needed to use amp)" -ForegroundColor Yellow
        Write-Host "   Install from: https://docs.anthropic.com/en/docs/claude-code/install" -ForegroundColor Yellow
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

    # Download amp.ps1 (PowerShell script)
    Write-Host "📥 Downloading amp.ps1..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "$BASE_URL/amp.ps1" -OutFile $AMP_SCRIPT
    Write-Host "✅ Downloaded amp.ps1" -ForegroundColor Green

    # Download amp.cmd (CMD batch file)
    Write-Host "📥 Downloading amp.cmd..." -ForegroundColor Cyan
    $AMP_CMD = "$AMP_HOME\amp.cmd"
    Invoke-WebRequest -Uri "$BASE_URL/amp.cmd" -OutFile $AMP_CMD
    Write-Host "✅ Downloaded amp.cmd" -ForegroundColor Green

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

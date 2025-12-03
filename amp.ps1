# amp.ps1 - Amplifier wrapper script for Windows
#
# Usage:
#   Source this file in your PowerShell profile:
#     . ~/.amp/amp.ps1
#
#   Then run:
#     amp [claude-arguments...]
#
# This script:
# 1. Bootstraps the amplifier environment on first run (clone, install)
# 2. Checks for updates daily
# 3. Activates the virtual environment
# 4. Launches Claude Code with workspace context
#
# Environment:
#   AMP_HOME - State directory (default: ~/.amp)
#   AMP_AMPLIFIER_DIR - Amplifier clone directory (default: ~/.amp/main)
#
# State files:
#   $AMP_HOME/.amp_ready       - Marks bootstrap complete
#   $AMP_HOME/.amp_last_check  - Timestamp of last update check
#   $AMP_HOME/.amp.log         - Operation log

# Configuration
$script:AMP_HOME = if ($env:AMP_HOME) { $env:AMP_HOME } else { "$env:USERPROFILE\.amp" }
$script:AMP_AMPLIFIER_DIR = if ($env:AMP_AMPLIFIER_DIR) { $env:AMP_AMPLIFIER_DIR } else { "$env:USERPROFILE\.amp\main" }
$script:AMP_REPO = "https://github.com/microsoft/amplifier.git"
$script:UPDATE_CHECK_INTERVAL = 86400  # 24 hours in seconds

# State files
$script:AMP_READY_FLAG = "$script:AMP_HOME\.amp_ready"
$script:AMP_LAST_CHECK = "$script:AMP_HOME\.amp_last_check"
$script:AMP_LOG = "$script:AMP_HOME\.amp.log"

# ============================================================================
# Logging
# ============================================================================

function _amp_log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
    "[$timestamp] $Message" | Add-Content -Path $script:AMP_LOG
}

# ============================================================================
# Error Handling
# ============================================================================

function _amp_error {
    param(
        [string]$Message,
        [string]$Suggestion = ""
    )

    Write-Host "❌ Error: $Message" -ForegroundColor Red
    if ($Suggestion) {
        Write-Host "💡 Suggestion: $Suggestion" -ForegroundColor Yellow
    }

    _amp_log "ERROR: $Message"
    return $false
}

# ============================================================================
# Prerequisite Checks
# ============================================================================

function _amp_check_prereqs {
    $missing = @()

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        $missing += "git"
    }

    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        $missing += "python"
    }

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        $missing += "uv"
    }

    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        $missing += "claude"
    }

    if ($missing.Count -gt 0) {
        _amp_error "Missing required tools: $($missing -join ', ')" `
            "Install missing tools:`n  - git: https://git-scm.com/downloads`n  - python: https://www.python.org/downloads/`n  - uv: https://docs.astral.sh/uv/getting-started/installation/`n  - claude: https://docs.anthropic.com/en/docs/claude-code/install"
        return $false
    }

    _amp_log "Prerequisites check passed"
    return $true
}

# ============================================================================
# Clone
# ============================================================================

function _amp_clone {
    Write-Host "📦 Cloning amplifier repository..." -ForegroundColor Cyan

    try {
        git clone $script:AMP_REPO $script:AMP_AMPLIFIER_DIR 2>&1 | Out-Null

        # Verify critical files exist
        if (-not (Test-Path "$script:AMP_AMPLIFIER_DIR\Makefile")) {
            _amp_error "Cloned repository is incomplete or corrupted" `
                "Remove and retry: Remove-Item -Recurse -Force $script:AMP_AMPLIFIER_DIR; amp"
            return $false
        }

        _amp_log "Cloned repository to $script:AMP_AMPLIFIER_DIR"
        Write-Host "✅ Repository cloned" -ForegroundColor Green
        return $true
    } catch {
        _amp_error "Failed to clone repository" `
            "Check network connection and repository URL"
        return $false
    }
}

# ============================================================================
# Update
# ============================================================================

function _amp_update {
    $currentTime = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    # Check if update check is needed
    if (Test-Path $script:AMP_LAST_CHECK) {
        $lastCheck = [int](Get-Content $script:AMP_LAST_CHECK)
        $timeDiff = $currentTime - $lastCheck

        if ($timeDiff -lt $script:UPDATE_CHECK_INTERVAL) {
            # No update check needed yet
            return $true
        }
    }

    Write-Host "🔄 Checking for updates..." -ForegroundColor Cyan

    Push-Location $script:AMP_AMPLIFIER_DIR
    try {
        # Fetch latest
        git fetch origin main 2>&1 | Out-Null

        # Check if updates available
        $local = git rev-parse HEAD
        $remote = git rev-parse origin/main

        if ($local -ne $remote) {
            Write-Host "📥 Updates available, pulling..." -ForegroundColor Yellow

            # Pull updates
            git pull origin main 2>&1 | Out-Null

            # Run make install
            Write-Host "🔧 Running make install..." -ForegroundColor Cyan
            uv sync 2>&1 | Out-Null

            _amp_log "Updated from $local to $remote"
            Write-Host "✅ Updated to latest version" -ForegroundColor Green
        } else {
            _amp_log "Already up to date"
        }

        # Update last check timestamp
        $currentTime | Set-Content -Path $script:AMP_LAST_CHECK

        return $true
    } catch {
        _amp_error "Update check failed" "Check network connection"
        return $false
    } finally {
        Pop-Location
    }
}

# ============================================================================
# Install
# ============================================================================

function _amp_install {
    Write-Host "🔧 Running uv sync..." -ForegroundColor Cyan

    Push-Location $script:AMP_AMPLIFIER_DIR
    try {
        uv sync 2>&1 | Out-Null
        _amp_log "Ran uv sync"
        Write-Host "✅ Dependencies installed" -ForegroundColor Green
        return $true
    } catch {
        _amp_error "Installation failed" "Check that uv is installed correctly"
        return $false
    } finally {
        Pop-Location
    }
}

# ============================================================================
# Bootstrap
# ============================================================================

function _amp_bootstrap {
    Write-Host ""
    Write-Host "🚀 Amplifier Setup - First Run" -ForegroundColor Cyan
    Write-Host ""

    # Create AMP_HOME
    if (-not (Test-Path $script:AMP_HOME)) {
        New-Item -ItemType Directory -Force -Path $script:AMP_HOME | Out-Null
    }

    # Check prerequisites
    if (-not (_amp_check_prereqs)) {
        return $false
    }

    # Clone repository
    if (-not (_amp_clone)) {
        return $false
    }

    # Install dependencies
    if (-not (_amp_install)) {
        return $false
    }

    # Mark as ready
    $null | Set-Content -Path $script:AMP_READY_FLAG
    _amp_log "Bootstrap complete"

    Write-Host ""
    Write-Host "✅ Amplifier setup complete!" -ForegroundColor Green
    Write-Host ""

    return $true
}

# ============================================================================
# Main amp function
# ============================================================================

function amp {
    # Bootstrap if needed
    if (-not (Test-Path $script:AMP_READY_FLAG)) {
        if (-not (_amp_bootstrap)) {
            return 1
        }
    }

    # Check for updates (daily)
    if (-not (_amp_update)) {
        # Continue even if update check fails
        _amp_log "Update check failed, continuing with current version"
    }

    # Get workspace directory (current directory)
    $workspace = Get-Location

    # Set environment variable for Claude Code
    $env:AMP_WORKSPACE = $workspace

    # Activate venv and run Claude Code
    $venvActivate = "$script:AMP_AMPLIFIER_DIR\.venv\Scripts\Activate.ps1"

    if (-not (Test-Path $venvActivate)) {
        _amp_error "Virtual environment not found" "Run: Remove-Item $script:AMP_READY_FLAG; amp"
        return 1
    }

    # Activate venv in current scope
    & $venvActivate

    # Launch Claude Code with all arguments
    _amp_log "Launching claude with workspace: $workspace"
    & claude @args

    # Deactivate venv
    if (Get-Command deactivate -ErrorAction SilentlyContinue) {
        deactivate
    }
}

# Note: No need to export - the amp function is automatically available when this script is sourced

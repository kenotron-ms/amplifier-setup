@echo off
REM amp.cmd - Amplifier wrapper for Windows CMD
REM
REM Usage:
REM   Place this in your PATH or run directly:
REM     amp [claude-arguments...]
REM
REM This script bootstraps and launches amplifier via PowerShell

REM Configuration
set "AMP_HOME=%USERPROFILE%\.amp"
set "AMP_AMPLIFIER_DIR=%AMP_HOME%\main"
set "AMP_READY_FLAG=%AMP_HOME%\.amp_ready"

REM Check if PowerShell is available
where pwsh >nul 2>&1
if %errorlevel% equ 0 (
    set "POWERSHELL_CMD=pwsh"
) else (
    where powershell >nul 2>&1
    if %errorlevel% equ 0 (
        set "POWERSHELL_CMD=powershell"
    ) else (
        echo Error: PowerShell not found
        echo Please install PowerShell from: https://aka.ms/PSWindows
        exit /b 1
    )
)

REM Bootstrap if needed
if not exist "%AMP_READY_FLAG%" (
    echo.
    echo First run - bootstrapping amplifier...
    echo.
    %POWERSHELL_CMD% -NoProfile -ExecutionPolicy Bypass -File "%AMP_HOME%\amp.ps1" -Function _amp_bootstrap
    if %errorlevel% neq 0 (
        echo Bootstrap failed
        exit /b 1
    )
)

REM Get current directory (workspace)
set "AMP_WORKSPACE=%CD%"

REM Launch via PowerShell script
%POWERSHELL_CMD% -NoProfile -ExecutionPolicy Bypass -Command ^
    "& { . '%AMP_HOME%\amp.ps1'; amp %* }"

exit /b %errorlevel%

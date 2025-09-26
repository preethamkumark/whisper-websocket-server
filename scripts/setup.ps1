# Whisper WebSocket Server Setup Script
# This script sets up the development environment for the whisper-websocket-server project

param(
    [string]$GitReference = "",  # Optional: branch, tag, or commit to checkout
    [switch]$SkipVenv = $false,  # Skip virtual environment creation
    [switch]$Force = $false      # Force recreate virtual environment
)

$ErrorActionPreference = "Stop"

# Color functions for better output
function Write-Success { param([string]$Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param([string]$Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Warning { param([string]$Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host "❌ $Message" -ForegroundColor Red }

Write-Host "🚀 Whisper WebSocket Server - Setup Script" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta

# Get current script directory and project root
$ScriptDir = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Info "Project root: $ProjectRoot"
Set-Location $ProjectRoot

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Error "This doesn't appear to be a git repository. Please run from project root."
    exit 1
}

# Git version control operations
if ($GitReference) {
    Write-Info "Checking out git reference: $GitReference"
    try {
        git fetch origin
        git checkout $GitReference
        Write-Success "Successfully checked out: $GitReference"
    }
    catch {
        Write-Error "Failed to checkout $GitReference. Error: $($_.Exception.Message)"
        exit 1
    }
}

# Check Python installation
Write-Info "Checking Python installation..."
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Python not found in PATH"
    }
    Write-Success "Found Python: $pythonVersion"
    
    # Check Python version (require 3.8+)
    $versionMatch = $pythonVersion -match "Python (\d+)\.(\d+)"
    if ($versionMatch) {
        $majorVersion = [int]$matches[1]
        $minorVersion = [int]$matches[2]
        if ($majorVersion -lt 3 -or ($majorVersion -eq 3 -and $minorVersion -lt 8)) {
            Write-Error "Python 3.8 or higher is required. Found: $pythonVersion"
            exit 1
        }
    }
}
catch {
    Write-Error "Python is required but not found. Please install Python 3.8+ first."
    Write-Info "Download from: https://www.python.org/downloads/"
    exit 1
}

# Virtual environment setup
$venvPath = Join-Path $ProjectRoot ".venv"

if (-not $SkipVenv) {
    if (Test-Path $venvPath) {
        if ($Force) {
            Write-Warning "Removing existing virtual environment..."
            Remove-Item -Recurse -Force $venvPath
        }
        else {
            Write-Info "Virtual environment already exists at: $venvPath"
            Write-Info "Use -Force to recreate or -SkipVenv to skip this step"
        }
    }
    
    if (-not (Test-Path $venvPath)) {
        Write-Info "Creating virtual environment..."
        python -m venv $venvPath
        Write-Success "Virtual environment created at: $venvPath"
    }
    
    # Activate virtual environment
    $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
    if (Test-Path $activateScript) {
        Write-Info "Activating virtual environment..."
        & $activateScript
        Write-Success "Virtual environment activated"
    }
}

# Install/upgrade pip
Write-Info "Upgrading pip..."
python -m pip install --upgrade pip

# Install project dependencies
$requirementsFile = Join-Path $ProjectRoot "requirements.txt"
if (Test-Path $requirementsFile) {
    Write-Info "Installing project dependencies..."
    pip install -r $requirementsFile
    Write-Success "Dependencies installed successfully"
}
else {
    Write-Warning "requirements.txt not found. Skipping dependency installation."
}

# Verify key dependencies
Write-Info "Verifying key dependencies..."
$keyPackages = @("faster-whisper", "websockets", "torch")
foreach ($package in $keyPackages) {
    try {
        $version = pip show $package | Select-String "Version:" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
        if ($version) {
            Write-Success "$package $version installed"
        }
        else {
            Write-Warning "$package not found (may be optional)"
        }
    }
    catch {
        Write-Warning "Could not verify $package installation"
    }
}

# Check CUDA availability (optional but recommended)
Write-Info "Checking CUDA availability..."
try {
    python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('CUDA devices:', torch.cuda.device_count() if torch.cuda.is_available() else 0)"
}
catch {
    Write-Warning "Could not check CUDA availability. This is optional but recommended for better performance."
}

Write-Success "Setup completed successfully! 🎉"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run the server: .\scripts\run.ps1 start" -ForegroundColor White
Write-Host "2. Test with: python test_ws_client.py" -ForegroundColor White
Write-Host "3. Check README.md for usage instructions" -ForegroundColor White
Write-Host ""
Write-Host "Server will be available at: ws://localhost:9001" -ForegroundColor Green
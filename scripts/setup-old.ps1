# Whisper WebSocket Server Setup Script
# This script handles ONLY the setup process: Git operations, environment creation, and dependency installation
# Use run.ps1 to start the server after setup is complete

<#
.SYNOPSIS
    Sets up the Whisper WebSocket Server development environment

.DESCRIPTION
    This script handles:
    - Git repository cloning (if needed)
    - Git version control (branches, tags, commits)
    - Python virtual environment setup
    - Dependency installation and verification
    - CUDA availability checking

.PARAMETER GitHubUrl
    GitHub repository URL (default: https://github.com/preethamkumark/whisper-websocket-server.git)

.PARAMETER ProjectDir  
    Directory name for the project (default: whisper-websocket-server)

.PARAMETER SkipClone
    Skip git clone operation (use existing directory)

.PARAMETER ForceReinstall
    Force recreation of virtual environment and dependencies

.PARAMETER PythonCommand
    Python command to use (default: python)

.PARAMETER Branch
    Git branch to checkout

.PARAMETER Tag
    Git tag to checkout

.PARAMETER Commit
    Git commit to checkout

.PARAMETER ListVersions
    List available branches, tags, and commits

.PARAMETER ShowCurrentVersion
    Show current git version information

.EXAMPLE
    .\setup.ps1
    Basic setup with default options

.EXAMPLE
    .\setup.ps1 -Branch "development"
    Setup and checkout development branch

.EXAMPLE
    .\setup.ps1 -Tag "v1.0.0"
    Setup and checkout specific version tag

.EXAMPLE
    .\setup.ps1 -ListVersions
    Show available versions without setup

.EXAMPLE
    .\setup.ps1 -SkipClone -ForceReinstall
    Reinstall in existing directory

.NOTES
    Author: GitHub Copilot
    Requires: Git, Python 3.8+
    Recommended: CUDA-capable GPU for better performance
#>

param(
    [Parameter()]
    [string]$GitHubUrl = "https://github.com/preethamkumark/whisper-websocket-server.git",
    
    [Parameter()]
    [string]$ProjectDir = "whisper-websocket-server",
    
    [Parameter()]
    [switch]$SkipClone = $false,
    
    [Parameter()]
    [switch]$ForceReinstall = $false,
    
    [Parameter()]
    [string]$PythonCommand = "python",
    
    [Parameter()]
    [string]$Branch = "",
    
    [Parameter()]
    [string]$Tag = "",
    
    [Parameter()]
    [string]$Commit = "",
    
    [Parameter()]
    [switch]$ListVersions = $false,
    
    [Parameter()]
    [switch]$ShowCurrentVersion = $false
)

# Colors for output
$Green = "Green"
$Yellow = "Yellow" 
$Red = "Red"
$Blue = "Cyan"

function Write-Step {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $Red
}

function Test-Command {
    param([string]$Command)
    try {
        & $Command --version > $null 2>&1
        return $true
    }
    catch {
        return $false
    }
}

function Get-GitVersions {
    param([string]$RepoUrl)
    
    Write-Step "Fetching Available Versions"
    
    try {
        # Get tags (releases)
        Write-Host "Available Tags/Releases:" -ForegroundColor $Green
        $tags = git ls-remote --tags $RepoUrl | ForEach-Object {
            if ($_ -match 'refs/tags/(.+)$') {
                $matches[1] -replace '\^\{\}', ''
            }
        } | Sort-Object -Unique | Where-Object { $_ -notlike '*^*' }
        
        if ($tags.Count -gt 0) {
            $tags | ForEach-Object { Write-Host "  - $_" -ForegroundColor $Yellow }
        } else {
            Write-Host "  No tags found" -ForegroundColor $Yellow
        }
        
        Write-Host ""
        
        # Get branches
        Write-Host "Available Branches:" -ForegroundColor $Green
        $branches = git ls-remote --heads $RepoUrl | ForEach-Object {
            if ($_ -match 'refs/heads/(.+)$') {
                $matches[1]
            }
        }
        
        if ($branches.Count -gt 0) {
            $branches | ForEach-Object { Write-Host "  - $_" -ForegroundColor $Yellow }
        } else {
            Write-Host "  No branches found" -ForegroundColor $Yellow
        }
        
        Write-Host ""
        
        # Get recent commits
        Write-Host "Recent Commits (last 5):" -ForegroundColor $Green
        $commits = git ls-remote $RepoUrl | Where-Object { $_ -match 'HEAD' } | ForEach-Object {
            $hash = ($_ -split '\s+')[0]
            $hash.Substring(0, 7)
        }
        
        if ($commits.Count -gt 0) {
            $commits | ForEach-Object { Write-Host "  - $_" -ForegroundColor $Yellow }
        }
        
    }
    catch {
        Write-Error "Failed to fetch version information: $_"
    }
}

function Show-CurrentVersion {
    param([string]$ProjectPath)
    
    if (!(Test-Path $ProjectPath)) {
        Write-Error "Project directory not found: $ProjectPath"
        return
    }
    
    Push-Location $ProjectPath
    try {
        Write-Step "Current Version Information"
        
        # Current branch/commit
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($branch) {
            Write-Host "  Current Branch: $branch" -ForegroundColor $Yellow
        }
        
        $commit = git rev-parse --short HEAD 2>$null
        if ($commit) {
            Write-Host "  Current Commit: $commit" -ForegroundColor $Yellow
        }
        
        # Last commit message
        $lastCommit = git log -1 --pretty=format:"%s" 2>$null
        if ($lastCommit) {
            Write-Host "  Last Commit: $lastCommit" -ForegroundColor $Yellow
        }
        
        # Show if there are uncommitted changes
        $status = git status --porcelain 2>$null
        if ($status) {
            Write-Warning "There are uncommitted changes in the working directory"
        } else {
            Write-Success "Working directory is clean"
        }
    }
    catch {
        Write-Error "Failed to get version information: $_"
    }
    finally {
        Pop-Location
    }
}

function Set-GitVersion {
    param(
        [string]$ProjectPath,
        [string]$Branch,
        [string]$Tag,
        [string]$Commit
    )
    
    if (!(Test-Path $ProjectPath)) {
        Write-Error "Project directory not found: $ProjectPath"
        return $false
    }
    
    Push-Location $ProjectPath
    try {
        # Fetch latest changes
        Write-Host "Fetching latest changes..." -ForegroundColor $Blue
        git fetch --all --tags 2>$null
        
        if ($Tag) {
            Write-Host "Checking out tag: $Tag" -ForegroundColor $Blue
            git checkout tags/$Tag 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to checkout tag: $Tag"
                return $false
            }
            Write-Success "Checked out tag: $Tag"
        }
        elseif ($Branch) {
            Write-Host "Checking out branch: $Branch" -ForegroundColor $Blue
            git checkout $Branch 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to checkout branch: $Branch"
                return $false
            }
            git pull origin $Branch 2>$null
            Write-Success "Checked out and updated branch: $Branch"
        }
        elseif ($Commit) {
            Write-Host "Checking out commit: $Commit" -ForegroundColor $Blue
            git checkout $Commit 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to checkout commit: $Commit"
                return $false
            }
            Write-Success "Checked out commit: $Commit"
        }
        
        return $true
    }
    catch {
        Write-Error "Git operation failed: $_"
        return $false
    }
    finally {
        Pop-Location
    }
}

# Main Script Logic
Write-Host ""
Write-Host "🚀 Whisper WebSocket Server - Setup Script" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host ""

# Handle special operations first
if ($ListVersions) {
    Get-GitVersions -RepoUrl $GitHubUrl
    exit 0
}

# Determine project path
$CurrentDir = Get-Location
$ScriptDir = $PSScriptRoot
$ParentDir = Split-Path -Parent $ScriptDir

if ($SkipClone) {
    # Use current directory or parent directory
    if (Test-Path "$CurrentDir\.git") {
        $ProjectPath = $CurrentDir
    } elseif (Test-Path "$ParentDir\.git") {
        $ProjectPath = $ParentDir
    } else {
        Write-Error "Not in a git repository. Use without -SkipClone to clone from GitHub."
        exit 1
    }
} else {
    # Set up for cloning
    $ProjectPath = Join-Path $CurrentDir $ProjectDir
}

if ($ShowCurrentVersion) {
    Show-CurrentVersion -ProjectPath $ProjectPath
    exit 0
}

# Step 1: Git Operations
if (!$SkipClone) {
    Write-Step "Git Repository Setup"
    
    # Check if Git is available
    if (!(Test-Command "git")) {
        Write-Error "Git is required but not found. Please install Git first."
        Write-Host "Download from: https://git-scm.com/download/windows" -ForegroundColor $Yellow
        exit 1
    }
    
    # Clone if directory doesn't exist
    if (!(Test-Path $ProjectPath)) {
        Write-Host "Cloning repository from: $GitHubUrl" -ForegroundColor $Blue
        git clone $GitHubUrl $ProjectPath
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to clone repository"
            exit 1
        }
        Write-Success "Repository cloned successfully"
    } else {
        Write-Warning "Project directory already exists: $ProjectPath"
        Write-Host "Use -ForceReinstall to remove and re-clone" -ForegroundColor $Yellow
        if ($ForceReinstall) {
            Write-Warning "Removing existing directory..."
            Remove-Item -Recurse -Force $ProjectPath
            Write-Host "Cloning repository from: $GitHubUrl" -ForegroundColor $Blue
            git clone $GitHubUrl $ProjectPath
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to clone repository"
                exit 1
            }
            Write-Success "Repository re-cloned successfully"
        }
    }
}

# Navigate to project directory
Set-Location $ProjectPath

# Handle version checkout if specified
if ($Branch -or $Tag -or $Commit) {
    Write-Step "Git Version Control"
    $success = Set-GitVersion -ProjectPath $ProjectPath -Branch $Branch -Tag $Tag -Commit $Commit
    if (!$success) {
        Write-Error "Failed to checkout specified version"
        exit 1
    }
}

# Step 2: Python Installation Check
Write-Step "Python Environment Validation"

if (!(Test-Command $PythonCommand)) {
    Write-Error "Python is required but not found. Please install Python 3.8+ first."
    Write-Host "Download from: https://www.python.org/downloads/" -ForegroundColor $Yellow
    exit 1
}

try {
    $pythonVersion = & $PythonCommand --version 2>&1
    Write-Success "Found Python: $pythonVersion"
    
    # Check Python version (require 3.8+)
    if ($pythonVersion -match "Python (\d+)\.(\d+)") {
        $majorVersion = [int]$matches[1]
        $minorVersion = [int]$matches[2]
        if ($majorVersion -lt 3 -or ($majorVersion -eq 3 -and $minorVersion -lt 8)) {
            Write-Error "Python 3.8 or higher is required. Found: $pythonVersion"
            exit 1
        }
    }
}
catch {
    Write-Error "Failed to check Python version: $_"
    exit 1
}

# Step 3: Virtual Environment Setup
Write-Step "Virtual Environment Setup"

$venvPath = ".venv"
$venvFullPath = Join-Path $ProjectPath $venvPath

if (Test-Path $venvFullPath) {
    if ($ForceReinstall) {
        Write-Warning "Removing existing virtual environment..."
        Remove-Item -Recurse -Force $venvFullPath
    } else {
        Write-Success "Virtual environment already exists"
        Write-Host "Use -ForceReinstall to recreate it" -ForegroundColor $Yellow
    }
}

if (!(Test-Path $venvFullPath)) {
    Write-Host "Creating virtual environment..." -ForegroundColor $Blue
    & $PythonCommand -m venv $venvPath
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create virtual environment"
        exit 1
    }
    Write-Success "Virtual environment created"
}

# Activate virtual environment
$activateScript = Join-Path $venvFullPath "Scripts\Activate.ps1"
if (Test-Path $activateScript) {
    Write-Host "Activating virtual environment..." -ForegroundColor $Blue
    try {
        & $activateScript
        Write-Success "Virtual environment activated"
    }
    catch {
        Write-Warning "Failed to activate virtual environment, continuing with system Python"
    }
}

# Step 4: Dependency Installation
Write-Step "Installing Dependencies"

# Upgrade pip first
Write-Host "Upgrading pip..." -ForegroundColor $Blue
& $PythonCommand -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Failed to upgrade pip, continuing anyway..."
}

# Install requirements
$requirementsPath = "requirements.txt"
if (Test-Path $requirementsPath) {
    Write-Host "Installing project dependencies..." -ForegroundColor $Blue
    pip install -r $requirementsPath
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install dependencies"
        exit 1
    }
    Write-Success "All dependencies installed successfully"
} else {
    Write-Warning "requirements.txt not found in project root"
    Write-Host "Expected path: $(Join-Path $ProjectPath $requirementsPath)" -ForegroundColor $Yellow
}

# Step 5: Verification
Write-Step "Installation Verification"

# Check key dependencies
Write-Host "Verifying key packages..." -ForegroundColor $Blue
$keyPackages = @(
    @{Name="faster-whisper"; Description="Whisper inference engine"},
    @{Name="websockets"; Description="WebSocket server library"},
    @{Name="torch"; Description="PyTorch (for GPU acceleration)"}
)

$allInstalled = $true
foreach ($pkg in $keyPackages) {
    try {
        $result = pip show $pkg.Name 2>$null
        if ($result) {
            $version = ($result | Select-String "Version:").ToString().Split(":")[1].Trim()
            Write-Success "$($pkg.Name) $version - $($pkg.Description)"
        } else {
            Write-Warning "$($pkg.Name) not found - $($pkg.Description)"
            $allInstalled = $false
        }
    }
    catch {
        Write-Warning "Could not verify $($pkg.Name) - $($pkg.Description)"
        $allInstalled = $false
    }
}

# Check CUDA availability
Write-Host "`nChecking CUDA support..." -ForegroundColor $Blue
Write-Host "Run 'python -c `"import torch; print(torch.cuda.is_available())`"' to check CUDA manually" -ForegroundColor $Yellow

# Final status
Write-Step "Setup Complete"

if ($allInstalled) {
    Write-Success "🎉 Whisper WebSocket Server setup completed successfully!"
} else {
    Write-Warning "⚠️ Setup completed with some warnings. Check dependency installation above."
}

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor $Yellow
Write-Host "  1. Start server: .\scripts\run.ps1 start" -ForegroundColor White
Write-Host "  2. Test client: python test_ws_client.py" -ForegroundColor White  
Write-Host "  3. Read docs: README.md" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Server Info:" -ForegroundColor $Yellow
Write-Host "  WebSocket URL: ws://localhost:9001" -ForegroundColor White
Write-Host "  Project Path: $ProjectPath" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Automation Scripts:" -ForegroundColor $Yellow
Write-Host "  Setup: .\scripts\setup.ps1 [options]" -ForegroundColor White
Write-Host "  Run: .\scripts\run.ps1 start" -ForegroundColor White
Write-Host "  Git: .\scripts\quick-push.ps1" -ForegroundColor White
Write-Host ""

# Show current version info
Show-CurrentVersion -ProjectPath $ProjectPath
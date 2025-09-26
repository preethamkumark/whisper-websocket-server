#!/usr/bin/env pwsh
# Whisper WebSocket Server Setup Script - Basic Version

param(
    [switch]$ListVersions = $false,
    [switch]$ShowCurrentVersion = $false,
    [string]$GitHubUrl = "https://github.com/preethamkumark/whisper-websocket-server.git"
)

function Write-ColorHost {
    param([string]$Message, [string]$Color = "White")
    switch ($Color) {
        "Red" { Write-Host $Message -ForegroundColor Red }
        "Green" { Write-Host $Message -ForegroundColor Green }
        "Yellow" { Write-Host $Message -ForegroundColor Yellow }
        "Cyan" { Write-Host $Message -ForegroundColor Cyan }
        "Magenta" { Write-Host $Message -ForegroundColor Magenta }
        default { Write-Host $Message -ForegroundColor White }
    }
}

Write-ColorHost "🚀 Whisper WebSocket Server - Setup Script" "Magenta"
Write-ColorHost "=============================================" "Magenta"

if ($ListVersions) {
    Write-ColorHost "`n=== Fetching Available Versions ===" "Cyan"
    
    try {
        Write-ColorHost "Available Branches:" "Green"
        $branches = git ls-remote --heads $GitHubUrl
        if ($branches) {
            $branches | ForEach-Object {
                if ($_ -match 'refs/heads/(.+)$') {
                    Write-ColorHost "  - $($matches[1])" "Yellow"
                }
            }
        }
        
        Write-ColorHost "`nAvailable Tags:" "Green"
        $tags = git ls-remote --tags $GitHubUrl
        if ($tags) {
            $tags | ForEach-Object {
                if ($_ -match 'refs/tags/(.+)$') {
                    $tagName = $matches[1] -replace '\^\{\}', ''
                    if ($tagName -notlike '*^*') {
                        Write-ColorHost "  - $tagName" "Yellow"
                    }
                }
            }
        }
    }
    catch {
        Write-ColorHost "Error fetching versions: $_" "Red"
    }
    
    exit 0
}

if ($ShowCurrentVersion) {
    Write-ColorHost "`n=== Current Version Information ===" "Cyan"
    
    if (Test-Path ".git") {
        try {
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            $commit = git rev-parse --short HEAD 2>$null
            $lastCommit = git log -1 --pretty=format:"%s" 2>$null
            
            Write-ColorHost "Current Branch: $branch" "Yellow"
            Write-ColorHost "Current Commit: $commit" "Yellow" 
            Write-ColorHost "Last Commit: $lastCommit" "Yellow"
            
            $status = git status --porcelain 2>$null
            if ($status) {
                Write-ColorHost "Status: Uncommitted changes present" "Red"
            } else {
                Write-ColorHost "Status: Working directory clean" "Green"
            }
        }
        catch {
            Write-ColorHost "Error getting version info: $_" "Red"
        }
    } else {
        Write-ColorHost "Not a git repository" "Red"
    }
    
    exit 0
}

# Regular setup process
Write-ColorHost "`n=== Python Environment Check ===" "Cyan"

$pythonCheck = python --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-ColorHost "✓ Found Python: $pythonCheck" "Green"
} else {
    Write-ColorHost "✗ Python not found. Please install Python 3.8+" "Red"
    exit 1
}

Write-ColorHost "`n=== Virtual Environment ===" "Cyan"

if (Test-Path ".venv") {
    Write-ColorHost "✓ Virtual environment already exists" "Green"
} else {
    Write-ColorHost "Creating virtual environment..." "Yellow"
    python -m venv .venv
    Write-ColorHost "✓ Virtual environment created" "Green"
}

Write-ColorHost "`n=== Installing Dependencies ===" "Cyan"

if (Test-Path "requirements.txt") {
    Write-ColorHost "Installing from requirements.txt..." "Yellow"
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    Write-ColorHost "✓ Dependencies installed" "Green"
} else {
    Write-ColorHost "⚠ requirements.txt not found" "Yellow"
}

Write-ColorHost "`n✅ Setup Complete!" "Green"
Write-ColorHost "`nNext steps:" "Yellow"
Write-ColorHost "1. Run server: .\scripts\run.ps1 start" "White"
Write-ColorHost "2. Test client: python test_ws_client.py" "White"
Write-ColorHost "3. WebSocket URL: ws://localhost:9001" "White"
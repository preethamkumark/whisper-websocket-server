# Git Push and Merge Script for Voice Q&A Backend
# This script handles committing, pushing, and merging changes to GitHub

param(
    [Parameter()]
    [string]$CommitMessage = "",
    
    [Parameter()]
    [string]$SourceBranch = "",
    
    [Parameter()]
    [string]$TargetBranch = "main",
    
    [Parameter()]
    [switch]$Force = $false,
    
    [Parameter()]
    [switch]$SkipTests = $false,
    
    [Parameter()]
    [switch]$AutoMerge = $false
)

# Colors for output
$Green = "Green"
$Yellow = "Yellow" 
$Red = "Red"
$Blue = "Cyan"
$White = "White"

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

function Test-GitRepository {
    """Check if current directory is a Git repository"""
    if (!(Test-Path ".git")) {
        Write-Error "Not a Git repository. Please run this script from the project root."
        return $false
    }
    
    # Check if we have a remote
    $remotes = git remote -v 2>$null
    if (!$remotes) {
        Write-Error "No Git remote configured. Please add a remote first."
        return $false
    }
    
    Write-Success "Git repository detected"
    return $true
}

function Get-GitStatus {
    """Get current Git status"""
    Write-Step "Checking Git Status"
    
    # Check for uncommitted changes
    $status = git status --porcelain
    if ($status) {
        Write-Host "Uncommitted changes found:" -ForegroundColor $Yellow
        git status --short | ForEach-Object {
            Write-Host "  $_" -ForegroundColor $White
        }
        return $status
    } else {
        Write-Success "Working directory is clean"
        return $null
    }
}

function Get-CurrentBranch {
    """Get current branch name"""
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch) {
        Write-Host "Current branch: $branch" -ForegroundColor $Green
        return $branch
    } else {
        Write-Error "Could not determine current branch"
        return $null
    }
}

function Test-Changes {
    """Test the application if not skipped"""
    if ($SkipTests) {
        Write-Warning "Skipping tests as requested"
        return $true
    }
    
    Write-Step "Running Basic Tests"
    
    # Check if Python files have syntax errors
    $pythonFiles = Get-ChildItem -Filter "*.py" -Recurse | Where-Object { $_.Name -ne "__pycache__" }
    
    foreach ($file in $pythonFiles) {
        Write-Host "Checking syntax: $($file.Name)" -ForegroundColor $White
        python -m py_compile $file.FullName 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Syntax error in $($file.Name)"
            return $false
        }
    }
    
    Write-Success "All Python files have valid syntax"
    return $true
}

function Add-CommitPush {
    param(
        [string]$Message,
        [string]$Branch
    )
    
    Write-Step "Committing and Pushing Changes"
    
    # Add all changes
    Write-Host "Adding all changes to staging..." -ForegroundColor $Blue
    git add .
    
    # Show what's being committed
    Write-Host "`nFiles to be committed:" -ForegroundColor $Yellow
    git diff --cached --name-status | ForEach-Object {
        Write-Host "  $_" -ForegroundColor $White
    }
    
    # Commit with message
    if ($Message) {
        Write-Host "`nCommitting with message: $Message" -ForegroundColor $Blue
        git commit -m $Message
    } else {
        Write-Host "`nOpening editor for commit message..." -ForegroundColor $Blue
        git commit
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Commit failed"
        return $false
    }
    
    # Push to remote
    Write-Host "`nPushing to remote..." -ForegroundColor $Blue
    git push origin $Branch
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Push failed"
        return $false
    }
    
    Write-Success "Successfully committed and pushed to $Branch"
    return $true
}

function Merge-ToMainBranch {
    param(
        [string]$SourceBranch,
        [string]$TargetBranch
    )
    
    Write-Step "Merging $SourceBranch to $TargetBranch"
    
    # Fetch latest changes
    Write-Host "Fetching latest changes..." -ForegroundColor $Blue
    git fetch origin
    
    # Switch to target branch
    Write-Host "Switching to $TargetBranch..." -ForegroundColor $Blue
    git checkout $TargetBranch
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to checkout $TargetBranch"
        return $false
    }
    
    # Pull latest changes
    Write-Host "Pulling latest $TargetBranch..." -ForegroundColor $Blue
    git pull origin $TargetBranch
    
    # Merge source branch
    Write-Host "Merging $SourceBranch into $TargetBranch..." -ForegroundColor $Blue
    git merge $SourceBranch --no-ff -m "Merge $SourceBranch into $TargetBranch"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Merge failed. Please resolve conflicts manually."
        return $false
    }
    
    # Push merged changes
    Write-Host "Pushing merged $TargetBranch..." -ForegroundColor $Blue
    git push origin $TargetBranch
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to push merged $TargetBranch"
        return $false
    }
    
    Write-Success "Successfully merged and pushed $TargetBranch"
    return $true
}

function Show-Summary {
    param([string]$Branch)
    
    Write-Step "Summary"
    
    # Show recent commits
    Write-Host "Recent commits on $Branch`:" -ForegroundColor $Green
    git log --oneline -5 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor $White
    }
    
    # Show remote URL
    $remoteUrl = git config --get remote.origin.url
    Write-Host "`nRepository: $remoteUrl" -ForegroundColor $Green
    Write-Host "Branch: $Branch" -ForegroundColor $Green
    
    # Show GitHub links
    if ($remoteUrl -match "github.com[:/](.+)/(.+?)(?:\.git)?$") {
        $owner = $matches[1]
        $repo = $matches[2] -replace "\.git$", ""
        Write-Host "`n🔗 GitHub Links:" -ForegroundColor $Yellow
        Write-Host "   Repository: https://github.com/$owner/$repo" -ForegroundColor $Blue
        Write-Host "   Commits: https://github.com/$owner/$repo/commits/$Branch" -ForegroundColor $Blue
        Write-Host "   Create PR: https://github.com/$owner/$repo/compare/$Branch" -ForegroundColor $Blue
    }
}

# Main script execution
Write-Host "Git Push and Merge Script" -ForegroundColor $Blue
Write-Host "=========================" -ForegroundColor $Blue

# Validate Git repository
if (!(Test-GitRepository)) {
    exit 1
}

# Get current status
$uncommittedChanges = Get-GitStatus
$currentBranch = Get-CurrentBranch

if (!$currentBranch) {
    exit 1
}

# Determine source branch
if (!$SourceBranch) {
    $SourceBranch = $currentBranch
}

# Handle uncommitted changes
if ($uncommittedChanges) {
    if (!$Force) {
        Write-Warning "You have uncommitted changes."
        $response = Read-Host "Do you want to commit and push them? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Operation cancelled by user" -ForegroundColor $Yellow
            exit 0
        }
    }
    
    # Get commit message if not provided
    if (!$CommitMessage) {
        $CommitMessage = Read-Host "Enter commit message"
        if (!$CommitMessage) {
            $CommitMessage = "Update: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        }
    }
    
    # Run tests
    if (!(Test-Changes)) {
        Write-Error "Tests failed. Please fix issues before committing."
        exit 1
    }
    
    # Commit and push
    if (!(Add-CommitPush -Message $CommitMessage -Branch $SourceBranch)) {
        exit 1
    }
} else {
    Write-Success "No uncommitted changes to push"
}

# Handle merging
if ($SourceBranch -ne $TargetBranch) {
    if ($AutoMerge) {
        $shouldMerge = $true
    } else {
        Write-Host "`nDo you want to merge $SourceBranch into $TargetBranch?" -ForegroundColor $Yellow
        $response = Read-Host "(y/N)"
        $shouldMerge = ($response -eq 'y' -or $response -eq 'Y')
    }
    
    if ($shouldMerge) {
        if (!(Merge-ToMainBranch -SourceBranch $SourceBranch -TargetBranch $TargetBranch)) {
            exit 1
        }
        $finalBranch = $TargetBranch
    } else {
        $finalBranch = $SourceBranch
    }
} else {
    Write-Success "Already on target branch $TargetBranch"
    $finalBranch = $TargetBranch
}

# Show summary
Show-Summary -Branch $finalBranch

Write-Host "`n🎉 All operations completed successfully!" -ForegroundColor $Green
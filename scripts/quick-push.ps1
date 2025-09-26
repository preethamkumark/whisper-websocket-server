# Quick Git Push Script
# Simple one-liner to commit and push current changes

param(
    [Parameter()]
    [string]$Message = "Quick update: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

Write-Host "Quick Git Push Script" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

# Check if we're in a git repository
if (!(Test-Path ".git")) {
    Write-Host "❌ Not a Git repository" -ForegroundColor Red
    exit 1
}

# Get current branch
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "📍 Current branch: $branch" -ForegroundColor Green

# Check for changes
$status = git status --porcelain
if (!$status) {
    Write-Host "✅ No changes to commit" -ForegroundColor Yellow
    exit 0
}

# Show what will be committed
Write-Host "`n📝 Changes to commit:" -ForegroundColor Yellow
git status --short

Write-Host "`n💬 Commit message: $Message" -ForegroundColor Cyan

# Quick commit and push
Write-Host "`n🚀 Adding, committing, and pushing..." -ForegroundColor Blue

git add .
git commit -m $Message
git push origin $branch

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] Successfully pushed to GitHub!" -ForegroundColor Green
    
    # Show recent commits
    Write-Host "`nRecent commits:" -ForegroundColor Cyan
    git log --oneline -3
    
    # Show GitHub URL if available
    $remoteUrl = git config --get remote.origin.url
    if ($remoteUrl -match "github.com[:/](.+)/(.+?)(?:\.git)?$") {
        $owner = $matches[1]
        $repo = $matches[2] -replace "\.git$", ""
        Write-Host "`nView on GitHub: https://github.com/$owner/$repo" -ForegroundColor Blue
    }
} else {
    Write-Host "`n[ERROR] Push failed!" -ForegroundColor Red
    exit 1
}
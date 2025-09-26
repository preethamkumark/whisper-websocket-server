#!/usr/bin/env pwsh
# Quick GitHub Setup Script
# Run this after creating the repository on GitHub

Write-Host "🚀 Connecting whisper-websocket-server to GitHub..." -ForegroundColor Magenta
Write-Host "=================================================" -ForegroundColor Magenta

# Add the correct remote
Write-Host "Adding GitHub remote..." -ForegroundColor Cyan
git remote add origin https://github.com/preethamkumark/whisper-websocket-server.git

# Verify remote was added
Write-Host "`nVerifying remote configuration..." -ForegroundColor Cyan
git remote -v

# Push to GitHub
Write-Host "`nPushing to GitHub..." -ForegroundColor Cyan
git push -u origin master

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Successfully connected to GitHub!" -ForegroundColor Green
    Write-Host "Repository URL: https://github.com/preethamkumark/whisper-websocket-server" -ForegroundColor White
    Write-Host "`nYou can now use the automation scripts:" -ForegroundColor Yellow
    Write-Host "- .\scripts\quick-push.ps1 -m 'commit message'" -ForegroundColor White
    Write-Host "- .\scripts\git-push-merge.ps1" -ForegroundColor White
} else {
    Write-Host "`n❌ Push failed. Please check:" -ForegroundColor Red
    Write-Host "1. Repository exists on GitHub" -ForegroundColor White
    Write-Host "2. You have push permissions" -ForegroundColor White
    Write-Host "3. Your Git credentials are set up" -ForegroundColor White
}
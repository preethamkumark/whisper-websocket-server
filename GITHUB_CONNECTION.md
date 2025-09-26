# GitHub Connection Commands for whisper-websocket-server

## After Creating the Repository on GitHub

Run these commands in PowerShell from the whisper-websocket-server directory:

```powershell
# Add the correct remote (using your actual GitHub username)
git remote add origin https://github.com/preethamkumark/whisper-websocket-server.git

# Verify the remote was added correctly
git remote -v

# Push all commits to GitHub
git push -u origin master
```

## Verification Steps

After pushing, you should see:
- ✅ All files visible on GitHub
- ✅ README.md displayed as the homepage
- ✅ 2 commits in the history:
  1. "Initial commit: WebSocket server for real-time Whisper transcription"
  2. "Add development automation scripts and GitHub setup guide"

## If You Get Permission Errors

If you get authentication errors, you may need to:

1. **Set up Personal Access Token** (if using HTTPS):
   ```powershell
   git config --global credential.helper manager
   ```

2. **Or use SSH** (if you have SSH keys set up):
   ```powershell
   git remote set-url origin git@github.com:preethamkumark/whisper-websocket-server.git
   ```

## Current Repository Status

- ✅ Local git repository initialized
- ✅ All files committed locally (2 commits)
- ✅ Scripts and documentation ready
- ⏳ Waiting for GitHub repository creation
- ⏳ Need to push to remote

## Next Steps After GitHub Setup

Once connected, you can use the automation scripts:
- `.\scripts\quick-push.ps1` - for quick commits and pushes
- `.\scripts\git-push-merge.ps1` - for full workflow with merge to main
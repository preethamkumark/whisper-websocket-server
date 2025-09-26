# Git Management Scripts

This directory contains automated Git scripts to streamline your GitHub workflow for the Voice Q&A Backend project.

## 🚀 Available Scripts

### 1. **`scripts/git-push-merge.ps1`** (PowerShell - Full Featured)

**Complete Git workflow management with safety checks and merging capabilities.**

#### Features:
- ✅ **Safety Checks**: Validates Git repository and remote configuration
- ✅ **Automatic Testing**: Runs Python syntax checks before committing
- ✅ **Smart Staging**: Shows exactly what will be committed
- ✅ **Branch Management**: Handles merging between branches
- ✅ **Interactive Prompts**: Asks for confirmation on important actions
- ✅ **GitHub Integration**: Shows repository links and PR creation URLs

#### Usage:
```powershell
# Basic usage - commit and push current changes
.\scripts\git-push-merge.ps1

# With custom commit message
.\scripts\git-push-merge.ps1 -CommitMessage "Add new feature"

# Merge feature branch to main
.\scripts\git-push-merge.ps1 -SourceBranch "feature/new-ui" -TargetBranch "main"

# Force operations without prompts
.\scripts\git-push-merge.ps1 -Force -AutoMerge

# Skip tests (faster but less safe)
.\scripts\git-push-merge.ps1 -SkipTests
```

### 2. **`scripts/git-push-merge.bat`** (Batch - Simple Version)

**Simplified Git workflow for Command Prompt users.**

#### Usage:
```cmd
# Basic usage
scripts\git-push-merge.bat

# With commit message
scripts\git-push-merge.bat "Add new feature"

# With source and target branches
scripts\git-push-merge.bat "Merge changes" feature-branch main
```

### 3. **`scripts/quick-push.ps1`** (PowerShell - Quick & Easy)

**One-command solution for everyday commits.**

#### Features:
- ✅ **Super Fast**: Minimal prompts, maximum speed
- ✅ **Auto-Timestamps**: Generates commit messages with current date/time
- ✅ **Status Display**: Shows what's being committed
- ✅ **GitHub Links**: Direct links to view changes

#### Usage:
```powershell
# Quick push with auto-generated message
.\scripts\quick-push.ps1

# Quick push with custom message
.\scripts\quick-push.ps1 -Message "Fix bug in authentication"
```

## 📋 **Workflow Examples**

### **Daily Development Workflow:**
```powershell
# Make your changes...

# Quick commit and push
.\scripts\quick-push.ps1 -Message "Implement user authentication"

# Or use the full workflow for important changes
.\scripts\git-push-merge.ps1 -CommitMessage "Major refactor: improve performance"
```

### **Feature Branch Workflow:**
```powershell
# Create and work on feature branch
git checkout -b feature/new-dashboard
# Make changes...

# Push feature branch
.\scripts\quick-push.ps1 -Message "Add dashboard components"

# Merge to main when ready
.\scripts\git-push-merge.ps1 -SourceBranch "feature/new-dashboard" -TargetBranch "main" -AutoMerge
```

### **Release Workflow:**
```powershell
# Prepare release
.\scripts\git-push-merge.ps1 -CommitMessage "Release v1.2.0: Add advanced logging" -Force

# Tag the release (manual)
git tag v1.2.0
git push origin v1.2.0
```

## 🛡️ **Safety Features**

### **Built-in Protections:**
1. **Repository Validation**: Ensures you're in a Git repository
2. **Remote Check**: Verifies GitHub connection before operations
3. **Syntax Testing**: Checks Python files for errors before committing
4. **Change Preview**: Shows exactly what will be committed
5. **Conflict Detection**: Handles merge conflicts gracefully
6. **Backup Branch**: Preserves original branch during merges

### **Interactive Confirmations:**
- ✅ Asks before committing uncommitted changes
- ✅ Confirms merge operations between branches
- ✅ Shows file changes before staging
- ✅ Provides GitHub URLs for verification

## 📊 **Script Comparison**

| Feature | git-push-merge.ps1 | git-push-merge.bat | quick-push.ps1 |
|---------|-------------------|-------------------|----------------|
| **Safety Checks** | ✅ Full | ✅ Basic | ✅ Basic |
| **Syntax Testing** | ✅ Yes | ❌ No | ❌ No |
| **Branch Merging** | ✅ Yes | ✅ Yes | ❌ No |
| **Interactive Prompts** | ✅ Yes | ✅ Yes | ❌ No |
| **GitHub Integration** | ✅ Full | ✅ Basic | ✅ Basic |
| **Speed** | 🐢 Thorough | 🏃 Medium | ⚡ Fast |
| **Best For** | Important changes | Simple workflow | Daily commits |

## 🔧 **Configuration**

### **Prerequisites:**
- Git installed and configured
- Repository connected to GitHub
- PowerShell execution policy set (for .ps1 scripts)

### **First-time Setup:**
```powershell
# Allow PowerShell scripts to run
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify Git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 🚨 **Troubleshooting**

### **Common Issues:**

1. **"PowerShell Execution Policy Error"**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **"Not a Git Repository"**
   - Ensure you're running the script from the project root directory
   - Check if `.git` folder exists

3. **"Push Failed"**
   - Check internet connection
   - Verify GitHub authentication (personal access token)
   - Ensure you have push permissions to the repository

4. **"Merge Conflicts"**
   - Scripts will stop and show error message
   - Resolve conflicts manually using `git status` and `git mergetool`
   - Continue with `git commit` and `git push`

### **Emergency Recovery:**
```powershell
# If something goes wrong, you can always:
git status                    # Check current state
git log --oneline -5         # See recent commits
git reflog                   # See all recent actions (can recover almost anything)
```

## 💡 **Best Practices**

### **When to Use Each Script:**

- **`quick-push.ps1`**: Daily development, small fixes, documentation updates
- **`git-push-merge.ps1`**: Feature completion, important changes, release preparation  
- **`git-push-merge.bat`**: When PowerShell isn't available, simpler environments

### **Commit Message Tips:**
```powershell
# Good commit messages:
"Add user authentication with JWT tokens"
"Fix memory leak in image processing"
"Update documentation for new API endpoints"

# Avoid:
"Update"
"Fix stuff"  
"Changes"
```

### **Branch Naming:**
```
feature/user-authentication
bugfix/memory-leak-fix
hotfix/security-patch
release/v1.2.0
```

## 🎯 **Quick Reference**

```powershell
# Most common commands:

# Quick daily commit
.\scripts\quick-push.ps1

# Full workflow with testing
.\scripts\git-push-merge.ps1

# Merge feature to main
.\scripts\git-push-merge.ps1 -SourceBranch "feature/xyz" -TargetBranch "main"

# Force push without prompts (be careful!)
.\scripts\git-push-merge.ps1 -Force
```

---

**Happy coding! 🚀 Your changes are now just one command away from GitHub!**
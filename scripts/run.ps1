param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start")]
    [string]$Action
)

$ErrorActionPreference = "Stop"

if ($Action -eq "start") {
    Write-Host "[DEBUG] Starting Whisper WebSocket Server (minimal-fw-mem.py)..."
    $parentDir = Split-Path -Parent $PSScriptRoot
    $projectVenvPython = Join-Path $parentDir ".venv\Scripts\python.exe"
    Write-Host "[DEBUG] Checking for project venv Python at: $projectVenvPython"
    if (Test-Path $projectVenvPython) {
        $python = $projectVenvPython
        Write-Host "[DEBUG] Using project venv Python: $python"
    } else {
        $python = "python"
        Write-Host "[DEBUG] Project venv not found, using system Python."
    }
    $parentDir = Split-Path -Parent $PSScriptRoot
    $scriptPath = Join-Path $parentDir "minimal-fw-mem.py"
    Write-Host "[DEBUG] Script path: $scriptPath"
    $fullScriptPath = Resolve-Path $scriptPath
    Write-Host "[DEBUG] Full script path: $fullScriptPath"
    Write-Host "[DEBUG] Changing directory to: $parentDir"
    Push-Location $parentDir
    # Install requirements.txt before running the server
    $requirements = Join-Path $parentDir "requirements.txt"
    if (Test-Path $requirements) {
        Write-Host "[DEBUG] Installing requirements from: $requirements"
        & $python -m pip install --upgrade pip
        & $python -m pip install -r "$requirements"
    } else {
        Write-Host "[DEBUG] requirements.txt not found, skipping pip install."
    }
    Write-Host "[DEBUG] Running command: $python `"$fullScriptPath`""
    Start-Process -NoNewWindow -Wait $python -ArgumentList "`"$fullScriptPath`""
    Pop-Location
    Write-Host "[DEBUG] Server process exited."
} else {
    Write-Host "Unknown action: $Action"
    exit 1
}
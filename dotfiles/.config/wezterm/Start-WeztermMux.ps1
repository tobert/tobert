# Start-WeztermMux.ps1
# Ensures wezterm-mux-server is running in the background
# This script is designed to be run at Windows login via Task Scheduler

$ProcessName = "wezterm-mux-server"

# Check if already running
$Process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue

if ($null -eq $Process) {
    Write-Host "Starting $ProcessName..."

    # Start the mux server in background
    # --daemonize makes it run as a background process
    Start-Process -FilePath "wezterm-mux-server" `
                  -ArgumentList "--daemonize" `
                  -WindowStyle Hidden `
                  -WorkingDirectory $env:USERPROFILE

    # Give it a moment to initialize
    Start-Sleep -Milliseconds 500

    # Verify it started
    $NewProcess = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    if ($null -ne $NewProcess) {
        Write-Host "$ProcessName started successfully (PID: $($NewProcess.Id))"
    } else {
        Write-Warning "Failed to start $ProcessName"
    }
} else {
    Write-Host "$ProcessName is already running (PID: $($Process.Id))"
}

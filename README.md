# tobert - my stuff

My dotfiles &amp; tools to push them around. Supports Linux (Debian & Arch) and Windows WSL (Debian).

My code is Apache 2. Take what you like, pay it forward :)

# Directories

## bin

Everything in this directory gets pushed out to my `~/bin` which is in my `$PATH`.

## scripts

Scripts I run less frequently and don't want or need in my $PATH.

## dotfiles

This is intended to be synchronized as-is to $HOME and contains configs for various apps.

# WezTerm Persistent Sessions Setup (Windows)

The WezTerm configuration includes support for persistent multiplexer sessions on Windows. This allows tabs and panes to survive closing/reopening WezTerm.

## How It Works

- `wezterm-mux-server` runs in the background on Windows
- WezTerm GUI connects to it via Unix domain socket
- All WSL sessions run through `wsl.exe` managed by the mux
- Sessions persist even when WezTerm window is closed

## Setup (One-time)

Run this in PowerShell (as Administrator):

```powershell
# Navigate to the config directory
cd $env:USERPROFILE\.config\wezterm

# Create the scheduled task for auto-start
$TaskName = "WeztermMuxServer"
$ScriptPath = "$env:USERPROFILE\.config\wezterm\Start-WeztermMux.ps1"

# Remove existing task if it exists
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

# Create the action
$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""

# Create the trigger (at logon)
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

# Create the principal (run as current user)
$Principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType Interactive `
    -RunLevel Limited

# Create settings
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0)

# Register the task
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Principal $Principal `
    -Settings $Settings `
    -Description "Auto-start wezterm multiplexer server at login"

Write-Host "✓ Scheduled task created successfully!"
```

## Start the Mux Server

```powershell
# Start it immediately (or just log out/in)
Start-ScheduledTask -TaskName "WeztermMuxServer"

# Verify it's running
Get-Process wezterm-mux-server
```

## Troubleshooting

```powershell
# Check if mux server is running
Get-Process wezterm-mux-server

# Manually start the mux server
wezterm-mux-server --daemonize

# Stop the mux server
Stop-Process -Name wezterm-mux-server

# Check scheduled task status
Get-ScheduledTask -TaskName "WeztermMuxServer"

# Remove auto-start
Unregister-ScheduledTask -TaskName "WeztermMuxServer" -Confirm:$false
```


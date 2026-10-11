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

# WezTerm Key Bindings

The WezTerm config uses a tmux-style leader key (`Ctrl-a`) for most commands. Here are the most useful bindings:

## Leader Key
| Binding | Action |
|---------|--------|
| `Ctrl-a` | Leader key (press before other commands) |
| `Ctrl-a a` | Send literal `Ctrl-a` (for shell/vim) |
| `Ctrl-a Ctrl-a` | Switch to last active tab |

## Tabs
| Binding | Action |
|---------|--------|
| `Ctrl-a c` | Create new tab |
| `Ctrl-a n` | Next tab |
| `Ctrl-a p` | Previous tab |
| `Ctrl-a 1-9` | Jump to tab 1-9 |
| `Ctrl-a ,` | Rename current tab |
| `Ctrl-a q` | Close current pane |
| `Ctrl-a Q` | Close current tab |

## Panes
| Binding | Action |
|---------|--------|
| `Ctrl-a \|` | Split pane horizontally |
| `Ctrl-a -` | Split pane vertically |
| `Ctrl-a h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl-a arrows` | Navigate panes (arrow keys) |
| `Ctrl-a z` | Zoom/unzoom current pane |

## Copy & Paste
| Binding | Action |
|---------|--------|
| `Ctrl-Shift-C` | Copy selection |
| `Ctrl-Shift-V` | Paste from clipboard |
| `Ctrl-v` | Paste from clipboard (alternative) |
| Right click | Paste from clipboard |

## Copy Mode
| Binding | Action |
|---------|--------|
| `Ctrl-a [` | Enter copy mode |
| `h/j/k/l` | Navigate (vim-style) |
| `w/b` | Forward/backward word |
| `0/$` | Start/end of line |
| `g/G` | Top/bottom of scrollback |
| `v` | Start selection |
| `V` | Start line selection |
| `y` | Yank (copy) and exit |
| `/` or `?` | Search forward/backward |
| `q` or `Esc` | Exit copy mode |

## Other
| Binding | Action |
|---------|--------|
| `Ctrl-a space` | Launcher menu |
| `Ctrl-a f` | Search current pane |
| `Ctrl-a "` | Show tab navigator |
| `Ctrl-a r` | Reload configuration |
| `Ctrl-a d` | Detach domain |
| `Ctrl +/-/0` | Font size (increase/decrease/reset) |

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


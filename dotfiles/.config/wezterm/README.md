# WezTerm Configuration

**Theme:** Amy's Theme (bright, clean colors)
**Structure:** Modular with separate theme and host configs
**Compatible:** Windows, Linux, WSL

## Directory Structure

```
.config/wezterm/
├── wezterm.lua           # Main config file
├── themes/
│   └── amystheme.lua     # Amy's Theme color scheme
└── hosts/
    ├── local.lua         # Local environment (WSL, native shell, etc.)
    └── zorak.lua         # SSH to zorak server
```

## Features

- **Amy's Theme** - Bright, clean colors optimized for readability
- **Modular design** - Theme and hosts in separate files
- **Cross-platform** - Works on Windows and Linux
- **Tmux-style keybindings** - Ctrl-a prefix like tmux
- **SSH integration** - Easy SSH connections to configured hosts
- **Nerd Font icons** - Process-specific icons in tabs

## Installation

### Linux

```bash
# Link or copy to ~/.config/wezterm/
ln -s ~/src/tobert/dotfiles/.config/wezterm ~/.config/wezterm

# Or copy files
cp -r ~/src/tobert/dotfiles/.config/wezterm ~/.config/
```

### Windows

Copy entire directory to:
```
%USERPROFILE%\.config\wezterm\
```

Or via PowerShell:
```powershell
Copy-Item -Recurse -Path "\\wsl$\Ubuntu\home\atobey\src\tobert\dotfiles\.config\wezterm" -Destination "$env:USERPROFILE\.config\"
```

## Configuration

### Adding New SSH Hosts

Create `hosts/hostname.lua`:

```lua
return {
  ssh_domains = {
    {
      name = 'hostname',
      remote_address = 'hostname.example.com:22',
      username = 'your_username',
      ssh_option = {
        ForwardAgent = 'yes',
      },
      multiplexing = 'WezTerm',
    },
  },

  launch_menu = {
    {
      label = 'SSH to hostname',
      domain = { DomainName = 'hostname' },
    },
  },
}
```

Then add the hostname to the `private_hosts` list in `wezterm.lua`:

```lua
local private_hosts = { 'zorak', 'hostname' }
```

### Customizing Local Environment

Edit `hosts/local.lua` to set:
- Default domain (WSL, PowerShell, native Linux, etc.)
- Default program
- Launch menu items

### Changing Theme

Amy's Theme is in `themes/amystheme.lua`. To use a different theme:

1. Create a new theme file in `themes/`
2. Update `wezterm.lua`:
   ```lua
   config.colors = require('themes.your_theme')
   ```

## Key Bindings

**Leader key:** `Ctrl-a` (like tmux)

### Tabs
- `Ctrl-a c` - New tab
- `Ctrl-a n` - Next tab
- `Ctrl-a p` - Previous tab
- `Ctrl-a 1-9` - Jump to tab 1-9
- `Ctrl-a ,` - Rename tab
- `Ctrl-a "` - Tab navigator

### Panes
- `Ctrl-a |` - Split horizontal
- `Ctrl-a -` - Split vertical
- `Ctrl-a h/j/k/l` - Navigate panes (vi-style)
- `Ctrl-a arrows` - Navigate panes (arrow keys)
- `Ctrl-a z` - Zoom pane

### Other
- `Ctrl-a Space` - Launcher menu
- `Ctrl-a f` - Search
- `Ctrl-a r` - Reload config
- `Ctrl +/-/0` - Font size
- `Right-click` - Paste

## Theme Details

See `~/src/tobert/botdocs/amys-theme.md` for complete theme documentation including:
- Full color palette
- Implementation across all tools (Neovim, Bash, etc.)
- Color adjustment instructions
- Screenshots and examples

## Syncing Between Machines

The modular structure makes syncing easy:

1. **Theme file** (`themes/amystheme.lua`) - Identical across all machines
2. **Main config** (`wezterm.lua`) - Identical across all machines
3. **Host files** (`hosts/*.lua`) - Machine-specific or shared

To sync to Windows:
```bash
# From Linux/WSL
rsync -av ~/.config/wezterm/ /mnt/c/Users/YourUsername/.config/wezterm/
```

## Troubleshooting

**Colors don't look right:**
- Verify `themes/amystheme.lua` exists
- Check for Lua syntax errors: `wezterm --config-file wezterm.lua`

**SSH doesn't work:**
- Verify `hosts/hostname.lua` exists and returns a table
- Check `ssh_domains` and `launch_menu` are in the return table
- Confirm hostname is in the `private_hosts` list in `wezterm.lua`

**Nerd Font icons missing:**
- Install Cascadia Code Nerd Font: https://www.nerdfonts.com/
- Restart wezterm

## Version Control

This configuration is stored in the dotfiles repo at:
`~/src/tobert/dotfiles/.config/wezterm/`

**Note:** `hosts/` files may contain private information (IP addresses, usernames). Consider adding them to `.gitignore` if making this repo public.

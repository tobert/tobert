-- Local domains configuration (WSL and PowerShell)
-- Safe to commit - no private information

return {
  -- Unix domain for persistent multiplexer (Windows-side)
  -- Requires wezterm-mux-server running (see README.md for autostart setup)
  unix_domains = {
    {
      name = 'windows-mux',
      -- Uses default socket path: %USERPROFILE%\.local\share\wezterm\sock
      socket_path = nil,
      skip_permissions_check = false,
      -- Auto-connect when wezterm starts
      connect_automatically = true,
    },
  },

  -- Default to the persistent multiplexer when available
  -- Falls back to direct WSL if mux not running
  default_domain = 'windows-mux',

  -- Default program to run in new panes (WSL in home directory)
  default_prog = { 'wsl.exe', '~' },

  launch_menu = {
    {
      label = 'WSL Ubuntu (Persistent)',
      domain = { DomainName = 'windows-mux' },
      args = { 'wsl.exe', '~' },
    },
    {
      label = 'WSL Ubuntu (Direct)',
      domain = { DomainName = 'WSL:Ubuntu' },
    },
    {
      label = 'PowerShell (Persistent)',
      domain = { DomainName = 'windows-mux' },
      args = { 'pwsh.exe', '-NoLogo' },
    },
    {
      label = 'PowerShell (Direct)',
      args = { 'pwsh.exe', '-NoLogo' },
    },
    {
      label = 'Command Prompt',
      args = { 'cmd.exe' },
    },
  },
}

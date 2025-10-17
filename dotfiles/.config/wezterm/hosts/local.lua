-- Local domains configuration (WSL and PowerShell)
-- Safe to commit - no private information

return {
  -- Default domain and program
  default_domain = 'WSL:Ubuntu',
  default_prog = { 'wsl.exe', '~' },

  launch_menu = {
    {
      label = 'WSL Ubuntu',
      domain = { DomainName = 'WSL:Ubuntu' },
    },
    {
      label = 'PowerShell',
      args = { 'pwsh.exe', '-NoLogo' },
    },
    {
      label = 'Command Prompt',
      args = { 'cmd.exe' },
    },
  },
}

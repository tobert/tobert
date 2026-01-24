-- Local domains configuration
-- Detects WSL vs native Linux and configures accordingly

local is_wsl = os.getenv("WSL_DISTRO_NAME") ~= nil

if is_wsl then
	-- WSL: Use Windows-side mux server
	return {
		unix_domains = {
			{
				name = "windows-mux",
				-- Uses default socket path: %USERPROFILE%\.local\share\wezterm\sock
				connect_automatically = true,
			},
		},
		default_domain = "windows-mux",
		default_prog = { "wsl.exe", "~" },
		launch_menu = {
			{
				label = "WSL Ubuntu (Persistent)",
				domain = { DomainName = "windows-mux" },
				args = { "wsl.exe", "~" },
			},
			{
				label = "WSL Ubuntu (Direct)",
				domain = { DomainName = "WSL:Ubuntu" },
			},
			{
				label = "PowerShell",
				domain = { DomainName = "windows-mux" },
				args = { "pwsh.exe", "-NoLogo" },
			},
		},
	}
else
	-- Native Linux: Year of the Linux desktop 🐧
	return {
		unix_domains = {
			{
				name = "unix",
				-- Uses default socket path: ~/.local/share/wezterm/sock
				connect_automatically = true,
			},
		},
		default_domain = "unix",
		launch_menu = {
			{
				label = "Shell (Persistent)",
				domain = { DomainName = "unix" },
			},
			{
				label = "Shell (Direct)",
			},
		},
	}
end

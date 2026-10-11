# labwc Cheat Sheet

Openbox-style stacking Wayland compositor. Mouse-friendly, simple.

## Keybinds (Amy's Config)

| Key | Action |
|-----|--------|
| `Alt+Enter` | Terminal (foot) |
| `Alt+d` | App launcher (wofi) |
| `Alt+q` | Close window |
| `Alt+f` | Toggle fullscreen |
| `Alt+m` | Toggle maximize |
| `Alt+\`` | Next window (grave/backtick - works over Moonlight) |
| `Alt+Shift+\`` | Previous window |
| `Alt+Escape` | Show root menu |
| `Right-click` | Desktop menu |
| `Print` | Screenshot to clipboard |
| `Alt+l` | Lock screen |

## CLI Commands (from foot)

### Launch Apps
```bash
foot &                    # terminal
wezterm &                 # wezterm
firefox &                 # browser
wofi --show drun &        # app launcher
thunar &                  # file manager
```

### Display / Output Control
```bash
wlr-randr                                      # list outputs
wlr-randr --output HDMI-A-1 --mode 1920x1080   # set resolution
wlr-randr --output HDMI-A-1 --mode 2256x1504   # high-res mode
```

### Screenshots
```bash
grim                      # full screen → file
grim -g "$(slurp)"        # select region → file
grim - | wl-copy          # full screen → clipboard
grim -g "$(slurp)" - | wl-copy  # region → clipboard
```

### Clipboard
```bash
wl-copy < file            # copy file contents
wl-paste                  # paste to stdout
wl-paste > file           # paste to file
```

### labwc Control
```bash
labwc --reconfigure       # reload config (or Alt+Escape → Reconfigure)
labwc --exit              # exit (or Alt+Escape → Exit)
```

### Sunshine (Moonlight streaming)
```bash
WAYLAND_DISPLAY=wayland-0 sunshine &   # start streaming
killall sunshine                        # stop streaming
```

## Config Files

All in `~/.config/labwc/` (symlinked from dotfiles):

| File | Purpose |
|------|---------|
| `rc.xml` | Main config (keybinds, theme, behavior) |
| `menu.xml` | Right-click menus |
| `autostart` | Startup apps (waybar, mako, etc.) |
| `environment` | Environment variables |

## Gamescope Wrapper (for Moonlight)

Start labwc inside gamescope for Sunshine capture:
```bash
gamescope -W 1920 -H 1080 -f -- labwc &
sleep 2
WAYLAND_DISPLAY=wayland-0 sunshine &
```

## Theme Colors (Amy's Theme)

Based on Tokyo Night:
- Background: `#1a1b26`
- Foreground: `#e5e5e5`
- Accent: `#7aa2f7`
- Border: `#33467c`

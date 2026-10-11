#!/bin/bash
# Install Sway + essentials on Arch Linux
# Run as root: sudo ./install-sway.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}▶${NC} $*"; }
ok()    { echo -e "${GREEN}✓${NC} $*"; }
err()   { echo -e "${RED}✗${NC} $*" >&2; }

if [[ $EUID -ne 0 ]]; then
    err "Run as root: sudo $0"
    exit 1
fi

info "Installing Sway desktop environment..."

pacman -S --needed --noconfirm \
    sway \
    swaylock \
    swayidle \
    swaybg \
    waybar \
    wofi \
    foot \
    mako \
    grim \
    slurp \
    wl-clipboard \
    xdg-desktop-portal-wlr \
    xdg-user-dirs \
    brightnessctl \
    playerctl \
    polkit-gnome

ok "Sway packages installed"

# Update greetd config
info "Configuring greetd for Sway..."
cat > /etc/greetd/config.toml << 'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --remember --time --asterisks --sessions /usr/share/wayland-sessions"
user = "greeter"
EOF
ok "greetd configured"

# Make sure sway session file exists
if [[ ! -f /usr/share/wayland-sessions/sway.desktop ]]; then
    info "Creating sway.desktop session file..."
    cat > /usr/share/wayland-sessions/sway.desktop << 'EOF'
[Desktop Entry]
Name=Sway
Comment=An i3-compatible Wayland compositor
Exec=sway
Type=Application
EOF
    ok "sway.desktop created"
fi

# Enable greetd
systemctl disable cosmic-greeter sddm 2>/dev/null || true
systemctl enable greetd
ok "greetd enabled"

echo ""
ok "Sway is ready! 🌿"
info "Run: sudo systemctl start greetd"
info "Or reboot and select Sway from the session menu"
echo ""

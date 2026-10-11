#!/bin/bash
# Install System76 COSMIC Desktop on Arch Linux
# Run as root: sudo ./install-cosmic.sh

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

info "Installing COSMIC desktop environment..."

# Core desktop + apps
pacman -S --needed --noconfirm \
    cosmic \
    cosmic-session \
    cosmic-greeter \
    cosmic-files \
    cosmic-store \
extra/cosmic-applets \
extra/cosmic-bg \
extra/cosmic-terminal \
extra/cosmic-text-editor \
extra/cosmic-wallpapers \
extra/cosmic-workspaces \
    xdg-desktop-portal-cosmic \
    xdg-user-dirs

ok "COSMIC packages installed"

# Disable old display manager if present
for dm in sddm gdm lightdm lxdm; do
    if systemctl is-enabled "$dm.service" &>/dev/null; then
        info "Disabling $dm..."
        systemctl disable "$dm.service"
        ok "Disabled $dm"
    fi
done

# Enable COSMIC greeter
info "Enabling cosmic-greeter..."
systemctl enable cosmic-greeter.service
ok "cosmic-greeter enabled"

# Generate XDG user dirs if not present
if [[ -n "${SUDO_USER:-}" ]]; then
    info "Setting up XDG directories for $SUDO_USER..."
    sudo -u "$SUDO_USER" xdg-user-dirs-update
    ok "XDG directories configured"
fi

echo ""
ok "COSMIC is ready! 🚀"
info "Reboot to start using COSMIC desktop"
echo ""
echo "    sudo reboot"
echo ""

#!/bin/bash
# Setup Sunshine streaming with labwc via greetd
#
# Installs and configures:
#   greetd + cage + regreet  — graphical Wayland login screen
#   greetd socket perms      — allows remote-login.py via sudo
#   sunshine user service    — starts after login, restarts on failure
#
# Workflow:
#   1. greetd starts cage → regreet on VT1
#   2. Login at the screen, OR ssh in and run:
#        sudo ~/src/tobert/bin/remote-login.py
#   3. labwc starts → sunshine user service starts → connect via Moonlight
#
# Run as root: sudo ./setup-sunshine-with-labwc.sh

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo $0" >&2
    exit 1
fi

SUNSHINE_USER="${SUDO_USER:-atobey}"
SUNSHINE_USER_HOME=$(getent passwd "$SUNSHINE_USER" | cut -d: -f6)
if [[ -z "$SUNSHINE_USER_HOME" ]]; then
    echo "Error: could not resolve home directory for $SUNSHINE_USER" >&2
    exit 1
fi

echo "=== Setting up Sunshine + labwc ==="

# --- Packages ---
echo "Installing packages..."
pacman -S --needed --noconfirm \
    greetd \
    greetd-regreet \
    cage \
    labwc

# sunshine is an AUR package — verify it's installed
if ! pacman -Q sunshine &>/dev/null; then
    echo "Error: sunshine is not installed. Install from AUR first:" >&2
    echo "  yay -S sunshine" >&2
    exit 1
fi

# --- greetd config ---
echo "Configuring greetd..."
cat > /etc/greetd/config.toml << 'EOF'
[terminal]
vt = 1

[default_session]
command = "cage -s -- regreet"
user = "greeter"
EOF

# --- greetd socket permissions for remote-login.py ---
echo "Configuring greetd socket permissions..."
mkdir -p /etc/systemd/system/greetd.service.d
cat > /etc/systemd/system/greetd.service.d/socket-perms.conf << 'EOF'
[Service]
ExecStartPost=/bin/sh -c 'sleep 1 && chmod 770 /run/greetd*.sock && chgrp wheel /run/greetd*.sock'
EOF

# --- regreet config ---
echo "Configuring regreet..."
cat > /etc/greetd/regreet.toml << 'EOF'
[commands]
reboot = [ "systemctl", "reboot" ]
poweroff = [ "systemctl", "poweroff" ]
EOF

# --- Sunshine config ---
echo "Installing sunshine.conf for $SUNSHINE_USER..."
SUNSHINE_CONF_DIR="$SUNSHINE_USER_HOME/.config/sunshine"
install -d -o "$SUNSHINE_USER" -g "$SUNSHINE_USER" -m 755 "$SUNSHINE_CONF_DIR"
install -o "$SUNSHINE_USER" -g "$SUNSHINE_USER" -m 644 /dev/stdin "$SUNSHINE_CONF_DIR/sunshine.conf" << 'EOF'
encoder = vaapi
adapter_name = /dev/dri/renderD128
capture = wlr
resolutions = [1920x1200, 2256x1504, 1680x1050]
EOF

# --- Sunshine user service ---
echo "Installing sunshine user service for $SUNSHINE_USER..."
UNIT_DIR="$SUNSHINE_USER_HOME/.config/systemd/user"
install -d -o "$SUNSHINE_USER" -g "$SUNSHINE_USER" -m 755 "$UNIT_DIR"
install -o "$SUNSHINE_USER" -g "$SUNSHINE_USER" -m 644 /dev/stdin "$UNIT_DIR/sunshine.service" << 'EOF'
[Unit]
Description=Sunshine self-hosted game stream host for Moonlight
StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
Type=simple
ExecStart=/usr/bin/sunshine
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=default.target
EOF

# --- Enable services ---
echo "Enabling greetd..."
systemctl daemon-reload
systemctl enable greetd.service

# Disable conflicting display managers
for dm in sddm gdm lightdm; do
    if systemctl is-enabled "$dm.service" &>/dev/null; then
        echo "Disabling $dm..."
        systemctl disable "$dm.service"
    fi
done

# Enable sunshine for the user
# systemctl --user requires the user's dbus session, which isn't available
# from a root sudo context. Use machinectl to enter the user's service manager.
echo "Enabling sunshine user service..."
if machinectl shell "$SUNSHINE_USER@" /usr/bin/systemctl --user daemon-reload 2>/dev/null \
   && machinectl shell "$SUNSHINE_USER@" /usr/bin/systemctl --user enable sunshine.service 2>/dev/null; then
    echo "  Sunshine service enabled."
else
    echo "  Note: Could not enable via machinectl ($SUNSHINE_USER may not be logged in)."
    echo "  Run manually after login:"
    echo "    systemctl --user daemon-reload && systemctl --user enable sunshine.service"
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Start greetd now (no reboot needed):"
echo "  sudo systemctl start greetd"
echo "  Then switch to VT1 (Ctrl+Alt+F1) to log in"
echo ""
echo "After login:"
echo "  - labwc starts from the regreet session picker"
echo "  - Sunshine starts automatically, connect via Moonlight"
echo ""
echo "For headless/remote login via SSH:"
echo "  sudo ~/src/tobert/bin/remote-login.py"

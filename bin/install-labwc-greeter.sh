#!/bin/bash
# Install labwc + regreet + sunshine greeter setup
# Run as root: sudo ./install-labwc-greeter.sh

set -euo pipefail

echo "=== Installing labwc greeter with Moonlight support ==="

# Install packages
echo "Installing packages..."
pacman -S --needed --noconfirm \
    greetd \
    greetd-regreet \
    cage \
    labwc \
    swaylock \
    swayidle \
    wlopm \
    sunshine

# Get greeter user info
GREETER_UID=$(id -u greeter)
echo "Greeter UID: $GREETER_UID"

# Add greeter to video group for GPU access
echo "Adding greeter to video group..."
usermod -aG video greeter

# Create persistent runtime dir via tmpfiles.d
echo "Setting up runtime dir..."
cat > /etc/tmpfiles.d/greeter-runtime.conf << EOF
d /run/user/$GREETER_UID 0700 greeter greeter -
EOF
systemd-tmpfiles --create /etc/tmpfiles.d/greeter-runtime.conf

# Create sunshine config for greeter
echo "Creating greeter sunshine config..."
mkdir -p /home/greeter/.config/sunshine
cat > /home/greeter/.config/sunshine/sunshine.conf << 'EOF'
capture = wlr
encoder = vaapi
adapter_name = /dev/dri/renderD128
min_log_level = info
EOF
chown -R greeter:greeter /home/greeter

# Create systemd service for greeter sunshine
echo "Installing sunshine-greeter.service..."
cat > /etc/systemd/system/sunshine-greeter.service << EOF
[Unit]
Description=Sunshine for greeter (Moonlight streaming)
After=greetd.service
BindsTo=greetd.service

[Service]
Type=simple
User=greeter
Environment=WAYLAND_DISPLAY=wayland-0
Environment=XDG_RUNTIME_DIR=/run/user/$GREETER_UID
ExecStartPre=/bin/sleep 2
ExecStart=/usr/bin/sunshine
Restart=on-failure
RestartSec=3

[Install]
WantedBy=greetd.service
EOF

# Configure greetd with cage + regreet
echo "Configuring greetd..."
cat > /etc/greetd/config.toml << 'EOF'
[terminal]
vt = 1

[default_session]
command = "cage -s -- regreet"
user = "greeter"
EOF

# Enable services
echo "Enabling services..."
systemctl daemon-reload
systemctl enable greetd.service
systemctl enable sunshine-greeter.service

# Disable other display managers
for dm in sddm gdm lightdm; do
    if systemctl is-enabled "$dm.service" &>/dev/null; then
        echo "Disabling $dm..."
        systemctl disable "$dm.service"
    fi
done

echo ""
echo "=== Setup complete! ==="
echo ""
echo "On reboot:"
echo "  1. greetd starts cage (minimal Wayland compositor)"
echo "  2. cage runs regreet (graphical login)"
echo "  3. sunshine-greeter captures it for Moonlight"
echo "  4. After login, labwc starts with your sunshine"
echo ""
echo "Make sure your labwc autostart has sunshine:"
echo "  ( sleep 3 ; sunshine >/dev/null 2>&1 ) &"
echo ""
echo "Reboot when ready: systemctl reboot"

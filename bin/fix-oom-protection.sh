#!/bin/bash
# Fix OOM protection for user services (specifically wezterm)
# Run as root or with sudo

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root (try: sudo $0)"
    exit 1
fi

DROPIN_DIR="/etc/systemd/system/user@1000.service.d"
DROPIN_FILE="$DROPIN_DIR/oom-protect.conf"

echo "📁 Creating drop-in directory..."
mkdir -p "$DROPIN_DIR"

echo "📝 Writing OOM protection drop-in..."
cat > "$DROPIN_FILE" << 'EOF'
# Grant capability to set negative OOMScoreAdjust for user services
# This allows wezterm.service to use OOMScoreAdjust=-1000

[Service]
AmbientCapabilities=CAP_SYS_RESOURCE
EOF

echo "🔄 Reloading systemd daemon..."
systemctl daemon-reload

echo ""
echo "✅ Drop-in installed: $DROPIN_FILE"
echo ""
echo "⚠️  To activate, you need to restart the user slice:"
echo "    sudo systemctl restart user@1000.service"
echo ""
echo "   This will DISCONNECT your current session!"
echo "   Run it when you're ready to reconnect."

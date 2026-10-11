#!/bin/bash
# Fix greetd socket permissions for remote login
# Run as root: sudo ./fix-greetd-perms.sh

set -euo pipefail

mkdir -p /etc/systemd/system/greetd.service.d

cat > /etc/systemd/system/greetd.service.d/socket-perms.conf << 'EOF'
[Service]
ExecStartPost=/bin/sh -c 'sleep 1 && chmod 770 /run/greetd*.sock && chgrp wheel /run/greetd*.sock'
EOF

systemctl daemon-reload

echo "Done. Socket will be accessible to wheel group after next greetd restart."

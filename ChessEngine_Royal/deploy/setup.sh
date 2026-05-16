#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  Chess Engine — AWS EC2 Deployment Script
#  Tested on: Ubuntu 22.04 LTS / Amazon Linux 2023
#  Run as root or with sudo
# ═══════════════════════════════════════════════════════════════

set -e

echo "============================================"
echo "  Chess Engine — AWS Setup"
echo "============================================"

# ── 1. Update system ─────────────────────────────────────────
echo "[1/5] Updating system packages..."
apt-get update -y && apt-get upgrade -y 2>/dev/null || yum update -y

# ── 2. Install nginx ──────────────────────────────────────────
echo "[2/5] Installing nginx..."
if command -v apt-get &>/dev/null; then
    apt-get install -y nginx
else
    yum install -y nginx
fi

# ── 3. Copy files ─────────────────────────────────────────────
echo "[3/5] Deploying chess app files..."
mkdir -p /var/www/chess
cp chess.html /var/www/chess/chess.html
cp nginx/chess.conf /etc/nginx/sites-available/chess.conf 2>/dev/null || \
cp nginx/chess.conf /etc/nginx/conf.d/chess.conf

# Enable site (Debian/Ubuntu)
if [ -d /etc/nginx/sites-enabled ]; then
    ln -sf /etc/nginx/sites-available/chess.conf /etc/nginx/sites-enabled/chess.conf
    rm -f /etc/nginx/sites-enabled/default
fi

# ── 4. Set permissions ────────────────────────────────────────
echo "[4/5] Setting file permissions..."
chown -R www-data:www-data /var/www/chess 2>/dev/null || \
chown -R nginx:nginx /var/www/chess
chmod -R 755 /var/www/chess

# ── 5. Start nginx ────────────────────────────────────────────
echo "[5/5] Starting nginx..."
nginx -t
systemctl enable nginx
systemctl restart nginx

echo ""
echo "============================================"
echo "  ✓ Chess Engine deployed!"
echo "  Open: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo 'YOUR_EC2_IP')"
echo "============================================"

#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Hugo Deploy Script
# Site: liamdecareaux.com
# ==============================

VPS_USER="liam"
VPS_HOST="45.76.68.204"
SITE_DIR="/var/www/liamdecareaux"
LOCAL_BUILD_DIR="public"
REMOTE="${VPS_USER}@${VPS_HOST}"

echo "Building Hugo site..."
hugo --minify

# FIX 1: Guard against empty build wiping your server
if [ -z "$(ls -A "${LOCAL_BUILD_DIR}" 2>/dev/null)" ]; then
  echo "ERROR: Hugo build output is empty. Aborting deploy." >&2
  exit 1
fi

# FIX 2: Removed redundant pre-rsync permission block (files get overwritten anyway)
echo "Ensuring web root exists on VPS..."
ssh "${REMOTE}" "sudo mkdir -p '${SITE_DIR}'"   # FIX 3: ssh -tt → ssh

echo "Deploying site files..."
rsync -avz --delete \
  "${LOCAL_BUILD_DIR}/" \
  "${REMOTE}:${SITE_DIR}/"

echo "Fixing permissions..."
ssh "${REMOTE}" "                               # FIX 3: ssh -tt → ssh
  sudo chown -R ${VPS_USER}:www-data '${SITE_DIR}' &&
  sudo find '${SITE_DIR}' -type d -exec chmod 755 {} \; &&
  sudo find '${SITE_DIR}' -type f -exec chmod 644 {} \;
"

echo "Testing Nginx config..."
ssh "${REMOTE}" "sudo nginx -t"                 # FIX 3: ssh -tt → ssh

echo "Reloading Nginx..."
ssh "${REMOTE}" "sudo systemctl reload nginx"   # FIX 3: ssh -tt → ssh

echo "Deployment complete. Site live at ${SITE_DIR}"
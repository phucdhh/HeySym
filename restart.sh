#!/bin/bash

# HeySym - Restart Script
# Restart all services (JupyterHub + Cloudflare Tunnel)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 Restarting HeySym (JupyterHub + Tunnel)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Stop
"$SCRIPT_DIR/stop.sh"

echo ""
echo "⏳ Waiting 2 seconds before restart..."
sleep 2
echo ""

# Start
"$SCRIPT_DIR/start.sh"

echo ""
echo "✅ Restart completed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

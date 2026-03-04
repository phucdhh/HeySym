#!/bin/bash

# HeySym - Start Script
# Khởi động JupyterHub và Cloudflare Tunnel

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PATH="$SCRIPT_DIR/venv"
CONFIG_FILE="$SCRIPT_DIR/config/jupyterhub_config.py"
PID_FILE="$SCRIPT_DIR/jupyterhub.pid"
TUNNEL_PID_FILE="$SCRIPT_DIR/cloudflare-tunnel.pid"
LOG_DIR="$SCRIPT_DIR/logs"
CF_DIR="$SCRIPT_DIR/cloudflare"
CF_CONFIG="$CF_DIR/heysym-tunnel.yaml"
CRED_FILE="$CF_DIR/heysym-credentials.json"

echo "🚀 Starting HeySym (JupyterHub + Cloudflare Tunnel)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Kiểm tra venv
if [ ! -d "$VENV_PATH" ]; then
    echo "❌ Virtual environment not found at $VENV_PATH"
    exit 1
fi

# Kiểm tra config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found at $CONFIG_FILE"
    exit 1
fi

# Kiểm tra xem đã chạy chưa
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  JupyterHub is already running (PID: $PID)"
        echo "   Use './stop.sh' to stop it first"
        exit 1
    else
        echo "⚠️  Stale JupyterHub PID file found, removing..."
        rm "$PID_FILE"
    fi
fi

# Kiểm tra tunnel
if [ -f "$TUNNEL_PID_FILE" ]; then
    TUNNEL_PID=$(cat "$TUNNEL_PID_FILE")
    if ps -p "$TUNNEL_PID" > /dev/null 2>&1; then
        echo "⚠️  Cloudflare Tunnel is already running (PID: $TUNNEL_PID)"
        echo "   Use './stop.sh' to stop it first"
        exit 1
    else
        echo "⚠️  Stale tunnel PID file found, removing..."
        rm "$TUNNEL_PID_FILE"
    fi
fi

# Tạo log directory
mkdir -p "$LOG_DIR"

# Activate venv và start JupyterHub
echo "📦 Activating virtual environment..."
source "$VENV_PATH/bin/activate"

echo "🔧 Starting JupyterHub..."
cd "$SCRIPT_DIR"

# Start JupyterHub in background
nohup jupyterhub -f "$CONFIG_FILE" > "$LOG_DIR/jupyterhub.log" 2>&1 &
JUPYTERHUB_PID=$!

# Lưu PID
echo "$JUPYTERHUB_PID" > "$PID_FILE"

# Đợi một chút để JupyterHub khởi động
sleep 3

# Kiểm tra xem process còn chạy không
if ps -p "$JUPYTERHUB_PID" > /dev/null 2>&1; then
    echo "✅ JupyterHub started successfully! (PID: $JUPYTERHUB_PID)"
else
    echo "❌ Failed to start JupyterHub"
    echo "   Check logs: cat $LOG_DIR/jupyterhub.log"
    rm "$PID_FILE"
    exit 1
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Start Cloudflare Tunnel
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo "🌐 Starting Cloudflare Tunnel..."

# Kiểm tra config file
if [ ! -f "$CF_CONFIG" ]; then
    echo "⚠️  Tunnel config not found: $CF_CONFIG"
    echo "   JupyterHub is running but tunnel is not started"
    echo "   Run ./setup-cloudflare-tunnel.sh to configure tunnel"
    exit 0
fi

# Kiểm tra credentials
if [ ! -f "$CRED_FILE" ]; then
    echo "⚠️  Credentials file not found: $CRED_FILE"
    echo "   JupyterHub is running but tunnel is not started"
    echo "   Run ./setup-cloudflare-tunnel.sh to configure tunnel"
    exit 0
fi

# Start tunnel in background
nohup cloudflared tunnel --config "$CF_CONFIG" run > "$LOG_DIR/cloudflare-tunnel.log" 2>&1 &
TUNNEL_PID=$!

# Lưu PID
echo "$TUNNEL_PID" > "$TUNNEL_PID_FILE"

# Đợi một chút để tunnel khởi động
sleep 3

# Kiểm tra xem tunnel process còn chạy không
if ps -p "$TUNNEL_PID" > /dev/null 2>&1; then
    echo "✅ Cloudflare Tunnel started successfully! (PID: $TUNNEL_PID)"
else
    echo "⚠️  Failed to start Cloudflare Tunnel"
    echo "   JupyterHub is still running"
    echo "   Check logs: cat $LOG_DIR/cloudflare-tunnel.log"
    rm "$TUNNEL_PID_FILE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ HeySym started successfully!"
echo ""
echo "📊 Service Information:"
echo "   • JupyterHub PID: $JUPYTERHUB_PID"
echo "   • Tunnel PID: $TUNNEL_PID"
echo "   • Local URL: http://192.168.1.100:3333"
echo "   • Public URL: https://heysym.truyenthong.edu.vn"
echo ""
echo "📁 Log Files:"
echo "   • JupyterHub: $LOG_DIR/jupyterhub.log"
echo "   • Tunnel: $LOG_DIR/cloudflare-tunnel.log"
echo ""
echo "💡 Next steps:"
echo "   • Check status: ./status.sh"
echo "   • View JupyterHub logs: tail -f $LOG_DIR/jupyterhub.log"
echo "   • View Tunnel logs: tail -f $LOG_DIR/cloudflare-tunnel.log"
echo "   • Stop all services: ./stop.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

#!/bin/bash

# HeySym - Stop Script
# Dừng Cloudflare Tunnel và JupyterHub

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/jupyterhub.pid"
TUNNEL_PID_FILE="$SCRIPT_DIR/cloudflare-tunnel.pid"

echo "🛑 Stopping HeySym (Tunnel + JupyterHub)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stop Cloudflare Tunnel First
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TUNNEL_STOPPED=false

if [ ! -f "$TUNNEL_PID_FILE" ]; then
    echo "⚠️  Cloudflare Tunnel PID file not found"
    
    # Tìm process bằng cách khác
    TUNNEL_PIDS=$(pgrep -f "cloudflared.*heysym-tunnel.yaml" || true)
    if [ -n "$TUNNEL_PIDS" ]; then
        echo "⚠️  Found running cloudflared processes: $TUNNEL_PIDS"
        echo "   Attempting to stop them..."
        echo "$TUNNEL_PIDS" | xargs kill -TERM
        sleep 2
        echo "✅ Cloudflared processes stopped"
        TUNNEL_STOPPED=true
    else
        echo "   No tunnel process found"
    fi
else
    TUNNEL_PID=$(cat "$TUNNEL_PID_FILE")
    
    # Kiểm tra process có đang chạy không
    if ! ps -p "$TUNNEL_PID" > /dev/null 2>&1; then
        echo "⚠️  Tunnel process $TUNNEL_PID is not running"
        rm "$TUNNEL_PID_FILE"
    else
        echo "📦 Stopping Cloudflare Tunnel (PID: $TUNNEL_PID)..."
        
        # Graceful shutdown
        kill -TERM "$TUNNEL_PID" 2>/dev/null || true
        
        # Đợi process dừng (max 10 seconds)
        TIMEOUT=10
        COUNT=0
        while ps -p "$TUNNEL_PID" > /dev/null 2>&1; do
            if [ $COUNT -ge $TIMEOUT ]; then
                echo "⚠️  Tunnel did not stop gracefully, forcing..."
                kill -KILL "$TUNNEL_PID" 2>/dev/null || true
                break
            fi
            sleep 1
            COUNT=$((COUNT + 1))
            echo -n "."
        done
        echo ""
        
        # Xóa PID file
        rm "$TUNNEL_PID_FILE"
        echo "✅ Cloudflare Tunnel stopped"
        TUNNEL_STOPPED=true
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stop JupyterHub
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
JUPYTERHUB_STOPPED=false

# Kiểm tra PID file
if [ ! -f "$PID_FILE" ]; then
    echo "⚠️  JupyterHub PID file not found"
    
    # Tìm process bằng cách khác
    PIDS=$(pgrep -f "jupyterhub.*jupyterhub_config.py" || true)
    if [ -n "$PIDS" ]; then
        echo "⚠️  Found running JupyterHub processes: $PIDS"
        echo "   Attempting to stop them..."
        echo "$PIDS" | xargs kill -TERM
        sleep 2
        echo "✅ JupyterHub processes stopped"
        JUPYTERHUB_STOPPED=true
    else
        echo "   No JupyterHub process found"
    fi
else
    PID=$(cat "$PID_FILE")

    # Kiểm tra process có đang chạy không
    if ! ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  JupyterHub process $PID is not running"
        rm "$PID_FILE"
    else
        echo "📦 Stopping JupyterHub (PID: $PID)..."

        # Graceful shutdown
        kill -TERM "$PID" 2>/dev/null || true

        # Đợi process dừng (max 10 seconds)
        TIMEOUT=10
        COUNT=0
        while ps -p "$PID" > /dev/null 2>&1; do
            if [ $COUNT -ge $TIMEOUT ]; then
                echo "⚠️  JupyterHub did not stop gracefully, forcing..."
                kill -KILL "$PID" 2>/dev/null || true
                break
            fi
            sleep 1
            COUNT=$((COUNT + 1))
            echo -n "."
        done
        echo ""

        # Xóa PID file
        rm "$PID_FILE"

        # Cleanup các single-user servers
        echo "🧹 Cleaning up user notebook servers..."
        pkill -f "jupyterhub-singleuser" 2>/dev/null || true

        echo "✅ JupyterHub stopped"
        JUPYTERHUB_STOPPED=true
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$TUNNEL_STOPPED" = true ] && [ "$JUPYTERHUB_STOPPED" = true ]; then
    echo "✅ HeySym stopped successfully!"
elif [ "$TUNNEL_STOPPED" = true ] || [ "$JUPYTERHUB_STOPPED" = true ]; then
    echo "✅ Partially stopped (some services were not running)"
else
    echo "⚠️  No services were running"
fi
echo ""
echo "💡 To start again: ./start.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

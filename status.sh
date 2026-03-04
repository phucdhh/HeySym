#!/bin/bash

# HeySym - Status Script
# Kiểm tra trạng thái của HeySym và Ollama

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/jupyterhub.pid"

echo "📊 HeySym Status Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check JupyterHub
echo ""
echo "🔷 JupyterHub Service:"
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        # Get memory and CPU usage
        MEM=$(ps -o rss= -p "$PID" | awk '{printf "%.1f MB", $1/1024}')
        CPU=$(ps -o %cpu= -p "$PID" | awk '{print $1"%"}')
        UPTIME=$(ps -o etime= -p "$PID" | xargs)
        
        echo "   ✅ Status: Running"
        echo "   • PID: $PID"
        echo "   • Uptime: $UPTIME"
        echo "   • Memory: $MEM"
        echo "   • CPU: $CPU"
        echo "   • URL: http://192.168.1.100:3333"
        
        # Check if port is listening
        if lsof -Pi :3333 -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "   • Port 3333: ✅ Listening"
        else
            echo "   • Port 3333: ⚠️  Not listening"
        fi
        
        # Count user sessions
        USER_COUNT=$(pgrep -f "jupyterhub-singleuser" | wc -l | xargs)
        echo "   • Active users: $USER_COUNT"
        
        JUPYTERHUB_STATUS="running"
    else
        echo "   ⚠️  Status: Stopped (stale PID file)"
        echo "   • PID file exists but process not running"
        JUPYTERHUB_STATUS="stopped"
    fi
else
    # Check if running without PID file
    PIDS=$(pgrep -f "jupyterhub.*jupyterhub_config.py" || true)
    if [ -n "$PIDS" ]; then
        echo "   ⚠️  Status: Running (no PID file)"
        echo "   • Found processes: $PIDS"
        JUPYTERHUB_STATUS="running_no_pid"
    else
        echo "   ❌ Status: Stopped"
        JUPYTERHUB_STATUS="stopped"
    fi
fi

# Check Cloudflare Tunnel
echo ""
echo "🔷 Cloudflare Tunnel:"
TUNNEL_PID_FILE="$SCRIPT_DIR/cloudflare-tunnel.pid"
if [ -f "$TUNNEL_PID_FILE" ]; then
    TUNNEL_PID=$(cat "$TUNNEL_PID_FILE")
    if ps -p "$TUNNEL_PID" > /dev/null 2>&1; then
        TUNNEL_MEM=$(ps -o rss= -p "$TUNNEL_PID" | awk '{printf "%.1f MB", $1/1024}')
        TUNNEL_UPTIME=$(ps -o etime= -p "$TUNNEL_PID" | xargs)
        
        echo "   ✅ Status: Running"
        echo "   • PID: $TUNNEL_PID"
        echo "   • Uptime: $TUNNEL_UPTIME"
        echo "   • Memory: $TUNNEL_MEM"
        echo "   • Domain: heysym.truyenthong.edu.vn"
        echo "   • Backend: http://localhost:3333"
        
        TUNNEL_STATUS="running"
    else
        echo "   ⚠️  Status: Stopped (stale PID file)"
        TUNNEL_STATUS="stopped"
    fi
else
    PIDS=$(pgrep -f "cloudflared.*heysym-tunnel.yaml" || true)
    if [ -n "$PIDS" ]; then
        echo "   ⚠️  Status: Running (no PID file)"
        echo "   • Found processes: $PIDS"
        TUNNEL_STATUS="running_no_pid"
    else
        echo "   ❌ Status: Stopped"
        TUNNEL_STATUS="stopped"
    fi
fi

# Check Ollama
echo ""
echo "🔷 Ollama Service:"
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "   ✅ Status: Running"
    echo "   • URL: http://localhost:11434"
    
    # Get Ollama version
    VERSION=$(curl -s http://localhost:11434/api/version 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
    echo "   • Version: $VERSION"
    
    # List models
    echo "   • Available models:"
    MODELS=$(curl -s http://localhost:11434/api/tags 2>/dev/null | python3 -c "import sys, json; data = json.load(sys.stdin); print('\n'.join(['     - ' + m['name'] for m in data.get('models', [])]))" 2>/dev/null || echo "     (unable to fetch)")
    echo "$MODELS"
    
    OLLAMA_STATUS="running"
else
    echo "   ❌ Status: Not running or not accessible"
    echo "   • Expected URL: http://localhost:11434"
    OLLAMA_STATUS="stopped"
fi

# Check Python environment
echo ""
echo "🔷 Python Environment:"
VENV_PATH="$SCRIPT_DIR/venv"
if [ -d "$VENV_PATH" ]; then
    echo "   ✅ Virtual environment exists"
    if [ -f "$VENV_PATH/bin/python3" ]; then
        PYTHON_VERSION=$("$VENV_PATH/bin/python3" --version 2>&1 | cut -d' ' -f2)
        echo "   • Python version: $PYTHON_VERSION"
        
        # Check key packages
        source "$VENV_PATH/bin/activate"
        JUPYTERHUB_VER=$(python3 -c "import jupyterhub; print(jupyterhub.__version__)" 2>/dev/null || echo "not found")
        JUPYTER_AI_VER=$(python3 -c "import jupyter_ai; print(jupyter_ai.__version__)" 2>/dev/null || echo "not found")
        echo "   • JupyterHub: $JUPYTERHUB_VER"
        echo "   • Jupyter AI: $JUPYTER_AI_VER"
        deactivate 2>/dev/null || true
    fi
else
    echo "   ❌ Virtual environment not found"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Summary:"
if [ "$JUPYTERHUB_STATUS" = "running" ] && [ "$OLLAMA_STATUS" = "running" ] && [ "$TUNNEL_STATUS" = "running" ]; then
    echo "   ✅ All systems operational"
    echo "   🌐 Access: https://heysym.truyenthong.edu.vn"
elif [ "$JUPYTERHUB_STATUS" = "running" ] && [ "$TUNNEL_STATUS" = "running" ]; then
    echo "   ⚠️  JupyterHub and Tunnel running, but Ollama is not available"
    echo "   🌐 Access: https://heysym.truyenthong.edu.vn"
elif [ "$JUPYTERHUB_STATUS" = "running" ]; then
    echo "   ⚠️  JupyterHub running, but Tunnel is not active"
    echo "   💡 Start services: ./start.sh"
elif [ "$TUNNEL_STATUS" = "running" ]; then
    echo "   ⚠️  Tunnel running, but JupyterHub is stopped"
    echo "   💡 Start JupyterHub: ./start.sh"
else
    echo "   ❌ Services are stopped"
fi

echo ""
echo "💡 Available commands:"
echo "   • Start HeySym: ./start.sh"
echo "   • Stop HeySym: ./stop.sh"
echo "   • Restart HeySym: ./restart.sh"
echo "   • Start all services: ./start.sh"
echo "   • Stop all services: ./stop.sh"
echo "   • View JupyterHub logs: tail -f logs/jupyterhub.log"
echo "   • View Tunnel logs: tail -f logs/cloudflare-tunnel.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

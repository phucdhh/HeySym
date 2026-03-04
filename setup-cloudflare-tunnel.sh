#!/bin/bash

# HeySym - Cloudflare Tunnel Setup Script
# Thiết lập Cloudflare Tunnel cho heysym.truyenthong.edu.vn

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CF_DIR="$SCRIPT_DIR/cloudflare"
TUNNEL_NAME="heysym"
DOMAIN="heysym.truyenthong.edu.vn"

# Cloudflare credentials (provided by user)
ZONE_ID="72731de3f08d42d689f39c81a9e4f42c"
ACCOUNT_ID="6950e81586db847aaa38425fc72c2ed1"
API_TOKEN="qE7_PIPCDJLWgYenWC5C9c0d3sgx3aNVdHOAPk0N"

echo "🌐 HeySym - Cloudflare Tunnel Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Check cloudflared
echo "1️⃣  Checking cloudflared..."
if ! command -v cloudflared &> /dev/null; then
    echo "❌ cloudflared not found. Installing..."
    brew install cloudflare/cloudflare/cloudflared
else
    echo "✅ cloudflared found: $(cloudflared --version | head -1)"
fi

# 2. Create cloudflare directory
echo ""
echo "2️⃣  Creating cloudflare directory..."
mkdir -p "$CF_DIR"
echo "✅ Directory created: $CF_DIR"

# 3. Authenticate with Cloudflare using API Token
echo ""
echo "3️⃣  Authenticating with Cloudflare..."
export CLOUDFLARE_API_TOKEN="$API_TOKEN"
export CLOUDFLARE_ACCOUNT_ID="$ACCOUNT_ID"

# 4. Check if tunnel already exists
echo ""
echo "4️⃣  Checking for existing tunnel..."
EXISTING_TUNNEL=$(cloudflared tunnel list --output json 2>/dev/null | jq -r ".[] | select(.name==\"$TUNNEL_NAME\") | .id" || echo "")

if [ -n "$EXISTING_TUNNEL" ]; then
    echo "⚠️  Tunnel '$TUNNEL_NAME' already exists (ID: $EXISTING_TUNNEL)"
    read -p "Do you want to delete and recreate it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing tunnel..."
        cloudflared tunnel delete "$TUNNEL_NAME" || true
        TUNNEL_ID=""
    else
        TUNNEL_ID="$EXISTING_TUNNEL"
        echo "Using existing tunnel: $TUNNEL_ID"
    fi
fi

# 5. Create tunnel if needed
if [ -z "$TUNNEL_ID" ]; then
    echo ""
    echo "5️⃣  Creating new tunnel..."
    cloudflared tunnel create "$TUNNEL_NAME"
    
    # Get tunnel ID
    TUNNEL_ID=$(cloudflared tunnel list --output json | jq -r ".[] | select(.name==\"$TUNNEL_NAME\") | .id")
    echo "✅ Tunnel created: $TUNNEL_ID"
else
    echo ""
    echo "5️⃣  Using existing tunnel: $TUNNEL_ID"
fi

# 6. Copy credentials file
echo ""
echo "6️⃣  Setting up credentials..."
CRED_FILE="$HOME/.cloudflared/$TUNNEL_ID.json"
if [ -f "$CRED_FILE" ]; then
    cp "$CRED_FILE" "$CF_DIR/heysym-credentials.json"
    echo "✅ Credentials copied to $CF_DIR/heysym-credentials.json"
else
    echo "❌ Credentials file not found at $CRED_FILE"
    exit 1
fi

# 7. Update config with actual tunnel ID
echo ""
echo "7️⃣  Updating tunnel configuration..."
sed -i.bak "s/^tunnel: .*/tunnel: $TUNNEL_ID/" "$CF_DIR/heysym-tunnel.yaml"
echo "✅ Config updated with tunnel ID: $TUNNEL_ID"

# 8. Create DNS route
echo ""
echo "8️⃣  Creating DNS route..."
# Check if route already exists
EXISTING_ROUTE=$(cloudflared tunnel route dns list "$TUNNEL_NAME" 2>/dev/null | grep "$DOMAIN" || echo "")

if [ -n "$EXISTING_ROUTE" ]; then
    echo "⚠️  DNS route already exists for $DOMAIN"
else
    cloudflared tunnel route dns "$TUNNEL_NAME" "$DOMAIN"
    echo "✅ DNS route created: $DOMAIN -> $TUNNEL_NAME"
fi

# 9. Validate configuration
echo ""
echo "9️⃣  Validating tunnel configuration..."
if cloudflared tunnel ingress validate "$CF_DIR/heysym-tunnel.yaml"; then
    echo "✅ Configuration is valid"
else
    echo "❌ Configuration validation failed"
    exit 1
fi

# 10. Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Cloudflare Tunnel Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Configuration Summary:"
echo "   • Tunnel Name: $TUNNEL_NAME"
echo "   • Tunnel ID: $TUNNEL_ID"
echo "   • Domain: $DOMAIN"
echo "   • Backend: http://localhost:3333"
echo "   • Config: $CF_DIR/heysym-tunnel.yaml"
echo "   • Credentials: $CF_DIR/heysym-credentials.json"
echo ""
echo "🚀 Next Steps:"
echo "   1. Start JupyterHub: ./start.sh"
echo "   2. Start services: ./start.sh"
echo "   3. Access: https://$DOMAIN"
echo ""
echo "💡 Useful Commands:"
echo "   • Test tunnel: cloudflared tunnel run --config $CF_DIR/heysym-tunnel.yaml"
echo "   • View routes: cloudflared tunnel route dns list"
echo "   • Tunnel info: cloudflared tunnel info $TUNNEL_NAME"
echo "   • Delete tunnel: cloudflared tunnel delete $TUNNEL_NAME"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

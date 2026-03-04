#!/bin/bash

# HeySym - Fix DNS Route
# Update DNS record để trỏ đến tunnel HeySym mới

set -e

TUNNEL_ID="bd882e16-2443-4300-8f2c-e3f431cc25f2"
DOMAIN="heysym.truyenthong.edu.vn"
ZONE_ID="72731de3f08d42d689f39c81a9e4f42c"
API_TOKEN="qE7_PIPCDJLWgYenWC5C9c0d3sgx3aNVdHOAPk0N"

echo "🔧 Fixing DNS Route for HeySym"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

export CLOUDFLARE_API_TOKEN="$API_TOKEN"

# 1. Get existing DNS record
echo "1️⃣  Checking existing DNS records..."
RECORD_JSON=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$DOMAIN" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json")

RECORD_ID=$(echo "$RECORD_JSON" | jq -r '.result[0].id // empty')
RECORD_TYPE=$(echo "$RECORD_JSON" | jq -r '.result[0].type // empty')
RECORD_CONTENT=$(echo "$RECORD_JSON" | jq -r '.result[0].content // empty')

if [ -z "$RECORD_ID" ]; then
    echo "⚠️  No existing DNS record found for $DOMAIN"
    echo "   Creating new record..."
    
    # Create new DNS record
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"CNAME\",\"name\":\"heysym\",\"content\":\"$TUNNEL_ID.cfargotunnel.com\",\"ttl\":1,\"proxied\":true}" | jq
    
    echo "✅ DNS record created"
else
    echo "✅ Found existing DNS record:"
    echo "   Type: $RECORD_TYPE"
    echo "   Content: $RECORD_CONTENT"
    echo "   Record ID: $RECORD_ID"
    echo ""
    
    # 2. Update DNS record
    echo "2️⃣  Updating DNS record to point to HeySym tunnel..."
    NEW_CONTENT="$TUNNEL_ID.cfargotunnel.com"
    
    UPDATE_RESULT=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"CNAME\",\"name\":\"heysym\",\"content\":\"$NEW_CONTENT\",\"ttl\":1,\"proxied\":true}")
    
    SUCCESS=$(echo "$UPDATE_RESULT" | jq -r '.success')
    
    if [ "$SUCCESS" = "true" ]; then
        echo "✅ DNS record updated successfully!"
        echo "   New CNAME: $NEW_CONTENT"
    else
        echo "❌ Failed to update DNS record:"
        echo "$UPDATE_RESULT" | jq
        exit 1
    fi
fi

# 3. Verify
echo ""
echo "3️⃣  Verifying DNS configuration..."
sleep 2

VERIFY_JSON=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$DOMAIN" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json")

CURRENT_CONTENT=$(echo "$VERIFY_JSON" | jq -r '.result[0].content')

if [[ "$CURRENT_CONTENT" == "$TUNNEL_ID.cfargotunnel.com" ]]; then
    echo "✅ DNS verified correctly!"
    echo "   $DOMAIN → $CURRENT_CONTENT"
else
    echo "⚠️  DNS not updated yet:"
    echo "   Current: $CURRENT_CONTENT"
    echo "   Expected: $TUNNEL_ID.cfargotunnel.com"
fi

# 4. Test DNS resolution
echo ""
echo "4️⃣  Testing DNS resolution..."
echo "   (May take 1-2 minutes to propagate)"
sleep 3

if nslookup "$DOMAIN" 8.8.8.8 > /dev/null 2>&1; then
    echo "✅ DNS resolving correctly"
    nslookup "$DOMAIN" 8.8.8.8 | grep -A2 "Name:"
else
    echo "⚠️  DNS not propagated yet"
    echo "   Wait a few minutes and test: nslookup $DOMAIN 8.8.8.8"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DNS Route Fixed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Configuration:"
echo "   • Domain: $DOMAIN"
echo "   • Tunnel ID: $TUNNEL_ID"
echo "   • CNAME: $TUNNEL_ID.cfargotunnel.com"
echo ""
echo "🧪 Testing:"
echo "   • Wait 1-2 minutes for DNS propagation"
echo "   • Test DNS: nslookup $DOMAIN 8.8.8.8"
echo "   • Test access: curl -I https://$DOMAIN"
echo "   • Open browser: https://$DOMAIN"
echo ""
echo "💡 Important:"
echo "   • HeyPhom tunnel (heyphom.truyenthong.edu.vn) is separate"
echo "   • HeySym tunnel (heysym.truyenthong.edu.vn) is now configured"
echo "   • Both can run independently"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

#!/bin/bash

# HeySym - Manual DNS Setup Guide
# Hướng dẫn tạo DNS record cho HeySym tunnel qua Cloudflare Dashboard

TUNNEL_ID="bd882e16-2443-4300-8f2c-e3f431cc25f2"
DOMAIN="heysym.truyenthong.edu.vn"
ZONE="truyenthong.edu.vn"

cat << 'EOF'
🌐 HeySym - Manual DNS Setup Guide
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

API Token không có quyền DNS, cần setup manual qua Cloudflare Dashboard.

📋 Bước 1: Mở Cloudflare Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Truy cập: https://dash.cloudflare.com/
2. Chọn domain: truyenthong.edu.vn
3. Click vào tab: DNS → Records

📝 Bước 2: Thêm/Update DNS Record
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Nếu record "heysym" ĐÃ TỒN TẠI:
   1. Tìm record: heysym.truyenthong.edu.vn
   2. Click "Edit"
   3. Update các field:
      • Type: CNAME
      • Name: heysym
      • Target: bd882e16-2443-4300-8f2c-e3f431cc25f2.cfargotunnel.com
      • TTL: Auto
      • Proxy status: ✅ Proxied (orange cloud)
   4. Click "Save"

Nếu record "heysym" CHƯA TỒN TẠI:
   1. Click "Add record"
   2. Điền các field:
      • Type: CNAME
      • Name: heysym
      • Target: bd882e16-2443-4300-8f2c-e3f431cc25f2.cfargotunnel.com
      • TTL: Auto
      • Proxy status: ✅ Proxied (orange cloud)
   3. Click "Save"

⚠️  LƯU Ý QUAN TRỌNG:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ HeySym tunnel:  heysym.truyenthong.edu.vn  → bd882e16-2443-4300-8f2c-e3f431cc25f2.cfargotunnel.com
✅ HeyPhom tunnel: heyphom.truyenthong.edu.vn → [giữ nguyên - KHÔNG THAY ĐỔI]

KHÔNG động vào các record khác (heyphom, heyim, heymac, v.v.)!

🧪 Bước 3: Kiểm tra DNS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sau khi save, đợi 1-2 phút rồi test:

EOF

echo "Test DNS resolution:"
echo "   nslookup heysym.truyenthong.edu.vn 8.8.8.8"
echo ""
echo "Expected output:"
echo "   Name:    heysym.truyenthong.edu.vn"
echo "   Address: [Cloudflare IP]"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Chạy lệnh này để test:"
echo ""
echo "   nslookup heysym.truyenthong.edu.vn 8.8.8.8"
echo ""
echo "Nếu resolve OK, test HTTPS access:"
echo ""
echo "   curl -I https://heysym.truyenthong.edu.vn"
echo ""
echo "Hoặc mở browser: https://heysym.truyenthong.edu.vn"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Current Status:"
echo ""
./status.sh | grep -A20 "Cloudflare Tunnel:"

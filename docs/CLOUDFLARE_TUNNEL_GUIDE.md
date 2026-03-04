# HeySym với Cloudflare Tunnel - Quick Start Guide

## 🎯 Tổng quan

HeySym sử dụng **Cloudflare Tunnel** để expose JupyterHub ra internet thông qua domain `heysym.truyenthong.edu.vn` một cách an toàn, không cần:
- ❌ Mở port trên router
- ❌ Public IP tĩnh
- ❌ Cấu hình firewall phức tạp
- ❌ Tự quản lý SSL certificate

## 🚀 Setup Lần Đầu

### Bước 1: Setup Cloudflare Tunnel

```bash
cd /Users/mac/HeySym
./setup-cloudflare-tunnel.sh
```

Script này sẽ:
1. ✅ Kiểm tra/cài đặt `cloudflared`
2. ✅ Authenticate với Cloudflare (dùng API token đã cung cấp)
3. ✅ Tạo tunnel "heysym"
4. ✅ Cấu hình DNS route: `heysym.truyenthong.edu.vn` → tunnel
5. ✅ Lưu credentials vào `cloudflare/heysym-credentials.json`
6. ✅ Validate configuration

**Chỉ cần chạy 1 lần duy nhất!**

### Bước 2: Start Services

```bash
# Start JupyterHub + Cloudflare Tunnel
./start.sh
```

### Bước 3: Truy cập

Mở browser:
```
https://heysym.truyenthong.edu.vn
```

✅ HTTPS tự động (Cloudflare quản lý SSL)
✅ Không cần VPN hay cấu hình gì thêm

---

## 📊 Kiểm tra trạng thái

```bash
./status.sh
```

Output mẫu khi mọi thứ OK:
```
📊 HeySym Status Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 JupyterHub Service:
   ✅ Status: Running
   • PID: 12345
   • Uptime: 1:23:45
   • Port 3333: ✅ Listening
   • Active users: 2

🔷 Cloudflare Tunnel:
   ✅ Status: Running
   • PID: 12346
   • Uptime: 1:23:40
   • Domain: heysym.truyenthong.edu.vn
   • Backend: http://localhost:3333

🔷 Ollama Service:
   ✅ Status: Running
   • Version: 0.14.3
   • Available models: deepseek-r1:8b, glm-4.7:cloud, ...

📋 Summary:
   ✅ All systems operational
   🌐 Access: https://heysym.truyenthong.edu.vn
```

---

## 🛠️ Các lệnh quản lý

### JupyterHub
```bash
./start.sh          # Khởi động JupyterHub
./stop.sh           # Dừng JupyterHub
./restart.sh        # Restart JupyterHub
```

### All Services
```bash
./start.sh          # Khởi động JupyterHub + Tunnel
./stop.sh           # Dừng tất cả services
./restart.sh        # Restart services
```

### Combined Status
```bash
./status.sh         # Xem tất cả services
```

### Logs
```bash
# JupyterHub logs
tail -f logs/jupyterhub.log

# Cloudflare Tunnel logs
tail -f logs/cloudflare-tunnel.log
```

---

## 🔧 Cấu trúc thư mục

```
/Users/mac/HeySym/
├── cloudflare/
│   ├── heysym-tunnel.yaml           # Tunnel config
│   └── heysym-credentials.json      # Tunnel credentials (bí mật!)
├── logs/
│   ├── jupyterhub.log
│   └── cloudflare-tunnel.log
├── setup-cloudflare-tunnel.sh       # Setup lần đầu
├── start.sh                         # Start JupyterHub + Tunnel
├── stop.sh                          # Stop tất cả services
├── restart.sh                       # Restart services
├── status.sh                        # Check status
├── jupyterhub.pid                   # JupyterHub PID
└── cloudflare-tunnel.pid            # Tunnel PID
```

---

## 🧪 Troubleshooting

### 1. Tunnel không start được

**Kiểm tra logs:**
```bash
cat logs/cloudflare-tunnel.log
```

**Thử chạy trực tiếp để xem lỗi:**
```bash
cloudflared tunnel --config cloudflare/heysym-tunnel.yaml run
```

**Validate config:**
```bash
cloudflared tunnel ingress validate cloudflare/heysym-tunnel.yaml
```

### 2. Domain không truy cập được

**Kiểm tra DNS route:**
```bash
cloudflared tunnel route dns list
```

Should show:
```
heysym.truyenthong.edu.vn -> heysym (tunnel-id)
```

**Test từ bên ngoài:**
```bash
nslookup heysym.truyenthong.edu.vn
# Should resolve to Cloudflare IPs
```

### 3. JupyterHub chạy nhưng tunnel không connect

**Kiểm tra JupyterHub có listening port 3333:**
```bash
lsof -i :3333
```

**Test local access:**
```bash
curl -I http://localhost:3333
```

Should return HTTP response (redirect to login).

### 4. Credentials không hợp lệ

**Re-run setup:**
```bash
./setup-cloudflare-tunnel.sh
```

Chọn option để delete và recreate tunnel.

### 5. Tunnel bị disconnect

**Restart tunnel:**
```bash
./restart.sh
```

**Check Cloudflare dashboard** để xem tunnel status.

---

## 🔐 Security Notes

### Credentials File
File `cloudflare/heysym-credentials.json` chứa thông tin nhạy cảm:
- ✅ Đã được gitignore
- ⚠️ **KHÔNG** commit vào git
- ⚠️ **KHÔNG** share công khai
- ✅ Chỉ user `mac` có quyền đọc

### API Token
Token `qE7_PIPCDJLWgYenWC5C9c0d3sgx3aNVdHOAPk0N`:
- Được dùng trong `setup-cloudflare-tunnel.sh`
- Có quyền quản lý tunnels trong account
- ⚠️ Nên rotate định kỳ trên Cloudflare dashboard

### Tunnel Access
- Tunnel chỉ forward traffic từ domain đã configure
- Cloudflare tự động chặn DDoS
- Rate limiting có thể config trên Cloudflare dashboard

---

## 📈 Monitoring

### Cloudflare Dashboard
Access tại: https://dash.cloudflare.com/
- Account ID: `6950e81586db847aaa38425fc72c2ed1`
- Zone: `truyenthong.edu.vn`

Features:
- ✅ Real-time traffic analytics
- ✅ Tunnel connection status
- ✅ Security events
- ✅ Performance metrics

### Local Monitoring
```bash
# Continuous status check
watch -n 5 ./status.sh

# Monitor tunnel logs
tail -f logs/cloudflare-tunnel.log | grep -i "error\|warning\|connected"

# Check tunnel info
cloudflared tunnel info heysym
```

---

## 🚀 Production Recommendations

### 1. Auto-start on Boot (macOS LaunchAgent)

Create `~/Library/LaunchAgents/com.heysym.services.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.heysym.services</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>cd /Users/mac/HeySym && ./start.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/mac/HeySym/logs/launchd.out.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/mac/HeySym/logs/launchd.err.log</string>
</dict>
</plist>
```

Load:
```bash
launchctl load ~/Library/LaunchAgents/com.heysym.services.plist
```

### 2. Health Check Cron

Add to crontab (`crontab -e`):
```bash
# Check every 5 minutes, restart if down
*/5 * * * * /Users/mac/HeySym/status.sh > /dev/null || /Users/mac/HeySym/start.sh
```

### 3. Log Rotation

Add to `/etc/newsyslog.conf`:
```
/Users/mac/HeySym/logs/*.log  644  7  100  *  GZ
```

---

## 📚 Additional Resources

- **Cloudflare Tunnel Docs**: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
- **JupyterHub Docs**: https://jupyterhub.readthedocs.io/
- **HeySym Project**: `/Users/mac/HeySym/README.md`

---

## 🆘 Support

Nếu gặp vấn đề:
1. Check `./status.sh`
2. Review logs trong `logs/`
3. Validate config: `cloudflared tunnel ingress validate cloudflare/heysym-tunnel.yaml`
4. Test local: `curl http://localhost:3333`
5. Check Cloudflare dashboard

---

## ✅ Checklist Startup

```bash
# 1. Start JupyterHub
./start.sh
# Start all services (JupyterHub + Tunnel)
./start.sh
# Wait for services to start

# 2. Verify
./status.sh
# Should show all services running

# 3. Test access
curl -I https://heysym.truyenthong.edu.vn
# Should return HTTP 200 or redirect to login
```

**🎉 Done! Access tại: https://heysym.truyenthong.edu.vn**

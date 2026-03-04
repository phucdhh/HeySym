# HeySym Management Scripts

Bộ scripts quản lý ứng dụng HeySym một cách dễ dàng.

## 📋 Các Scripts

### 🚀 start.sh
Khởi động JupyterHub cho HeySym.

```bash
./start.sh
```

**Chức năng:**
- ✅ Activate Python virtual environment
- ✅ Khởi động JupyterHub ở background
- ✅ Lưu PID để quản lý
- ✅ Tạo log file tự động
- ✅ Kiểm tra xem đã chạy chưa (tránh duplicate)

**Output:**
```
🚀 Starting HeySym...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Activating virtual environment...
🔧 Starting JupyterHub...
✅ HeySym started successfully!

📊 Service Information:
   • JupyterHub PID: 12345
   • Web Interface: http://192.168.1.100:3333
   • Log file: logs/jupyterhub.log

💡 Next steps:
   • Check status: ./status.sh
   • View logs: tail -f logs/jupyterhub.log
   • Stop service: ./stop.sh
```

---

### 🛑 stop.sh
Dừng JupyterHub một cách graceful.

```bash
./stop.sh
```

**Chức năng:**
- ✅ Graceful shutdown (SIGTERM trước)
- ✅ Force kill nếu không dừng sau 10 giây
- ✅ Cleanup các user notebook servers
- ✅ Xóa PID file
- ✅ Tìm và dừng process ngay cả khi không có PID file

**Output:**
```
🛑 Stopping HeySym...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Stopping JupyterHub (PID: 12345)...
..
🧹 Cleaning up user notebook servers...
✅ HeySym stopped successfully!

💡 To start again: ./start.sh
```

---

### 📊 status.sh
Kiểm tra trạng thái của HeySym và Ollama.

```bash
./status.sh
```

**Chức năng:**
- ✅ Kiểm tra JupyterHub (PID, uptime, memory, CPU)
- ✅ Kiểm tra Ollama (status, version, models)
- ✅ Kiểm tra Python environment
- ✅ Đếm số active users
- ✅ Kiểm tra port listening
- ✅ Tổng kết tình trạng tổng quan

**Output:**
```
📊 HeySym Status Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 JupyterHub Service:
   ✅ Status: Running
   • PID: 12345
   • Uptime: 2:30:45
   • Memory: 156.3 MB
   • CPU: 2.5%
   • URL: http://192.168.1.100:3333
   • Port 3333: ✅ Listening
   • Active users: 2

🔷 Ollama Service:
   ✅ Status: Running
   • URL: http://localhost:11434
   • Version: 0.14.3
   • Available models:
     - deepseek-r1:8b
     - glm-4.7:cloud
     - nomic-embed-text:latest
     [...]

🔷 Python Environment:
   ✅ Virtual environment exists
   • Python version: 3.11.14
   • JupyterHub: 5.4.3
   • Jupyter AI: 2.31.7

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Summary:
   ✅ All systems operational

💡 Available commands:
   • Start HeySym: ./start.sh
   • Stop HeySym: ./stop.sh
   • Restart HeySym: ./restart.sh
   • View logs: tail -f logs/jupyterhub.log
```

---

### 🔄 restart.sh
Restart JupyterHub (stop + start).

```bash
./restart.sh
```

**Chức năng:**
- ✅ Gọi stop.sh để dừng service
- ✅ Đợi 2 giây
- ✅ Gọi start.sh để khởi động lại
- ✅ Đơn giản và an toàn

**Output:**
```
🔄 Restarting HeySym...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Output của stop.sh]

⏳ Waiting 2 seconds before restart...

[Output của start.sh]

✅ Restart completed!
```

---

## 🎯 Use Cases

### Khởi động HeySym sau khi reboot
```bash
cd /Users/mac/HeySym
./start.sh
```

### Kiểm tra xem có đang chạy không
```bash
./status.sh
```

### Restart sau khi update code
```bash
./restart.sh
```

### Dừng để maintenance
```bash
./stop.sh
```

### Xem logs real-time
```bash
tail -f logs/jupyterhub.log
```

---

## 🔍 Troubleshooting

### "HeySym is already running"
```bash
# Kiểm tra status
./status.sh

# Nếu thực sự đang chạy, stop trước
./stop.sh

# Hoặc restart
./restart.sh
```

### "Port 3333 already in use"
```bash
# Tìm process đang dùng port
lsof -i :3333

# Kill process đó
kill -9 <PID>

# Hoặc dùng stop.sh
./stop.sh
```

### "Stale PID file"
```bash
# status.sh sẽ phát hiện và báo
./status.sh

# stop.sh sẽ cleanup tự động
./stop.sh

# Hoặc xóa manual
rm jupyterhub.pid
```

### Scripts không execute được
```bash
# Đảm bảo có executable permission
chmod +x *.sh

# Hoặc run với bash
bash start.sh
```

---

## 📁 File Structure

```
/Users/mac/HeySym/
├── start.sh              # Script khởi động
├── stop.sh               # Script dừng
├── status.sh             # Script kiểm tra trạng thái
├── restart.sh            # Script restart
├── jupyterhub.pid        # PID file (tự động tạo)
├── logs/                 # Log directory
│   └── jupyterhub.log    # JupyterHub logs
├── config/
│   └── jupyterhub_config.py
└── venv/                 # Python virtual environment
```

---

## ⚙️ Configuration

Scripts tự động detect các paths:
- **VENV_PATH**: `$SCRIPT_DIR/venv`
- **CONFIG_FILE**: `$SCRIPT_DIR/config/jupyterhub_config.py`
- **PID_FILE**: `$SCRIPT_DIR/jupyterhub.pid`
- **LOG_DIR**: `$SCRIPT_DIR/logs`

Không cần config gì thêm!

---

## 🚨 Important Notes

### Về Ollama
- ⚠️ Scripts **KHÔNG** start/stop Ollama
- Ollama là shared service cho nhiều ứng dụng
- Chỉ `status.sh` kiểm tra Ollama status
- Nếu cần start Ollama: `brew services start ollama`

### Về Logs
- Logs được ghi vào `logs/jupyterhub.log`
- Tự động rotate khi file quá lớn (do JupyterHub)
- Xem real-time: `tail -f logs/jupyterhub.log`

### Về Permissions
- Scripts cần executable permission (`chmod +x`)
- JupyterHub cần quyền tạo user directories
- Đảm bảo user có quyền ghi vào `/Users/mac/HeySym`

---

## 🔐 Production Recommendations

### 1. Systemd Service (Linux)
Nếu deploy lên Linux server:
```bash
sudo systemctl enable jupyterhub
sudo systemctl start jupyterhub
```

### 2. Launchd Service (macOS)
Tạo `~/Library/LaunchAgents/com.heysym.jupyterhub.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.heysym.jupyterhub</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/mac/HeySym/start.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Load:
```bash
launchctl load ~/Library/LaunchAgents/com.heysym.jupyterhub.plist
```

### 3. Monitoring
```bash
# Cron job để check health mỗi 5 phút
*/5 * * * * /Users/mac/HeySym/status.sh > /dev/null || /Users/mac/HeySym/start.sh
```

---

## 📞 Support

Nếu gặp vấn đề:
1. Chạy `./status.sh` để xem tình trạng
2. Check logs: `cat logs/jupyterhub.log`
3. Thử restart: `./restart.sh`
4. Check GitHub issues hoặc documentation

---

## 📝 Changelog

### Version 1.0 (2026-02-05)
- ✅ Initial release
- ✅ 4 basic management scripts
- ✅ PID-based process management
- ✅ Comprehensive status checking
- ✅ Graceful shutdown
- ✅ Log management
- ✅ User session tracking

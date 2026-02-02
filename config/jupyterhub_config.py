# Configuration file for JupyterHub - HeySym Project
# Triển khai cho Mac Mini M2 (24GB RAM)

import os
from jupyterhub.spawner import LocalProcessSpawner

c = get_config()  #noqa

# Fix PATH for configurable-http-proxy
os.environ['PATH'] = '/opt/homebrew/Cellar/node/25.3.0/bin:' + os.environ.get('PATH', '')

# Custom spawner để không yêu cầu system user
class CustomLocalProcessSpawner(LocalProcessSpawner):
    def user_env(self, env):
        """Override để không check system user"""
        env['USER'] = self.user.name
        env['HOME'] = f'/Users/mac/HeySym/user_notebooks/{self.user.name}'
        env['SHELL'] = '/bin/bash'
        return env
    
    def make_preexec_fn(self, name):
        """Override để không gọi setuid (không cần system user)"""
        def preexec():
            # Tạo user directory nếu chưa có
            user_dir = f'/Users/mac/HeySym/user_notebooks/{name}'
            os.makedirs(user_dir, exist_ok=True)
            # Không gọi setuid vì không có system user
        return preexec
    
    def get_env(self):
        """Get environment variables"""
        env = super().get_env()
        # Tạo user directory nếu chưa có
        user_dir = f'/Users/mac/HeySym/user_notebooks/{self.user.name}'
        os.makedirs(user_dir, exist_ok=True)
        return env

# ============================================================================
# 1. CƠ BẢN - BASIC CONFIGURATION
# ============================================================================

# Port và địa chỉ JupyterHub
c.JupyterHub.ip = '0.0.0.0'   # Lắng nghe tất cả interface
c.JupyterHub.port = 3333       # Port 3333 thay vì 8000 mặc định
c.JupyterHub.hub_port = 3335   # Hub internal port (default 8081)

# Database (SQLite cho đơn giản, chuyển PostgreSQL sau nếu scale)
c.JupyterHub.db_url = 'sqlite:///config/jupyterhub.sqlite'

# Cookie secret (tự động tạo nếu chưa có)
c.JupyterHub.cookie_secret_file = 'config/jupyterhub_cookie_secret'

# Admin users (thêm username của bạn vào đây)
c.Authenticator.admin_users = {'admin', 'phucdhh'}

# Allow all authenticated users
c.Authenticator.allow_all = True

# ============================================================================
# 2. AUTHENTICATION - XÁC THỰC
# ============================================================================

# Sử dụng NativeAuthenticator (đăng ký tài khoản trực tiếp)
c.JupyterHub.authenticator_class = 'nativeauthenticator.NativeAuthenticator'

# Admin phải approve user mới (không auto-approve)
c.Authenticator.auto_approved = False

# Cho phép đăng ký user mới
c.Authenticator.open_signup = True

# Mật khẩu tối thiểu 8 ký tự
c.Authenticator.minimum_password_length = 8

# Không bắt buộc username phải là chữ thường
c.Authenticator.check_common_password = True

# ============================================================================
# 3. SPAWNER - QUẢN LÝ NOTEBOOK SERVER
# ============================================================================

# Sử dụng Custom Spawner để không cần system user
c.JupyterHub.spawner_class = CustomLocalProcessSpawner

# Timeout cho spawner (60 giây)
c.Spawner.http_timeout = 60
c.Spawner.start_timeout = 60

# Giới hạn tài nguyên mỗi user
c.Spawner.mem_limit = '3G'  # Mỗi user tối đa 3GB RAM
c.Spawner.cpu_limit = 2.0   # Mỗi user tối đa 2 CPU cores

# Notebook directory - tạo trong thư mục project
c.Spawner.notebook_dir = '/Users/mac/HeySym/user_notebooks/{username}'

# Môi trường Python
c.Spawner.environment = {
    'JUPYTER_ENABLE_LAB': '1',  # Mặc định mở JupyterLab thay vì Notebook
    'PATH': '/Users/mac/HeySym/venv/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
}

# Default URL - mở JupyterLab thay vì classic notebook
c.Spawner.default_url = '/lab'

# Specify the command to spawn notebook servers
c.Spawner.cmd = ['/Users/mac/HeySym/venv/bin/jupyterhub-singleuser']

# Disable system user requirement (quan trọng!)
c.Spawner.disable_user_config = True

# ============================================================================
# 4. JUPYTER AI - KẾT NỐI OLLAMA
# ============================================================================

# Thiết lập biến môi trường cho Jupyter AI
c.Spawner.environment.update({
    # Ollama endpoint
    'OLLAMA_BASE_URL': 'http://localhost:11434',
    
    # Các model có sẵn (Cloud AI ưu tiên, Local AI dự phòng)
    'JUPYTER_AI_DEFAULT_MODEL': 'ollama:kimi',
    
    # Thư mục cho Jupyter AI cache
    'JUPYTER_AI_CACHE_DIR': '/Users/mac/HeySym/.jupyter_ai_cache',
})

# ============================================================================
# 5. NBGRADER - QUẢN LÝ BÀI TẬP
# ============================================================================

# Thư mục exchange cho nbgrader (nơi student nộp bài)
exchange_dir = '/Users/mac/HeySym/exchange'
os.makedirs(exchange_dir, exist_ok=True)
os.chmod(exchange_dir, 0o777)  # Cho phép mọi user đọc/ghi

c.Spawner.environment.update({
    'NBGRADER_EXCHANGE': exchange_dir,
})

# ============================================================================
# 6. LOGGING & MONITORING
# ============================================================================

# Log level
c.Application.log_level = 'INFO'

# Log file
c.JupyterHub.extra_log_file = '/Users/mac/HeySym/logs/jupyterhub.log'

# ============================================================================
# 7. SERVICES - DỊCH VỤ BỔ SUNG
# ============================================================================

# Idle Culler - tự động tắt notebook không hoạt động (tiết kiệm RAM)
c.JupyterHub.services = [
    {
        'name': 'idle-culler',
        'admin': True,
        'command': [
            'python', '-m', 'jupyterhub_idle_culler',
            '--timeout=3600',  # 1 giờ không hoạt động sẽ tắt
        ],
    }
]

# ============================================================================
# 8. SECURITY
# ============================================================================

# CORS (nếu cần truy cập từ domain khác)
# c.JupyterHub.tornado_settings = {
#     'headers': {
#         'Access-Control-Allow-Origin': '*',
#     }
# }

# ============================================================================
# 9. PERFORMANCE TUNING
# ============================================================================

# Số concurrent notebook servers tối đa
c.JupyterHub.concurrent_spawn_limit = 10

# Proxy authentication token (tự động tạo nếu chưa có)
# c.ConfigurableHTTPProxy.auth_token = '<your-token-here>'

# ============================================================================
# 10. ADDITIONAL PATHS
# ============================================================================

# Thư mục home cho users (mỗi user sẽ có thư mục riêng)
# c.Spawner.notebook_dir = '~/notebooks'

# ============================================================================
# GHI CHÚ - NOTES
# ============================================================================
# 
# CAPACITY ESTIMATE (với config này):
# - Cloud AI Models (Kimi/GPT OSS): 15-20 users đồng thời
# - Local AI Model (deepseek-r1:8b): 6-8 users đồng thời
# - Total RAM Usage: ~18GB peak (để 6GB cho hệ thống)
#
# DEPLOYMENT CHECKLIST:
# ✅ Cài đặt packages: jupyterhub, jupyterlab, nbgrader, jupyter-ai
# ✅ Cài đặt Ollama và pull models
# ✅ Tạo admin user đầu tiên
# ✅ Test connection với Ollama
# ✅ Test nbgrader exchange directory
# ✅ Configure Cloudflare Tunnel (Phase 3)
# ✅ Setup LaunchDaemon auto-start (Phase 3)
#
# IMPORTANT URLS:
# - JupyterHub: http://localhost:3333
# - JupyterHub Admin: http://localhost:3333/hub/admin
# - Ollama API: http://localhost:11434
#
# ADMIN TASKS:
# 1. Tạo admin user đầu tiên (username: admin hoặc phucdhh)
# 2. Approve user registrations tại /hub/authorize
# 3. Monitor resource usage tại /hub/admin
# 4. Check logs: tail -f /Users/mac/HeySym/logs/jupyterhub.log
#
# ============================================================================

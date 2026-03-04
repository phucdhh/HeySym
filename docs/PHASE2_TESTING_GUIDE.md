# Phase 2: Testing Guide - HeySym Project

**Date**: February 3, 2026  
**Status**: ✅ JupyterHub Running on http://localhost:3333

---

## 🎯 Testing Objectives

1. ✅ **Authentication Testing** - Tạo và quản lý users
2. ⏳ **Jupyter AI Integration** - Test AI models với SymPy
3. ⏳ **nbgrader Workflow** - Test assignment management
4. ⏳ **Load Testing** - Test với 5-10 concurrent users
5. ⏳ **Resource Monitoring** - Kiểm tra RAM/CPU usage

---

## 📋 Test Case 1: Authentication & User Management

### 1.1. Tạo Admin User Đầu Tiên

**URL**: http://localhost:3333

**Steps**:
1. Truy cập http://localhost:3333
2. Click vào **"Sign Up"** (hoặc tương tự)
3. Tạo tài khoản admin:
   - **Username**: `admin` (hoặc `phucdhh`)
   - **Password**: `admin12345` (tối thiểu 8 ký tự)
   - **Confirm Password**: `admin12345`
4. Sau khi đăng ký, user sẽ pending approval
5. Approve user qua command line (vì đây là admin đầu tiên):

```bash
cd /Users/mac/HeySym
source venv/bin/activate
python -c "
from jupyterhub.orm import User
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

engine = create_engine('sqlite:///config/jupyterhub.sqlite')
Session = sessionmaker(bind=engine)
session = Session()

# Get the first user
user = session.query(User).filter_by(name='admin').first()
if user:
    user.admin = True
    session.commit()
    print(f'✅ User {user.name} is now admin')
else:
    print('❌ User not found')
"
```

**Alternative Method** (nếu NativeAuthenticator hỗ trợ):
```bash
jupyterhub token admin -f config/jupyterhub_config.py
```

### 1.2. Test Login

1. Quay lại http://localhost:3333
2. Login với:
   - **Username**: `admin`
   - **Password**: `admin12345`
3. Nếu thành công, bạn sẽ thấy:
   - JupyterLab interface
   - Admin panel link (nếu là admin)

### 1.3. Tạo Regular User (Test Student Account)

1. Sign up với username khác:
   - **Username**: `student1`
   - **Password**: `student123`
2. Login với admin và approve user:
   - Truy cập http://localhost:3333/hub/admin
   - Click vào tab **"Authorize"** hoặc **"Pending Users"**
   - Approve user `student1`
3. Test login với `student1`

**Expected Results**:
- ✅ Admin user có thể login và access admin panel
- ✅ Regular user cần approval trước khi login
- ✅ Mỗi user có workspace riêng

---

## 📋 Test Case 2: Jupyter AI Integration

### 2.1. Test AI Magic Commands

**Steps**:
1. Login vào JupyterHub
2. Tạo new notebook (Python kernel)
3. Test %%ai magic command:

```python
# Cell 1: Load jupyter-ai extension
%load_ext jupyter_ai_magics
```

```python
# Cell 2: Test với Kimi (Cloud AI)
%%ai ollama:kimi-k2-thinking:cloud
Giải thích khái niệm đạo hàm trong toán học bằng tiếng Việt
```

```python
# Cell 3: Test với SymPy integration
%%ai ollama:kimi-k2-thinking:cloud
Cho tôi code Python để tính đạo hàm của hàm số f(x) = x^3 + 2x^2 + 5 sử dụng SymPy
```

### 2.2. Test Different AI Models

```python
# Test Local AI Model (deepseek-r1:8b)
%%ai ollama:deepseek-r1:8b
What is the derivative of x^2?
```

```python
# Test GPT OSS (Cloud)
%%ai ollama:gpt-oss:120b-cloud
Explain the concept of limits in calculus
```

### 2.3. Test SymPy + AI Workflow

```python
# Cell 1: Import SymPy
import sympy as sp
from sympy import symbols, diff, integrate, simplify

x = sp.Symbol('x')
f = x**3 + 2*x**2 + 5
print(f"Function: {f}")
```

```python
# Cell 2: Ask AI for help
%%ai ollama:kimi-k2-thinking:cloud
Tôi có hàm số f(x) = x^3 + 2x^2 + 5. 
Hãy giúp tôi:
1. Tính đạo hàm bậc nhất
2. Tính đạo hàm bậc hai
3. Tìm điểm cực trị
```

```python
# Cell 3: Implement AI's suggestion
f_prime = diff(f, x)
f_double_prime = diff(f_prime, x)
critical_points = sp.solve(f_prime, x)

print(f"f'(x) = {f_prime}")
print(f"f''(x) = {f_double_prime}")
print(f"Critical points: {critical_points}")
```

**Expected Results**:
- ✅ jupyter-ai extension loads successfully
- ✅ Kimi (Cloud AI) responds in Vietnamese
- ✅ deepseek-r1:8b (Local AI) works offline
- ✅ AI can understand SymPy code context
- ⏱️ Response time: Cloud AI (~2-5s), Local AI (~5-10s with 8GB RAM)

---

## 📋 Test Case 3: nbgrader Basic Workflow

### 3.1. Setup Instructor Environment

**Create Course Directory**:
```bash
cd /Users/mac/HeySym
source venv/bin/activate

# Create course directory
mkdir -p courses/sympy_2025
cd courses/sympy_2025

# Initialize nbgrader
nbgrader quickstart sympy_2025 --force
```

### 3.2. Create Sample Assignment

**Create assignment notebook** (`source/assignment1/problem1.ipynb`):

```python
# Cell 1 (Markdown)
# Problem 1: Tính Đạo Hàm
Sử dụng SymPy để tính đạo hàm của hàm số sau:
f(x) = x^4 - 3x^2 + 2x - 1
```

```python
# Cell 2 (Code - Graded)
### BEGIN SOLUTION
import sympy as sp
x = sp.Symbol('x')
f = x**4 - 3*x**2 + 2*x - 1
f_prime = sp.diff(f, x)
print(f_prime)
### END SOLUTION
```

```python
# Cell 3 (Test - Autograder)
### BEGIN HIDDEN TESTS
assert str(f_prime) == "4*x**3 - 6*x + 2"
print("✅ Test passed!")
### END HIDDEN TESTS
```

### 3.3. Test nbgrader Commands

```bash
# Generate student version
nbgrader generate_assignment assignment1

# Release assignment (copy to exchange)
nbgrader release_assignment assignment1

# Simulate student fetching assignment
# (Run as different user or copy manually to test)

# Collect submissions
nbgrader collect assignment1

# Autograde
nbgrader autograde assignment1

# Generate feedback
nbgrader generate_feedback assignment1
```

**Expected Results**:
- ✅ Assignment được tạo thành công
- ✅ Student version không có solution code
- ✅ Autograder chạm bài tự động
- ✅ Exchange directory permissions đúng (777)

---

## 📋 Test Case 4: Load Testing

### 4.1. Test với Multiple Users

**Method 1: Manual Testing**
1. Tạo 3-5 users: `student1`, `student2`, `student3`, etc.
2. Login đồng thời từ các browser khác nhau (hoặc incognito windows)
3. Mỗi user tạo notebook và chạy SymPy code
4. Monitor resource usage:

```bash
# Monitor RAM usage
watch -n 2 "ps aux | grep jupyter | awk '{sum+=\$4} END {print \"Total RAM: \" sum \"%\"}'"

# Monitor CPU usage
top -l 1 | grep "CPU usage"

# Monitor active notebooks
ps aux | grep "jupyter-notebook" | wc -l
```

**Method 2: Automated Testing** (Optional)
```python
# test_load.py
import requests
import concurrent.futures

def test_login(username):
    url = "http://localhost:3333/hub/login"
    session = requests.Session()
    # Implement login logic
    pass

users = ['student1', 'student2', 'student3']
with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
    executor.map(test_login, users)
```

### 4.2. Expected Capacity

**With Current Config (24GB RAM, Cloud AI)**:
- ✅ **15-20 concurrent users** with Cloud AI (Kimi/GPT OSS)
- ✅ **6-8 concurrent users** with Local AI (deepseek-r1:8b)
- ⚠️ Each user uses ~1.5-3GB RAM (within 3GB limit)
- ⚠️ System keeps 6GB for macOS

**Performance Benchmarks**:
- Notebook start time: ~3-5 seconds
- SymPy calculation: <1 second (simple expressions)
- AI response time: 2-5s (Cloud), 5-10s (Local)
- Idle culler timeout: 1 hour

---

## 📋 Test Case 5: Resource Monitoring

### 5.1. Monitor JupyterHub Logs

```bash
tail -f /Users/mac/HeySym/logs/jupyterhub_phase2.log
```

### 5.2. Check System Resources

```bash
# Total RAM usage
htop  # or Activity Monitor GUI

# JupyterHub process tree
pstree -p $(pgrep jupyterhub)

# Ollama status
curl -s http://localhost:11434/api/tags | jq '.models[] | {name: .name, size: .size}'
```

### 5.3. Database Check

```bash
cd /Users/mac/HeySym
sqlite3 config/jupyterhub.sqlite "SELECT name, admin, created FROM users;"
```

---

## 🐛 Troubleshooting

### Issue 1: Cannot Login
**Symptom**: Login page shows error or redirects infinitely  
**Solution**:
```bash
# Check logs
tail -50 logs/jupyterhub_phase2.log

# Verify config
jupyterhub -f config/jupyterhub_config.py --generate-config

# Reset cookie secret
rm config/jupyterhub_cookie_secret
```

### Issue 2: AI Magic Commands Not Working
**Symptom**: `%%ai` command shows "unknown magic"  
**Solution**:
```python
# In notebook
%pip install jupyter-ai jupyter-ai-magics
%load_ext jupyter_ai_magics
```

### Issue 3: nbgrader Permission Denied
**Symptom**: Cannot write to exchange directory  
**Solution**:
```bash
chmod 777 /Users/mac/HeySym/exchange
chown -R mac:staff /Users/mac/HeySym/exchange
```

### Issue 4: Port Already in Use
**Symptom**: JupyterHub fails to start with "Address already in use"  
**Solution**:
```bash
# Find and kill process
lsof -ti:3333 | xargs kill -9
lsof -ti:8082 | xargs kill -9

# Restart JupyterHub
cd /Users/mac/HeySym && source venv/bin/activate
jupyterhub -f config/jupyterhub_config.py --no-ssl &
```

---

## ✅ Phase 2 Checklist

- [ ] **Authentication**
  - [ ] Admin user created and can login
  - [ ] Regular user can register
  - [ ] Admin can approve users
  - [ ] User isolation works (separate workspaces)

- [ ] **Jupyter AI**
  - [ ] jupyter-ai extension loads
  - [ ] Kimi (Cloud AI) responds correctly
  - [ ] deepseek-r1:8b (Local AI) works offline
  - [ ] AI understands SymPy context
  - [ ] Response times acceptable

- [ ] **nbgrader**
  - [ ] Can create assignments
  - [ ] Can generate student versions
  - [ ] Can release to exchange
  - [ ] Autograder works correctly
  - [ ] Feedback generation works

- [ ] **Performance**
  - [ ] 5+ concurrent users tested
  - [ ] RAM usage within limits
  - [ ] CPU usage acceptable
  - [ ] Idle culler works correctly

- [ ] **Documentation**
  - [ ] All issues documented
  - [ ] Performance benchmarks recorded
  - [ ] Ready for Phase 3 (Production Pilot)

---

## 📊 Expected Test Results Summary

| Test Case | Expected Result | Pass/Fail | Notes |
|-----------|-----------------|-----------|-------|
| Admin Login | ✅ Success | ⬜ | |
| Student Registration | ✅ Needs approval | ⬜ | |
| Jupyter AI - Kimi | ✅ 2-5s response | ⬜ | |
| Jupyter AI - Local | ✅ 5-10s response | ⬜ | |
| nbgrader Create | ✅ Success | ⬜ | |
| nbgrader Autograde | ✅ Success | ⬜ | |
| 5 Concurrent Users | ✅ <70% RAM | ⬜ | |
| 10 Concurrent Users | ✅ <90% RAM | ⬜ | |

---

## 🚀 Next Steps After Phase 2

Once all tests pass:
1. ✅ Move to **Phase 3: Production Pilot**
2. Setup Cloudflare Tunnel for HTTPS
3. Configure LaunchDaemon for auto-start
4. Pilot với 15-20 real students
5. Setup backup automation

---

**Last Updated**: February 3, 2026  
**Tested By**: [Your Name]  
**JupyterHub Version**: 5.4.3  
**Status**: 🟡 Testing In Progress

# 🚀 Git Setup & Push to GitHub

## Bước 1: Initialize Git Repository

```bash
cd /Users/mac/HeySym

# Initialize git
git init

# Check status
git status
```

## Bước 2: Stage All Files

```bash
# Add all files (except those in .gitignore)
git add .

# Check what will be committed
git status
```

Expected files to be added:
- ✅ README.md
- ✅ PLAN.md
- ✅ LICENSE
- ✅ CONTRIBUTING.md
- ✅ .gitignore
- ✅ .gitattributes
- ✅ init_project.sh
- ✅ .github/ templates

**NOT included** (thanks to .gitignore):
- ❌ venv/
- ❌ config/*.sqlite
- ❌ logs/
- ❌ __pycache__/
- ❌ .DS_Store

## Bước 3: Commit

```bash
git commit -m "🎓 Initial commit: HeySym v1.0 - JupyterHub + nbgrader + AI

- JupyterHub multi-user environment
- nbgrader integration for auto-grading
- Ollama AI assistant (Kimi, GPT OSS, GLM, deepseek-r1)
- Cloudflare Tunnel for secure access
- Complete deployment plan (4 phases)
- GitHub templates for issues and PRs
- MIT License with educational use notice"
```

## Bước 4: Create GitHub Repository

1. Vào https://github.com/new
2. Repository name: `HeySym`
3. Description: `🎓 Hệ thống học SymPy với AI - JupyterHub + nbgrader + Ollama`
4. Visibility: **Public** (hoặc Private nếu muốn)
5. **KHÔNG check** "Initialize with README" (đã có rồi)
6. Click **Create repository**

## Bước 5: Connect to GitHub

```bash
# Add remote
git remote add origin https://github.com/phucdhh/HeySym.git

# Verify remote
git remote -v
```

## Bước 6: Push to GitHub

```bash
# Create and switch to main branch
git branch -M main

# Push
git push -u origin main
```

## Bước 7: Verify on GitHub

1. Vào https://github.com/phucdhh/HeySym
2. Check:
   - ✅ README.md hiển thị đẹp
   - ✅ License badge visible
   - ✅ PLAN.md có link từ README
   - ✅ .github templates work (try creating an issue)

## 🎉 Done!

Repository của bạn đã sẵn sàng!

### Next Steps

1. **Enable GitHub Pages** (optional):
   - Settings → Pages → Source: main branch
   - Để host documentation

2. **Add topics** to repository:
   - Settings → Topics
   - Suggest: `jupyter`, `jupyterhub`, `education`, `python`, `sympy`, `ai`, `ollama`, `nbgrader`

3. **Create first release**:
   - Releases → Create a new release
   - Tag: `v1.0.0`
   - Title: `HeySym v1.0 - Initial Release`

4. **Share with team**:
   - Email link: https://github.com/phucdhh/HeySym
   - Students can now fork/star/watch

## 🔄 Future Updates

Để push updates sau này:

```bash
# Make changes
# ...

# Stage changes
git add .

# Commit
git commit -m "feat: add new feature"

# Push
git push
```

## 🛠️ Troubleshooting

### Permission denied (publickey)

Setup SSH key:
```bash
ssh-keygen -t ed25519 -C "nguyendangminhphuc@dhsphue.edu.vn"
cat ~/.ssh/id_ed25519.pub
# Copy and add to GitHub Settings → SSH Keys
```

Or use HTTPS with token:
```bash
git remote set-url origin https://YOUR_TOKEN@github.com/phucdhh/HeySym.git
```

### Already initialized repository

```bash
# Remove existing .git if needed
rm -rf .git
# Start from Bước 1
```

---

**🎓 HeySym is now live on GitHub!** 🚀

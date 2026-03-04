# HeySym UI Customization Guide

## 🎨 Overview

HeySym có giao diện tùy chỉnh với:
- ✅ Custom logo (HeySym branding)
- ✅ Modern gradient color scheme
- ✅ Educational theme (mathematics-focused)
- ✅ Footer với links đến các ứng dụng khác
- ✅ Responsive design

## 📁 File Structure

```
/Users/mac/HeySym/
├── static/
│   └── custom/
│       ├── heysym-logo.svg      # Logo SVG
│       └── custom.css           # Custom styles
├── templates/
│   ├── page.html               # Base template với footer
│   ├── login.html              # Custom login page
│   └── home.html               # Custom home page
└── config/
    └── jupyterhub_config.py    # Config pointing to custom files
```

## 🎨 Design Elements

### Logo
- **File**: `static/custom/heysym-logo.svg`
- **Design**: 
  - Sigma (Σ) symbol cho toán học
  - Infinity overlay cho AI/learning
  - Gradient blue-purple theme
  - "MATH WITH AI" tagline
- **Dimensions**: 200x50px
- **Format**: SVG (scalable)

### Color Scheme
```css
Primary:   #4A90E2 (Blue)
Secondary: #7B68EE (Purple)
Accent:    #50C878 (Green)
Dark:      #2C3E50
Light:     #ECF0F1
```

### Typography
- Font Family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif
- Headings: 600-700 weight
- Body: 400 weight

## 🎯 Key Features

### 1. Custom Logo
Logo xuất hiện ở:
- Navbar (góc trên trái)
- Login page
- Footer
- Browser tab (favicon)

### 2. Gradient Theme
- Navbar: Blue → Purple gradient
- Buttons: Matching gradient với hover effects
- Login form header: Branded gradient

### 3. Footer (AIThink-inspired)
Footer bao gồm:
- ⚠️ Warning message về AI accuracy
- 🔗 Navigation links (Home, HeyTeX, AIThink, HeyPhom, etc.)
- 📊 HeySym info và credits
- © Copyright notice

### 4. Enhanced Forms
- Rounded corners (6px radius)
- Focus states với subtle shadow
- Hover effects với transform
- Better spacing và padding

## 🔧 Customization

### Thay đổi Logo

**Option 1: Thay file SVG**
```bash
# Backup logo cũ
cp static/custom/heysym-logo.svg static/custom/heysym-logo.svg.bak

# Copy logo mới
cp /path/to/new-logo.svg static/custom/heysym-logo.svg

# Restart JupyterHub
./restart.sh
```

**Option 2: Edit SVG code**
Mở `static/custom/heysym-logo.svg` và chỉnh sửa:
- Colors (gradient stops)
- Text content
- Symbol shapes
- Dimensions

### Thay đổi Colors

Edit `static/custom/custom.css`:
```css
:root {
    --heysym-primary: #4A90E2;    /* Change to your primary color */
    --heysym-secondary: #7B68EE;  /* Change to your secondary color */
    --heysym-accent: #50C878;     /* Change to your accent color */
}
```

### Thay đổi Footer

Edit `templates/page.html`, section `<!-- HeySym Footer -->`:
```html
<!-- Warning Message -->
<div class="footer-warning">
    <strong>⚠️ Lưu ý:</strong> Your custom warning here
</div>

<!-- Navigation Links -->
<div class="footer-links">
    <a href="...">Your Link</a>
    <!-- Add more links -->
</div>
```

### Thay đổi Login Page Message

Edit `templates/login.html`:
```html
<!-- Welcome Message -->
<div class="text-center">
    <p>Your custom welcome message</p>
</div>
```

## 🚀 Apply Changes

### Quick Update Workflow

Khi thay đổi UI files:

```bash
# 1. Edit files in static/custom/ or templates/
vim static/custom/custom.css
vim templates/page.html

# 2. Copy static files to JupyterHub directory
./update-ui.sh

# 3. Restart JupyterHub
./restart.sh

# 4. Test changes
open http://localhost:3333
```

**Important:** Static files (CSS, images, SVG) must be copied to `venv/share/jupyterhub/static/custom/` because JupyterHub serves static files from its installation directory.

**Note**: Một số thay đổi CSS có thể cần clear browser cache:
- Cmd+Shift+R (Mac)
- Ctrl+Shift+R (Windows/Linux)

## 📱 Responsive Design

UI tự động adapt cho:
- 📱 Mobile (< 768px)
  - Footer links stack vertically
  - Logo scale down
  - Simplified layout
  
- 💻 Tablet (768px - 992px)
  - Optimized spacing
  - Readable font sizes
  
- 🖥️ Desktop (> 992px)
  - Full layout
  - All features visible

## 🎨 Advanced Customization

### Add Custom Fonts

1. Download font files to `static/custom/fonts/`
2. Add to `custom.css`:
```css
@font-face {
    font-family: 'YourFont';
    src: url('/hub/static/custom/fonts/YourFont.woff2') format('woff2');
}

body {
    font-family: 'YourFont', sans-serif;
}
```

### Add Announcement Banner

Edit `config/jupyterhub_config.py`:
```python
c.JupyterHub.template_vars = {
    'announcement': 'Your announcement message here',
}
```

Then add to `templates/page.html`:
```html
{% if announcement %}
<div class="alert alert-info" style="margin: 0; border-radius: 0;">
    {{ announcement }}
</div>
{% endif %}
```

### Custom Home Page Cards

Edit `templates/home.html`, add new cards:
```html
<div class="col-md-4">
    <div class="panel panel-default">
        <div class="panel-body text-center">
            <i class="fa fa-icon-name" style="font-size: 48px; color: #4A90E2;"></i>
            <h4>Card Title</h4>
            <p>Card description</p>
            <a href="#" class="btn btn-primary btn-sm">Action</a>
        </div>
    </div>
</div>
```

## 🐛 Troubleshooting

### Logo không hiển thị

**Check file path:**
```bash
ls -la static/custom/heysym-logo.svg
```

**Check JupyterHub config:**
```python
# In jupyterhub_config.py
c.JupyterHub.logo_file = '/Users/mac/HeySym/static/heysym-logo.svg'
c.JupyterHub.extra_static_paths = ['/Users/mac/HeySym/static']
```

**Check logs:**
```bash
tail -f logs/jupyterhub.log | grep -i "logo\|static"
```

### CSS không apply

**Clear browser cache:**
- Hard refresh: Cmd+Shift+R (Mac) / Ctrl+Shift+R (Windows)

**Check CSS loading:**
```bash
curl -I http://localhost:3333/hub/static/custom/custom.css
# Should return 200 OK
```

**Verify template paths:**
```python
c.JupyterHub.template_paths = ['/Users/mac/HeySym/templates']
```

### Footer không xuất hiện

**Check template:**
```bash
grep -n "footer" templates/page.html
# Should show footer section
```

**Ensure page.html được extend:**
```jinja2
{% extends "page.html" %}
```

### Gradient không hoạt động

**Check browser compatibility:**
- Gradients require modern browser
- IE11 và cũ hơn không support

**Fallback color:**
```css
background: #4A90E2; /* Fallback */
background: linear-gradient(135deg, #4A90E2 0%, #7B68EE 100%);
```

## 📊 Testing

### Test Local
```bash
# Test login page
curl -s http://localhost:3333/hub/login | grep "HeySym"

# Test logo loading
curl -I http://localhost:3333/hub/static/custom/heysym-logo.svg

# Test CSS loading
curl -I http://localhost:3333/hub/static/custom/custom.css
```

### Test via Tunnel
```bash
# After DNS is set up
curl -s https://heysym.truyenthong.edu.vn/hub/login | grep "HeySym"
```

### Visual Testing
1. Open https://heysym.truyenthong.edu.vn
2. Check logo in navbar
3. Verify login page styling
4. Check footer links
5. Test responsive (resize browser)

## 🎓 Design Philosophy

HeySym UI được thiết kế theo nguyên tắc:

1. **Educational Focus**: Colors và typography phù hợp với learning environment
2. **Professional**: Clean, modern, không quá flashy
3. **Mathematical**: Sigma symbol, infinity, gradient (continuous learning)
4. **Accessible**: High contrast, readable fonts, clear hierarchy
5. **Consistent**: Matching theme across all pages

## 📚 Resources

- **JupyterHub Templates**: https://jupyterhub.readthedocs.io/en/stable/reference/templates.html
- **Custom CSS**: https://jupyterhub.readthedocs.io/en/stable/howto/templates.html
- **Logo Design**: SVG format cho best quality at all sizes
- **Color Palette**: https://coolors.co/ để chọn màu harmonious

## 🔮 Future Enhancements

Ideas cho future updates:
- [ ] Dark mode toggle
- [ ] Animated logo (subtle movement)
- [ ] More color themes (user selectable)
- [ ] Custom 404/500 error pages
- [ ] User profile customization
- [ ] Achievement badges
- [ ] Progress tracking visualization

## 📝 Changelog

### 2026-02-05
- ✅ Initial custom UI implementation
- ✅ HeySym logo design (SVG)
- ✅ Custom CSS with gradient theme
- ✅ Footer inspired by AIThink
- ✅ Enhanced login page
- ✅ Custom home page with cards
- ✅ Responsive design
- ✅ Configuration in jupyterhub_config.py

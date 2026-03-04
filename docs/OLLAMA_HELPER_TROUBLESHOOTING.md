# OllamaHelper Troubleshooting Guide

## Vấn đề thường gặp và cách fix

### ❌ Issue 1: Chỉ thấy timing, không thấy output

**Triệu chứng:**
```python
ai = OllamaHelper()
answer = ai.ask("Question")
print(answer)

# Output:
# 🤔 deepseek-r1:8b đang trả lời:
# ⏱️  Tổng thời gian: 32.3s
# [không có gì khác]
```

**Nguyên nhân:**
- Đã có output trong streaming phase nhưng bạn không thấy
- Cell chạy xong nhưng IPython.display không render trong context hiện tại
- `print(answer)` in lại plain text nhưng formatted version đã hiển thị rồi

**Fix:**
1. **KHÔNG dùng `print(answer)`** - output đã tự động hiển thị!
```python
# ✅ ĐÚNG
answer = ai.ask("Question")  # Thấy streaming + formatted

# ❌ SAI
answer = ai.ask("Question")
print(answer)  # Duplicate và có thể không hiển thị đúng
```

2. Nếu muốn lấy plain text để xử lý sau:
```python
answer = ai.ask("Question", display_format=False)
# Bây giờ answer là string, có thể parse/process
parsed = json.loads(answer)
```

---

### ❌ Issue 2: generate_code không có output

**Triệu chứng:**
```python
code = ai.generate_code("Calculate factorial")
# Chỉ thấy timing, không thấy code
```

**Nguyên nhân:**
- `generate_code` đặt `display_format=False` (code không cần Markdown)
- Output được print trong streaming nhưng không được "captured" bởi cell

**Fix:**
```python
# Chỉ cần chạy, code sẽ streaming ra
code = ai.generate_code("Calculate factorial")

# Nếu muốn xem lại code
print("\n📝 Code đã sinh:")
print(code)

# Test code
exec(code)
result = factorial(5)
print(f"Result: {result}")
```

---

### ❌ Issue 3: LaTeX không render đẹp

**Triệu chứng:**
```python
ai.ask("Explain $E=mc^2$")
# Thấy $E=mc^2$ thay vì E=mc² rendered
```

**Nguyên nhân:**
- Jupyter notebook chưa load MathJax
- Output bị print thay vì display
- Formatted phase không chạy

**Fix:**

1. **Reload module** sau khi update code:
```python
import importlib
import ollama_helper
importlib.reload(ollama_helper)
from ollama_helper import OllamaHelper

ai = OllamaHelper()
```

2. **Restart kernel** và chạy lại từ đầu

3. **Verify IPython context:**
```python
from IPython import get_ipython
print(get_ipython())  # Should not be None
```

4. **Force display:**
```python
from IPython.display import display, Markdown

answer = ai.ask("Question with $LaTeX$", display_format=False)
display(Markdown(answer))  # Manual display
```

---

### ❌ Issue 4: Quick functions không hoạt động

**Triệu chứng:**
```python
from ollama_helper import quick_ask, solve

answer = quick_ask("Question")
# Không có output gì
```

**Nguyên nhân:**
- Old version của module đã cache
- Quick functions tạo helper mới với silent=True

**Fix:**
```python
# 1. Restart kernel
# 2. Clear output và re-run
# 3. Hoặc dùng OllamaHelper trực tiếp

ai = OllamaHelper()
answer = ai.ask("Question")  # This always works
```

---

### ❌ Issue 5: Stream quá nhanh, không kịp đọc

**Triệu chứng:**
Text streaming quá nhanh, khó theo dõi

**Fix:**
```python
# Option 1: Tắt streaming, chỉ xem kết quả cuối
answer = ai.ask("Question", stream=False)

# Option 2: Sau khi stream xong, scroll lên xem formatted version
# Formatted version sẽ có header:
# ============================================================
# 📝 Phiên bản định dạng:
# ============================================================
```

---

### ❌ Issue 6: "NameError: name 'display' is not defined"

**Triệu chứng:**
```
NameError: name 'display' is not defined
```

**Nguyên nhân:**
- Chạy code ngoài Jupyter notebook
- IPython không có trong environment

**Fix:**

1. **Trong notebook** - đảm bảo đã import:
```python
from IPython.display import display, Markdown
```

2. **Ngoài notebook** - ollama_helper sẽ tự động fallback về print:
```python
# Code đã có try/except, sẽ tự động dùng print
answer = ai.ask("Question")  # Works trong terminal
```

---

### ❌ Issue 7: Model mất quá lâu (>60s)

**Triệu chứng:**
Đợi rất lâu mà không có output

**Nguyên nhân:**
- Model lớn (deepseek-r1:8b có reasoning)
- Prompt quá phức tạp
- Ollama server chậm

**Fix:**

1. **Đợi thêm** - deepseek-r1 có thể mất 30-90s cho câu phức tạp

2. **Dùng model nhẹ hơn:**
```python
ai.change_model("glm-4.7:cloud")  # Nhanh hơn
answer = ai.ask("Question")
```

3. **Đơn giản hóa prompt:**
```python
# ❌ Prompt quá dài
ai.ask("Explain quantum mechanics in detail with examples...")

# ✅ Prompt ngắn gọn
ai.ask("Explain quantum mechanics briefly")
```

4. **Monitor Ollama:**
```bash
# Terminal khác
watch -n 1 "curl -s http://localhost:11434/api/ps | python3 -m json.tool"
```

---

### ❌ Issue 8: exec(code) lỗi sau generate_code

**Triệu chứng:**
```python
code = ai.generate_code("Function X")
exec(code)
# NameError: name 'function_name' is not defined
```

**Nguyên nhân:**
- AI sinh code với tên function khác
- Code có lỗi syntax
- exec() chạy trong namespace khác

**Fix:**

1. **Print code trước khi exec:**
```python
code = ai.generate_code("Calculate area of circle")
print("\n📝 Generated code:")
print(code)
print("\n🧪 Testing...")

# Exec vào global namespace
exec(code, globals())

# Bây giờ có thể dùng
result = circle_area(5)
```

2. **Chỉ định tên function:**
```python
code = ai.generate_code("""
Create a function called 'circle_area' that takes radius as parameter
and returns the area of a circle.
""")
exec(code, globals())
print(circle_area(5))
```

3. **Xử lý lỗi:**
```python
code = ai.generate_code("Description")
try:
    exec(code, globals())
    print("✅ Code works!")
except Exception as e:
    print(f"❌ Error: {e}")
    print("Code:")
    print(code)
```

---

### ❌ Issue 9: Output bị duplicate (hiện 2 lần)

**Triệu chứng:**
Thấy output 2 lần - 1 lần plain text, 1 lần formatted

**Nguyên nhân:**
- Gọi `print(answer)` sau `ai.ask()`
- Display và print đều chạy

**Fix:**
```python
# ❌ SAI - duplicate output
answer = ai.ask("Q")
print(answer)  # Thừa!

# ✅ ĐÚNG - chỉ call, không print
answer = ai.ask("Q")

# Hoặc nếu cần process kết quả
answer = ai.ask("Q", display_format=False)  # Không display
result = process(answer)  # Xử lý
print(result)  # Print kết quả xử lý
```

---

### ❌ Issue 10: Markdown formatting không đẹp

**Triệu chứng:**
Vẫn thấy `**bold**`, `*italic*` thay vì text in đậm/nghiêng

**Nguyên nhân:**
- `display_format=False`
- IPython.display không hoạt động
- Cell output mode không đúng

**Fix:**

1. **Verify display_format:**
```python
# Mặc định là True
answer = ai.ask("Q")  # Should format

# Nếu bị tắt
answer = ai.ask("Q", display_format=True)  # Force on
```

2. **Manual format nếu cần:**
```python
from IPython.display import display, Markdown

answer = ai.ask("Q", display_format=False)
display(Markdown(answer))  # Format manually
```

3. **Check Jupyter settings:**
```python
# Trong notebook, chạy:
from IPython.display import display, Markdown
display(Markdown("**Test bold** and *italic*"))
# Nếu không thấy formatted → vấn đề với Jupyter, không phải code
```

---

## Best Practices để tránh issues

### ✅ DO:

1. **Để output tự động hiển thị:**
```python
ai.ask("Question")  # Không cần print
```

2. **Reload module sau khi edit:**
```python
import importlib
import ollama_helper
importlib.reload(ollama_helper)
```

3. **Check output của generate_code:**
```python
code = ai.generate_code("Description")
print("Generated:")
print(code)
exec(code, globals())
```

4. **Dùng model phù hợp:**
```python
# Câu đơn giản → model nhẹ
ai.change_model("glm-4.7:cloud")

# Câu phức tạp → model mạnh
ai.change_model("deepseek-r1:8b")
```

### ❌ DON'T:

1. **Không print result sau ask:**
```python
# ❌ BAD
result = ai.ask("Q")
print(result)  # Duplicate!
```

2. **Không expect instant results:**
```python
# ❌ BAD - interrupt sau 5s
ai.ask("Complex question")  # Đợi thêm!
```

3. **Không ignore error messages:**
```python
# ❌ BAD
code = ai.generate_code("X")
exec(code)  # Không check errors

# ✅ GOOD
try:
    exec(code, globals())
except Exception as e:
    print(f"Error: {e}")
```

---

## Debug Checklist

Khi gặp issue, check theo thứ tự:

- [ ] Đã restart kernel chưa?
- [ ] Đã reload module chưa?
- [ ] Có đang print(result) thừa không?
- [ ] display_format có đúng setting không?
- [ ] IPython context có hoạt động không? (`get_ipython()`)
- [ ] Ollama server có đang chạy không? (`curl localhost:11434/api/tags`)
- [ ] Model có available không? (`ollama list`)
- [ ] Đã đợi đủ lâu chưa? (>30s cho complex prompts)

---

## Quick Fixes Cho Từng Issue

| Issue | Quick Fix |
|-------|-----------|
| Không có output | Bỏ `print(answer)` |
| generate_code không work | `print(code)` trước `exec(code)` |
| LaTeX không render | Restart kernel |
| Quá chậm | Dùng model nhẹ hơn |
| Duplicate output | Bỏ `print()` |
| Display error | `display_format=False` + manual display |
| NameError after exec | `exec(code, globals())` |
| Formatting không đẹp | `display_format=True` (mặc định) |

---

## Test Script

Chạy script này để verify mọi thứ hoạt động:

```python
# Test Script
import sys
sys.path.insert(0, '/Users/mac/HeySym/config')

# Test 1: Import
print("Test 1: Import...")
from ollama_helper import OllamaHelper, quick_ask
print("✅ Import OK")

# Test 2: Create instance
print("\nTest 2: Create instance...")
ai = OllamaHelper(model="glm-4.7:cloud")
print("✅ Instance OK")

# Test 3: Simple ask
print("\nTest 3: Simple ask...")
answer = ai.ask("Say 'Hello' in one word only", stream=False)
print(f"✅ Ask OK - got: {answer[:50]}")

# Test 4: Streaming
print("\nTest 4: Streaming...")
answer = ai.ask("Count from 1 to 3", stream=True)
print("✅ Streaming OK")

# Test 5: Generate code
print("\nTest 5: Generate code...")
code = ai.generate_code("Function that returns 42")
print("✅ Generate code OK")
print(f"Code preview: {code[:100]}")

# Test 6: Display
print("\nTest 6: IPython display...")
from IPython import get_ipython
if get_ipython():
    print("✅ IPython context OK")
else:
    print("⚠️  Not in IPython - display may not work")

print("\n🎉 All tests passed!")
```

---

## Khi nào cần help

Nếu vẫn gặp issue sau khi thử tất cả fixes trên:

1. **Restart everything:**
   - Jupyter kernel
   - Terminal
   - Ollama server: `brew services restart ollama`

2. **Reinstall packages:**
```bash
source venv/bin/activate
pip install --force-reinstall langchain-ollama jupyter-ai
```

3. **Check logs:**
```bash
tail -f ~/.ollama/logs/server.log
```

4. **Report issue với thông tin:**
   - Error message đầy đủ
   - Code bạn đã chạy
   - Output actual vs expected
   - Python version, OS, Ollama version

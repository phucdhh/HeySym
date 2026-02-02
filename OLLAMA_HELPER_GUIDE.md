# HeySym OllamaHelper - Quick Reference

## 🎉 Những gì đã cải tiến

### 1. ⚡ Streaming Mặc Định
- **Trước:** `stream=False` → đợi lâu mới thấy kết quả
- **Bây giờ:** `stream=True` mặc định → thấy output real-time ngay lập tức!

```python
ai = OllamaHelper()

# Streaming tự động - không cần thêm tham số
answer = ai.ask("Giải thích định lý Pythagoras")
# → Thấy từng chữ khi AI generate ⚡
```

### 2. 🎨 Auto Formatting
Output tự động được format đẹp với:
- **Markdown**: bold (`**text**`), italic (`*text*`), lists, etc.
- **LaTeX Math**: inline `$E=mc^2$` và block `$$\int_a^b f(x)dx$$`

**Flow:**
1. **Streaming phase**: Thấy plain text từng chữ một
2. **Formatting phase**: Sau khi xong, hiển thị formatted version đẹp

```python
ai.ask("""
Giải phương trình: $x^2 + 5x + 6 = 0$

Sử dụng công thức nghiệm: $$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$
""")
```

**Output:**
- Plain text streaming: `x^2 + 5x + 6 = 0` → `x = (-b ± √(b²-4ac))/2a`
- Formatted display: $x^2 + 5x + 6 = 0$ → $x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$

### 3. ✅ Fix generate_code
- **Trước:** Không có output, không biết AI đang làm gì
- **Bây giờ:** Thấy code được sinh ra từng dòng!

```python
code = ai.generate_code("Calculate factorial recursively")
# → Thấy code xuất hiện từng dòng
# → Không cần verbose=True nữa
```

### 4. 🔧 Tất cả methods đều streaming
```python
ai.solve_math(problem)        # stream=True mặc định
ai.explain_concept(concept)   # stream=True mặc định
ai.check_answer(q, ans)       # stream=True mặc định
ai.generate_code(desc)        # stream=True mặc định

# Quick functions cũng vậy
quick_ask(prompt)    # stream=True
solve(problem)       # stream=True
explain(concept)     # stream=True
```

### 5. 🧠 Chain-of-Thought Streaming (NEW!)
Với models như `deepseek-r1`, `qwen-r1`, bạn có thể **thấy quá trình suy nghĩ** của AI:

```python
ai = OllamaHelper(model="deepseek-r1:8b")

# Mặc định hiển thị thinking process
ai.ask("Giải phương trình x^2 - 5x + 6 = 0")
# Output:
# 🤔 deepseek-r1:8b đang suy nghĩ:
# First, let's analyze... (màu xám - thinking tokens)
# ...
# 💡 Kết luận:
# Phương trình x^2 - 5x + 6 = 0... (kết quả chính)

# Tắt thinking nếu muốn chỉ thấy kết quả
ai.ask("Question", show_thinking=False)
```

**Lợi ích:**
- ✅ Không còn cảm giác "đang đợi mà không biết AI làm gì"
- ✅ Hiểu được cách AI suy luận (educational value!)
- ✅ Đặc biệt hữu ích với reasoning models như deepseek-r1

## 📖 Cách sử dụng

### Basic Usage
```python
from ollama_helper import OllamaHelper

ai = OllamaHelper(model="deepseek-r1:8b")

# Tất cả đều streaming + formatted + chain-of-thought mặc định
answer = ai.ask("Định lý Pythagoras là gì?")
```

### Chain-of-Thought Models
```python
# Models hỗ trợ thinking tokens (auto-detected)
deepseek = OllamaHelper(model="deepseek-r1:8b")
qwen = OllamaHelper(model="qwen-r1:7b")

# Mặc định hiển thị thinking process
deepseek.ask("Tính tổng các số từ 1 đến 100")
# → Thấy thinking tokens màu xám
# → Sau đó kết luận

# Tắt thinking nếu muốn
deepseek.ask("Question", show_thinking=False)
# → Chỉ thấy kết quả cuối cùng
```

### Tắt Streaming (không khuyến nghị)
```python
# Nếu thực sự muốn đợi toàn bộ kết quả
answer = ai.ask("Question", stream=False)
# ⚠️ Sẽ mất 10-30s không có phản hồi gì
```

### Tắt Formatting
```python
# Nếu chỉ muốn plain text (VD: parsing output)
answer = ai.ask("Question", display_format=False)
# → Chỉ return string, không display Markdown/LaTeX
```

### Generate Code
```python
code = ai.generate_code(
    "Create a function to find prime numbers up to n"
)
# → Thấy code streaming
# → display_format=False tự động (code không cần markdown)

# Chạy code vừa sinh
exec(code)
result = find_primes(100)
print(result)
```

### Math Problems với LaTeX
```python
solution = ai.solve_math("""
Tính tích phân: ∫(x² + 2x + 1)dx từ 0 đến 3

Hiển thị kết quả với LaTeX notation.
""")
# → Streaming plain text
# → Formatted với LaTeX đẹp
```

### Check Student Answers
```python
question = "Tính đạo hàm của y = x³ + 2x²"
student_answer = "y' = 3x² + 4x"

feedback = ai.check_answer(question, student_answer)
# → Streaming feedback real-time
# → Formatted với bold/italic/lists
```

## 🎯 Best Practices

### 1. Luôn để streaming enabled
```python
# ✅ GOOD - Default behavior
ai.ask("Question")

# ❌ BAD - Tắt streaming
ai.ask("Question", stream=False)
```

### 2. Sử dụng chain-of-thought cho reasoning tasks
```python
# ✅ GOOD - Dùng deepseek-r1 cho tasks phức tạp
deepseek = OllamaHelper(model="deepseek-r1:8b")
deepseek.ask("Giải bài toán logic này...")
# → Thấy quá trình suy luận
# → Dễ debug nếu kết quả sai

# ✅ GOOD - Tắt thinking cho tasks đơn giản
deepseek.ask("Tính 2+2", show_thinking=False)
```

### 3. Yêu cầu AI dùng LaTeX cho math
```python
ai.ask("""
Giải phương trình và hiển thị kết quả với LaTeX notation.

Sử dụng $...$ cho inline và $$...$$ cho block equations.
""")
```

### 4. Generate code và test ngay
```python
code = ai.generate_code("Implement quicksort")
exec(code)
# Test ngay
result = quicksort([3, 1, 4, 1, 5, 9, 2, 6])
print(result)
```

### 4. Kết hợp với SymPy
```python
from sympy import symbols, diff, integrate

x = symbols('x')
expr = x**3 + 2*x**2 - 5*x + 1

# Tính với SymPy
derivative = diff(expr, x)

# Giải thích bằng AI
explanation = ai.ask(f"""
Giải thích đạo hàm này: {derivative}

Từ hàm gốc: {expr}
""")
```

## 🔧 Configuration Options

### OllamaHelper Constructor
```python
ai = OllamaHelper(
    base_url="http://localhost:11434",  # Ollama server
    model="deepseek-r1:8b"              # Model name
)
```

### ask() Parameters
```python
ai.ask(
    prompt="Your question",
    verbose=True,          # Show timing info
    stream=True,           # Streaming output (default)
    display_format=True    # Markdown/LaTeX formatting (default)
)
```

### Method-specific Defaults
```python
solve_math()       # stream=True, display_format=True
explain_concept()  # stream=True, display_format=True
check_answer()     # stream=True, display_format=True
generate_code()    # stream=True, display_format=False (code không cần format)
```

## 📊 Output Format Examples

### Plain Streaming (First Phase)
```
🤔 deepseek-r1:8b đang trả lời:

Định lý Pythagoras phát biểu rằng trong tam giác vuông...
[text xuất hiện từng chữ một]

⏱️  Tổng thời gian: 15.3s
```

### Formatted Display (Second Phase)
```
============================================================
📝 Phiên bản định dạng:
============================================================
[Markdown với bold, italic, lists]
[LaTeX equations rendered đẹp]
```

### Code Generation
```
🤔 deepseek-r1:8b đang trả lời:

def circle_area(radius):
    import math
    return math.pi * radius ** 2
[code xuất hiện từng dòng]

⏱️  Tổng thời gian: 8.2s
```

## 🚫 Common Mistakes

### ❌ Mistake 1: Quên reload module sau khi update
```python
# Sau khi edit ollama_helper.py
import importlib
import ollama_helper
importlib.reload(ollama_helper)
```

### ❌ Mistake 2: Expect instant results với model lớn
```python
# deepseek-r1:8b có reasoning → mất 10-30s
# Đừng interrupt quá sớm!
ai.ask("Complex question")  # Đợi streaming...
```

### ❌ Mistake 3: Parse output trong khi streaming
```python
# ❌ BAD - Output đang stream, chưa hoàn thành
result = ai.ask("Question")
parsed = json.loads(result)  # Có thể fail nếu chưa xong

# ✅ GOOD - Đợi xong rồi parse
result = ai.ask("Return JSON", display_format=False)
parsed = json.loads(result)
```

## 🎓 Advanced Examples

### Example 1: Interactive Math Tutor
```python
ai = OllamaHelper()

# Học sinh hỏi
question = ai.ask("Đạo hàm là gì?")

# Học sinh làm bài
student_work = "y' = 2x"

# Giáo viên AI check
feedback = ai.check_answer(
    "Tính đạo hàm của y = x²",
    student_work
)

# Tạo bài tập mới
new_problems = ai.ask("Tạo 3 bài tập về đạo hàm, độ khó tăng dần")
```

### Example 2: Code Generation Pipeline
```python
# 1. Generate
code = ai.generate_code("Implement binary search")

# 2. Test
exec(code)
assert binary_search([1, 2, 3, 4, 5], 3) == 2

# 3. Optimize
optimized = ai.generate_code("""
Optimize this binary search code for better performance:

{code}
""")

# 4. Document
docs = ai.ask(f"""
Generate docstring for this function:

{code}
""")
```

### Example 3: SymPy + AI Workflow
```python
from sympy import *

# Define problem
x = symbols('x')
f = x**4 - 4*x**3 + 6*x**2 - 4*x + 1

# Compute với SymPy
derivative = diff(f, x)
critical_points = solve(derivative, x)

# Giải thích với AI
explanation = ai.ask(f"""
Phân tích hàm số: {f}

Đạo hàm: {derivative}
Điểm tới hạn: {critical_points}

Giải thích:
1. Hành vi của hàm số
2. Tính chất các điểm tới hạn
3. Đồ thị và ứng dụng
""")
```

## 📝 Summary

| Feature | Before | After |
|---------|--------|-------|
| Streaming | `stream=False` | `stream=True` ⚡ |
| Formatting | Plain text only | Markdown + LaTeX 🎨 |
| generate_code | Không output | Streaming code ✅ |
| User experience | Đợi lâu 😴 | Real-time 🚀 |
| Math display | `x^2`, `sqrt(x)` | $x^2$, $\sqrt{x}$ 🎯 |

**Bottom line:** Bây giờ tất cả đều tốt hơn mà không cần config gì thêm! 🎉

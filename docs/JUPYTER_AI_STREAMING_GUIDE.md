# Jupyter AI Magic Commands - Streaming Issue & Solutions

## Vấn đề gặp phải

### 1. Syntax Error với Line Magic
**Lỗi:**
```python
%ai ollama:deepseek-r1:8b -f code -- What is 2+2?
```
```
UsageError: No such command 'ollama:deepseek-r1:8b'.
```

**Nguyên nhân:**
- `%ai` (line magic) chỉ dùng cho **subcommands**: `list`, `help`, `register`, `delete`, `update`, `error`, `version`, `reset`
- `%ai` **KHÔNG dùng để invoke models**

**Cách fix:**
```python
# SAI ❌
%ai ollama:deepseek-r1:8b -f code -- What is 2+2?

# ĐÚNG ✅
%%ai ollama:deepseek-r1:8b -f code
What is 2+2?
```

### 2. Không có Streaming Output
**Vấn đề:**
- Magic commands `%%ai` không streaming
- Phải đợi toàn bộ response mới hiển thị
- Với model reasoning (deepseek-r1:8b) mất 10-30 giây → trải nghiệm không tốt

**Nguyên nhân kỹ thuật:**
Trong `jupyter_ai_magics/magics.py`, magic commands gọi:
```python
result = provider.generate([inputs])  # Blocking call, không streaming
output = result.generations[0][0].text
return self.display_output(output, args.format, md)
```

Magic commands chỉ hiển thị output sau khi có **toàn bộ response**, không phải real-time streaming.

## Giải pháp

### Solution 1: Dùng OllamaHelper với Streaming Support

Chúng tôi đã tạo `OllamaHelper` class với streaming support:

```python
import sys
sys.path.insert(0, '/Users/mac/HeySym/config')
from ollama_helper import OllamaHelper

ai = OllamaHelper(model="deepseek-r1:8b")

# ⚡ Streaming enabled - hiển thị real-time
answer = ai.ask("Giải thích định lý Pythagoras", stream=True)
```

**Cách hoạt động:**
```python
def _ask_stream(self, prompt: str, verbose: bool = True) -> str:
    """Hỏi Ollama với streaming output"""
    start_time = time.time()
    full_response = ""
    
    # Stream từng chunk từ model
    for chunk in self.client.stream(prompt):
        content = chunk.content
        print(content, end="", flush=True)  # Print ngay lập tức
        full_response += content
    
    return full_response
```

### Solution 2: Dùng Cell Magic %%ai (Non-streaming)

Nếu vẫn muốn dùng magic commands:

```python
%%ai ollama:deepseek-r1:8b
Giải thích định lý Pythagoras bằng tiếng Việt
```

**Ưu điểm:**
- Syntax đơn giản
- Integrated trong Jupyter AI ecosystem
- Hỗ trợ nhiều format: `-f code`, `-f markdown`, `-f math`

**Nhược điểm:**
- ⚠️ Không streaming → phải đợi lâu
- Ít flexible hơn direct API calls

## So sánh

| Feature | Magic Commands `%%ai` | OllamaHelper |
|---------|----------------------|--------------|
| Syntax | Cell magic ✅ | Python function ✅ |
| Streaming | ❌ Không | ✅ Có |
| Customization | ⚠️ Hạn chế | ✅ Rất linh hoạt |
| Format support | ✅ `-f code/md/math` | ✅ Custom templates |
| Error handling | ⚠️ Cơ bản | ✅ Advanced |
| Integration | ✅ Jupyter AI ecosystem | ✅ Direct langchain |
| Helper methods | ❌ Không | ✅ solve_math, check_answer, etc. |

## Khuyến nghị

### Dùng OllamaHelper khi:
- ✅ Cần streaming output (UX tốt hơn)
- ✅ Câu trả lời dài (> 10s processing time)
- ✅ Cần customize logic (templates, error handling)
- ✅ Muốn helper methods (solve_math, check_answer)
- ✅ Dùng trong production code

### Dùng Magic Commands khi:
- ✅ Demo nhanh, prototype
- ✅ Câu trả lời ngắn (< 5s)
- ✅ Muốn syntax đơn giản
- ✅ Đã quen với Jupyter AI workflow
- ✅ Không cần streaming

## Ví dụ sử dụng

### Example 1: Quick Ask với Streaming
```python
from ollama_helper import OllamaHelper

ai = OllamaHelper(model="deepseek-r1:8b")

# Streaming enabled - thấy output ngay lập tức
answer = ai.ask("""
Giải thích chi tiết về định lý Lagrange trong giải tích,
bao gồm ý nghĩa hình học và ứng dụng.
""", stream=True)
```

**Output:** Hiển thị từng chữ khi model generate ⚡

### Example 2: Solve Math với Streaming
```python
problem = """
Cho hàm số y = x³ - 3x² + 2
a) Tìm đạo hàm
b) Tìm cực trị
c) Vẽ đồ thị
"""

solution = ai.solve_math(problem, stream=True)
```

**Output:** Thấy lời giải từng bước real-time

### Example 3: Magic Commands (Non-streaming)
```python
%%ai ollama:deepseek-r1:8b -f markdown
Tính đạo hàm của y = x² + 3x - 5
```

**Output:** Đợi 10-20s rồi hiển thị toàn bộ kết quả

## Implementation Details

### Streaming Architecture

```
┌─────────────────┐
│  JupyterLab     │
│  Notebook Cell  │
└────────┬────────┘
         │
         ├─── Magic Commands (%%ai)
         │    └──> provider.generate()  [BLOCKING]
         │         └──> Display all at once ❌
         │
         └─── OllamaHelper
              └──> client.stream()  [STREAMING]
                   └──> print(chunk) immediately ✅
                        └──> User sees real-time output
```

### Code Flow

**Non-streaming (Magic):**
```
User runs cell
  → Parse magic args
    → Call provider.generate()
      → Wait for FULL response (10-30s)
        → Display everything at once
```

**Streaming (OllamaHelper):**
```
User runs cell
  → Call ai.ask(..., stream=True)
    → client.stream() returns iterator
      → For each chunk:
          → Print immediately
          → User sees partial output
        → Return full response when done
```

## Troubleshooting

### Issue: "No such command 'ollama:deepseek-r1:8b'"
**Cause:** Dùng `%ai` (line magic) thay vì `%%ai` (cell magic)

**Fix:**
```python
# Change from:
%ai ollama:deepseek-r1:8b -- prompt

# To:
%%ai ollama:deepseek-r1:8b
prompt here
```

### Issue: Cell chạy lâu không có output
**Cause:** Magic commands không streaming, phải đợi toàn bộ response

**Fix:** Dùng OllamaHelper với streaming:
```python
ai = OllamaHelper()
answer = ai.ask(prompt, stream=True)  # See output immediately
```

### Issue: ImportError: cannot import name 'list_providers'
**Cause:** API changed trong jupyter-ai-magics 2.31.7

**Fix:** Provider registration qua entry_points, không cần manual import

## Future Improvements

### Potential Enhancement: Streaming Magic Commands

Có thể enhance magic commands với streaming bằng cách:

1. **Monkey-patch magics.py:**
```python
from IPython.display import display, Markdown
import sys

def streaming_display(provider, prompt):
    output = ""
    for chunk in provider.stream(prompt):
        sys.stdout.write(chunk.content)
        sys.stdout.flush()
        output += chunk.content
    return output
```

2. **Custom magic command:**
```python
@register_line_cell_magic
def ai_stream(line, cell=None):
    # Implementation với streaming support
    pass
```

3. **Configuration option:**
```python
# jupyter_ai_config.json
{
  "enable_streaming": true,
  "stream_chunk_size": 1
}
```

## References

- Jupyter AI Documentation: https://jupyter-ai.readthedocs.io/
- LangChain Streaming: https://python.langchain.com/docs/expression_language/streaming
- Ollama API: https://github.com/ollama/ollama/blob/main/docs/api.md
- IPython Magic Commands: https://ipython.readthedocs.io/en/stable/interactive/magics.html

## Conclusion

**TL;DR:**
- ❌ `%ai ollama:model` - Sai syntax (line magic không dùng cho models)
- ✅ `%%ai ollama:model` - Đúng syntax nhưng không streaming
- ⚡ `OllamaHelper(stream=True)` - Best solution với streaming support

**Recommendation:** Dùng OllamaHelper thay vì magic commands để có trải nghiệm tốt nhất với streaming output.

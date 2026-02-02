# Chain-of-Thought Streaming trong HeySym

## 🎯 Vấn đề

Với reasoning models như `deepseek-r1`, khi hỏi câu hỏi phức tạp, user phải đợi **30-60 giây** không có phản hồi gì trước khi thấy kết quả. Điều này tạo cảm giác "lag" và không biết AI đang làm gì.

**Tại sao?**
- Models này có "thinking phase" (chain-of-thought reasoning)
- Ollama API streaming có 2 fields riêng biệt:
  - `message.thinking`: Quá trình suy nghĩ của AI
  - `message.content`: Kết luận cuối cùng
- langchain-ollama library **không expose** thinking tokens
- Nên user chỉ thấy content sau khi thinking xong

## ✨ Giải pháp

OllamaHelper giờ có **chain-of-thought streaming**:
- Stream **cả thinking lẫn content** trực tiếp từ Ollama API
- Hiển thị thinking tokens màu xám italic (dễ phân biệt)
- Auto-detect models hỗ trợ chain-of-thought
- Có thể tắt nếu muốn

## 🚀 Cách dùng

### 1. Mặc định - Hiển thị thinking

```python
from ollama_helper import OllamaHelper

# Models có chain-of-thought
ai = OllamaHelper(model="deepseek-r1:8b")

# Tự động hiển thị thinking process
ai.ask("Giải phương trình x^2 - 5x + 6 = 0")
```

**Output:**
```
🤔 deepseek-r1:8b đang suy nghĩ:

[Màu xám italic]
Tôi có phương trình bậc hai: x^2 - 5x + 6 = 0. Tôi cần giải nó.
Có nhiều cách để giải... Tôi sẽ thử phân tích nhân tử...
[continues with full reasoning process]

💡 Kết luận:

Phương trình x^2 - 5x + 6 = 0 có thể được phân tích thành:
(x - 2)(x - 3) = 0

Nghiệm: x = 2 hoặc x = 3

⏱️ Tổng thời gian: 48.1s
   (Thinking: ~437 words, Response: ~71 words)

============================================================
📝 Phiên bản định dạng:
============================================================
[LaTeX formatted version with markdown]
```

### 2. Tắt thinking nếu muốn

```python
# Chỉ hiển thị kết luận
ai.ask("Question", show_thinking=False)
```

## 🎨 Chi tiết kỹ thuật

### Auto-detection
```python
# Models được detect tự động
if any(keyword in self.model.lower() for keyword in ['deepseek-r1', 'qwen', 'r1']):
    # Sử dụng _ask_stream_with_thinking()
```

### API Call trực tiếp
```python
response = requests.post(
    f"{base_url}/api/chat",
    json={
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "stream": True
    },
    stream=True
)

for line in response.iter_lines():
    data = json.loads(line)
    
    # Thinking tokens
    if "thinking" in data["message"]:
        print(thinking_text, style="gray+italic")
    
    # Content tokens
    if "content" in data["message"]:
        print(content_text)
```

### Ollama API Response Format
```json
{"model":"deepseek-r1:8b","message":{"role":"assistant","content":"","thinking":"First"},"done":false}
{"model":"deepseek-r1:8b","message":{"role":"assistant","content":"","thinking":","},"done":false}
{"model":"deepseek-r1:8b","message":{"role":"assistant","content":"","thinking":" the"},"done":false}
...
[After thinking phase]
{"model":"deepseek-r1:8b","message":{"role":"assistant","content":"The","thinking":""},"done":false}
{"model":"deepseek-r1:8b","message":{"role":"assistant","content":" answer","thinking":""},"done":false}
...
{"model":"deepseek-r1:8b","message":{"role":"assistant","content":""},"done":true}
```

## 📊 Performance Metrics

**Test case:** "Giải phương trình x^2 - 5x + 6 = 0"

| Metric | Value |
|--------|-------|
| Total time | 48.1s |
| Thinking words | ~437 words |
| Response words | ~71 words |
| Thinking phase | ~40s (83%) |
| Content phase | ~8s (17%) |

**UX Impact:**
- ✅ Trước: 48s đợi → cảm giác lag
- ✅ Bây giờ: Thấy thinking ngay → không cảm giác đợi

## 🔍 Models hỗ trợ

Hiện tại auto-detect cho:
- `deepseek-r1:*` (any variant)
- `qwen*-r1:*` (Qwen R1 models)
- Any model có `r1` trong tên

**Test với Ollama:**
```bash
# List models có chain-of-thought
ollama list | grep -E "deepseek-r1|qwen.*r1|r1"
```

## 💡 Best Practices

### 1. Dùng cho reasoning tasks
```python
# ✅ GOOD - Complex reasoning
ai.ask("Giải bài toán logic phức tạp...")
# → Thấy AI suy luận từng bước

# ❌ BAD - Simple questions
ai.ask("What is 2+2?", show_thinking=True)
# → Thinking quá dài cho câu hỏi đơn giản
```

### 2. Tắt thinking cho tasks đơn giản
```python
# Quick factual queries
ai.ask("Tính 2+2", show_thinking=False)
ai.ask("What is the capital of France?", show_thinking=False)
```

### 3. Educational use cases
```python
# Cho học sinh thấy cách AI giải toán
ai.ask("""
Giải chi tiết bài toán:
Một ô tô đi từ A đến B với vận tốc 60km/h...
""")
# → Học sinh thấy được cách phân tích từng bước
```

## 🐛 Troubleshooting

### "Không thấy thinking tokens?"
```python
# Check model name
print(ai.model)  # Phải có 'deepseek-r1' hoặc 'r1'

# Force enable
ai.ask(prompt, show_thinking=True)
```

### "Thinking quá dài!"
```python
# Tắt đi
ai.ask(prompt, show_thinking=False)

# Hoặc dùng model khác
ai = OllamaHelper(model="glm-4.7:cloud")  # Không có thinking
```

### "Muốn xem raw Ollama response?"
```bash
curl -s http://localhost:11434/api/chat -d '{
  "model": "deepseek-r1:8b",
  "messages": [{"role": "user", "content": "Test"}],
  "stream": true
}' | jq -c '.message | {thinking, content}'
```

## 📚 Tham khảo

- **Ollama API Docs**: https://github.com/ollama/ollama/blob/main/docs/api.md
- **DeepSeek R1**: Reasoning model với chain-of-thought
- **Implementation**: `/Users/mac/HeySym/config/ollama_helper.py` → `_ask_stream_with_thinking()`

## 🎓 Educational Value

Chain-of-thought streaming không chỉ cải thiện UX, mà còn có giá trị giáo dục:

1. **Transparency**: Học sinh thấy được cách AI suy nghĩ
2. **Learning**: Học được cách tiếp cận bài toán
3. **Debugging**: Nếu kết quả sai, có thể thấy lỗi ở đâu trong thinking
4. **Engagement**: Thú vị hơn so với chỉ thấy kết quả cuối

## 🚀 Future Enhancements

- [ ] Collapsible thinking sections trong Jupyter
- [ ] Different colors cho different reasoning steps
- [ ] Export thinking process sang file
- [ ] Comparison mode: nhiều models suy nghĩ song song
- [ ] Interactive mode: có thể interrupt thinking để hỏi thêm

## 🙏 Credits

Implementation dựa trên discovery về Ollama API structure:
- `message.thinking`: Discovered through direct API testing
- `message.content`: Standard response field
- **langchain-ollama không hỗ trợ thinking field** → phải dùng direct API call

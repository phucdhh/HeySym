# Hướng dẫn Debug Ollama trong Jupyter AI

## Vấn đề hiện tại
Magic command `%%ai ollama:deepseek-r1:8b` không có output gì cả.

## Đã xác minh ✅
1. ✅ OllamaProvider có trong jupyter-ai (đã thấy trong %ai list)
2. ✅ langchain-ollama đã cài đặt (version 0.3.10)
3. ✅ Ollama server đang chạy trên localhost:11434
4. ✅ Connection test thành công từ Python
5. ✅ Provider có thể instantiate và invoke trực tiếp

## Nguyên nhân có thể
1. **Model deepseek-r1:8b mất thời gian xử lý** - Model này có khả năng reasoning nên response time có thể dài (10-30 giây)
2. **Kernel chưa reload** - Cần restart kernel để load provider mới
3. **Output format** - Cell magic có thể trả về format đặc biệt
4. **Base URL chưa được config** - Cần set explicit trong command

## Các bước Debug

### Bước 1: Restart Kernel
1. Trong JupyterLab, click menu **Kernel** → **Restart Kernel**
2. Hoặc click icon hình vòng tròn ở toolbar

### Bước 2: Chạy từng cell trong test_ollama.ipynb
Tôi đã tạo notebook test tại: `/Users/mac/HeySym/user_notebooks/phucndm/test_ollama.ipynb`

Chạy từng cell và quan sát output:

#### Cell 1: Load extension
```python
%load_ext jupyter_ai_magics
```
**Kỳ vọng**: Không có output (silent success)

#### Cell 2: List providers
```python
%ai list
```
**Kỳ vọng**: Thấy `ollama` trong danh sách

#### Cell 3: Line magic test
```python
%ai ollama:deepseek-r1:8b -f code -- What is 2+2?
```
**Kỳ vọng**: Có output code với kết quả
**Lưu ý**: Đợi 10-20 giây, model có thể cần thời gian

#### Cell 4: Cell magic test (trước đây fail)
```python
%%ai ollama:deepseek-r1:8b
Giải thích định lý Pythagoras bằng tiếng Việt, ngắn gọn trong 2-3 câu.
```
**Kỳ vọng**: Output văn bản tiếng Việt
**Lưu ý**: Nếu không có output, đợi thêm 30 giây

#### Cell 5: Với base_url explicit
```python
%%ai ollama:deepseek-r1:8b --base-url http://localhost:11434
Tính 5 + 3
```
**Kỳ vọng**: Output "8" hoặc giải thích

#### Cell 6: Test trực tiếp với langchain-ollama
```python
from langchain_ollama import ChatOllama

ollama = ChatOllama(
    base_url="http://localhost:11434",
    model="deepseek-r1:8b"
)

response = ollama.invoke("Nói 'Xin chào' bằng tiếng Việt")
print(response.content)
```
**Kỳ vọng**: In ra "Xin chào" hoặc greeting
**Lưu ý**: Nếu cell này work nhưng magic không work → vấn đề ở magic command

#### Cell 7: Xem help
```python
%ai --help
```
**Kỳ vọng**: Hiển thị usage instructions

### Bước 3: Thử với model nhẹ hơn
```python
%%ai ollama:glm-4.7:cloud
Hello, how are you?
```
Hoặc thử với nomic-embed-text nếu có

## Solutions theo từng trường hợp

### Case 1: Cell đang chạy nhưng không có output
**Triệu chứng**: Cell có dấu `[*]` bên trái (đang chạy) nhưng lâu quá không ra output

**Giải pháp**:
- Đợi thêm 30-60 giây (model reasoning có thể lâu)
- Check Ollama logs: `tail -f ~/.ollama/logs/server.log`
- Monitor Ollama với: `watch -n 1 "curl -s http://localhost:11434/api/ps | jq"`

### Case 2: Cell chạy xong nhưng không có output gì
**Triệu chứng**: Cell có dấu `[1]` (đã chạy xong) nhưng không có output

**Giải pháp A - Thử format khác**:
```python
# Thử format markdown
%%ai ollama:deepseek-r1:8b -f markdown
Giải thích định lý Pythagoras

# Thử format code
%%ai ollama:deepseek-r1:8b -f code
Write a Python function to calculate area

# Thử format text (default)
%%ai ollama:deepseek-r1:8b -f text
Hello
```

**Giải pháp B - Check cell output settings**:
1. Right-click vào cell output area
2. Check "Enable Scrolling for Outputs"
3. Check nếu output bị collapsed

**Giải pháp C - Thử tạo biến**:
```python
%%ai ollama:deepseek-r1:8b
result = "Giải thích định lý Pythagoras"
```
Sau đó:
```python
print(result)
```

### Case 3: Error hiển thị
**Triệu chứng**: Có error message

**Debug steps**:
1. Copy full error message
2. Check nếu là timeout → tăng timeout setting
3. Check nếu là connection error → verify Ollama running
4. Check nếu là model not found → list models với `ollama list`

### Case 4: Magic command không work nhưng direct call work
**Triệu chứng**: Cell 6 (langchain-ollama direct) work, nhưng magic không work

**Giải pháp**:
Có thể jupyter-ai-magics version này có bug với Ollama provider. Thử:

1. **Update jupyter-ai**:
```bash
pip install --upgrade jupyter-ai jupyter-ai-magics
```

2. **Dùng langchain-ollama trực tiếp** thay vì magic:
```python
from langchain_ollama import ChatOllama

ollama = ChatOllama(
    base_url="http://localhost:11434",
    model="deepseek-r1:8b"
)

def ask_ollama(prompt):
    response = ollama.invoke(prompt)
    return response.content

# Sử dụng
result = ask_ollama("Giải thích định lý Pythagoras bằng tiếng Việt")
print(result)
```

## Monitoring và Debugging

### Check Ollama status real-time
```bash
# Terminal 1: Watch running models
watch -n 1 "curl -s http://localhost:11434/api/ps | python3 -m json.tool"

# Terminal 2: Monitor logs
tail -f ~/.ollama/logs/server.log
```

### Check notebook kernel logs
```bash
# Xem logs của notebook server
ps aux | grep jupyterhub-singleuser
# Note PID, then:
lsof -p <PID> | grep log
```

### Enable verbose logging
Thêm vào đầu notebook:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## Expected Behavior

Khi magic command work đúng:

```python
%%ai ollama:deepseek-r1:8b
Giải thích định lý Pythagoras
```

**Output mong đợi** (sau 10-30 giây):
```
Định lý Pythagoras phát biểu rằng trong tam giác vuông, bình phương cạnh 
huyền bằng tổng bình phương hai cạnh góc vuông. Công thức: a² + b² = c²
```

## Next Steps

Nếu sau khi thử tất cả các bước trên vẫn không work:

1. **Report issue**: Ghi lại chi tiết:
   - Jupyter AI version: `pip show jupyter-ai jupyter-ai-magics`
   - Python version: `python --version`
   - Error message (nếu có)
   - Which cells work vs fail

2. **Fallback solution**: Dùng langchain-ollama trực tiếp thay vì magic commands

3. **Alternative**: Sử dụng Jupyter AI Chat UI thay vì magic commands:
   - Click vào icon chat ở sidebar
   - Select Ollama provider
   - Chat trực tiếp

## Reference

- Jupyter AI docs: https://jupyter-ai.readthedocs.io/
- Ollama models: https://ollama.com/library
- langchain-ollama: https://python.langchain.com/docs/integrations/llms/ollama

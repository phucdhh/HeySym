"""
HeySym AI Startup Script
Chạy tự động khi kernel khởi động.
- Thay thế `%ai list` bằng output chỉ hiện Ollama models
- Thêm magic `%models` để xem nhanh danh sách model Ollama
"""
import urllib.request
import json
from IPython import get_ipython
from IPython.display import display, Markdown

OLLAMA_BASE_URL = "http://localhost:11434"
EMBED_ONLY = {"nomic-embed-text", "mxbai-embed-large", "all-minilm", "bge-m3", "bge-large"}


def _fetch_models():
    try:
        with urllib.request.urlopen(f"{OLLAMA_BASE_URL}/api/tags", timeout=3) as r:
            data = json.loads(r.read())
            return [m["name"] for m in data.get("models", [])
                    if not any(e in m["name"] for e in EMBED_ONLY)]
    except Exception:
        return []


def _show_ollama_models():
    """Hiển thị bảng Ollama models thay thế %ai list."""
    model_list = _fetch_models()
    if not model_list:
        display(Markdown("⚠️ Không lấy được danh sách model từ Ollama."))
        return
    rows = []
    for name in model_list:
        tag = "☁️ cloud" if "cloud" in name else "💻 local"
        rows.append(f"| `ollama:{name}` | `%%ai ollama:{name}` | {tag} |")
    display(Markdown("\n".join([
        "## 🦙 Ollama Models",
        "",
        "| Model | Cách dùng | Loại |",
        "|-------|-----------|------|",
        *rows,
        "",
        "> Gõ `%models` để xem lại danh sách này bất cứ lúc nào.",
    ])))


# ── Patch AiMagics.handle_list trước khi %load_ext được gọi ───────────────
try:
    from jupyter_ai_magics import AiMagics

    def _new_handle_list(self, args):
        _show_ollama_models()

    AiMagics.handle_list = _new_handle_list
except ImportError:
    pass


# ── Đăng ký các magic commands ────────────────────────────────────────────
ip = get_ipython()
if ip is not None:
    @ip.register_magic_function
    def models(line):
        """Xem danh sách Ollama models. Dùng với: %%ai ollama:<model>"""
        _show_ollama_models()

    @ip.register_magic_function
    def load_ai(line):
        """%load_ai — tải Jupyter AI magic (thay thế ngắn gọn cho %load_ext jupyter_ai_magics)"""
        ip.run_line_magic('load_ext', 'jupyter_ai_magics')
        # Patch lại handle_list sau khi extension vừa được load
        try:
            from jupyter_ai_magics import AiMagics
            def _new_handle_list(self, args):
                _show_ollama_models()
            AiMagics.handle_list = _new_handle_list
        except ImportError:
            pass
        _show_ollama_models()

    print("✅ HeySym AI ready. Gõ `%load_ai` để bắt đầu, `%models` để xem danh sách model.")

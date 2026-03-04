"""Cerebras Provider for Jupyter AI - HeySym
Cerebras có API tương thích OpenAI, dùng langchain-openai với base_url tùy chỉnh.
"""
import urllib.request
import json

from jupyter_ai_magics.providers import BaseProvider, TextField
from langchain_openai import ChatOpenAI

CEREBRAS_BASE_URL = "https://api.cerebras.ai/v1"
CEREBRAS_ENV_VAR = "CEREBRAS_API_KEY"


def _fetch_cerebras_models(api_key: str) -> list[str]:
    """Fetch model list từ Cerebras API."""
    try:
        req = urllib.request.Request(
            f"{CEREBRAS_BASE_URL}/models",
            headers={"Authorization": f"Bearer {api_key}"},
        )
        with urllib.request.urlopen(req, timeout=5) as r:
            data = json.loads(r.read())
            return [m["id"] for m in data.get("data", [])]
    except Exception:
        # Fallback list nếu không fetch được
        return ["llama3.1-8b", "qwen-3-235b-a22b-instruct-2507", "gpt-oss-120b", "zai-glm-4.7"]


class CerebrasProvider(BaseProvider, ChatOpenAI):
    """Cerebras provider cho %%ai magic — dùng Cerebras Cloud API."""

    id = "cerebras"
    name = "Cerebras"
    model_id_key = "model_name"
    models = ["llama3.1-8b", "qwen-3-235b-a22b-instruct-2507", "gpt-oss-120b", "zai-glm-4.7"]
    pypi_package_deps = ["langchain-openai"]
    auth_strategy = None  # API key được truyền qua env var CEREBRAS_API_KEY

    fields = [
        TextField(key="openai_api_key", label="Cerebras API Key", format="text"),
    ]

    def __init__(self, **kwargs):
        import os
        kwargs.setdefault("model_id", "llama3.1-8b")
        api_key = kwargs.pop("openai_api_key", None) or os.environ.get(CEREBRAS_ENV_VAR, "")
        kwargs["openai_api_key"] = api_key
        kwargs["openai_api_base"] = CEREBRAS_BASE_URL
        super().__init__(**kwargs)

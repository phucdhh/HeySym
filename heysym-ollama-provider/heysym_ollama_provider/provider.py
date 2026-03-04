"""Ollama Provider for Jupyter AI - HeySym"""
import urllib.request
import json

from jupyter_ai_magics.providers import BaseProvider, TextField
from langchain_ollama import ChatOllama


def _fetch_ollama_models(base_url: str = "http://localhost:11434") -> list[str]:
    """Fetch model list from Ollama API, excluding embedding-only models."""
    EMBED_ONLY = {"nomic-embed-text", "mxbai-embed-large", "all-minilm", "bge-m3", "bge-large"}
    try:
        with urllib.request.urlopen(f"{base_url}/api/tags", timeout=3) as resp:
            data = json.loads(resp.read())
            models = []
            for m in data.get("models", []):
                name = m["name"]
                # Skip embedding-only models
                if any(e in name for e in EMBED_ONLY):
                    continue
                models.append(name)
            return models if models else ["deepseek-r1:8b"]
    except Exception:
        return ["deepseek-r1:8b"]


# Fetch once at import time so %ai list shows actual models
_OLLAMA_MODELS = _fetch_ollama_models()


class OllamaProvider(BaseProvider, ChatOllama):
    """Ollama provider for %%ai magic and Jupyter AI chat"""

    id = "ollama"
    name = "Ollama"
    model_id_key = "model"
    # Dynamic model list fetched from local Ollama — visible in %ai list
    models = _OLLAMA_MODELS
    pypi_package_deps = ["langchain-ollama"]
    auth_strategy = None

    fields = [
        TextField(
            key="base_url",
            label="Ollama Base URL",
            format="text",
        ),
    ]

    def __init__(self, **kwargs):
        kwargs.setdefault("model_id", _OLLAMA_MODELS[0])
        kwargs.setdefault("base_url", "http://localhost:11434")
        # Disable streaming to prevent async hang with thinking models (deepseek-r1, etc.)
        kwargs.setdefault("disable_streaming", True)
        super().__init__(**kwargs)



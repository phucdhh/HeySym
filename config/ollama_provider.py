"""Custom Ollama Provider for Jupyter AI"""
from jupyter_ai_magics.providers import BaseProvider, TextField
from langchain_community.llms import Ollama
from langchain_community.chat_models import ChatOllama


class OllamaProvider(BaseProvider, Ollama):
    """Ollama provider for Jupyter AI magic commands"""
    
    id = "ollama"
    name = "Ollama"
    
    # Configuration fields
    model_id_key = "model"
    model_id_label = "Model ID"
    
    base_url = TextField(
        key="base_url",
        label="Base URL",
        default="http://localhost:11434",
        description="Ollama server URL"
    )
    
    def __init__(self, **kwargs):
        # Get model from kwargs, default to deepseek-r1:8b
        model = kwargs.pop('model_id', 'deepseek-r1:8b')
        base_url = kwargs.pop('base_url', 'http://localhost:11434')
        
        # Initialize parent classes
        BaseProvider.__init__(self, **kwargs)
        Ollama.__init__(self, model=model, base_url=base_url, **kwargs)
    
    @property
    def allows_concurrency(self):
        return True


class ChatOllamaProvider(BaseProvider, ChatOllama):
    """Chat Ollama provider for Jupyter AI chat interface"""
    
    id = "ollama-chat"
    name = "Ollama Chat"
    
    model_id_key = "model"
    model_id_label = "Model ID"
    
    base_url = TextField(
        key="base_url",
        label="Base URL",
        default="http://localhost:11434",
        description="Ollama server URL"
    )
    
    def __init__(self, **kwargs):
        model = kwargs.pop('model_id', 'deepseek-r1:8b')
        base_url = kwargs.pop('base_url', 'http://localhost:11434')
        
        BaseProvider.__init__(self, **kwargs)
        ChatOllama.__init__(self, model=model, base_url=base_url, **kwargs)
    
    @property
    def allows_concurrency(self):
        return True

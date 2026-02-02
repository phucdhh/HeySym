"""
HeySym Ollama Helper Functions

Các hàm tiện ích để sử dụng Ollama trong JupyterLab một cách dễ dàng
"""

from langchain_ollama import ChatOllama
from typing import Optional, Iterator
import time
import sys
from IPython.display import display, Markdown, Latex
import re
import requests
import json


class OllamaHelper:
    """Helper class để sử dụng Ollama trong HeySym"""
    
    def __init__(self, base_url: str = "http://localhost:11434", model: str = "deepseek-r1:8b", silent: bool = False):
        """
        Khởi tạo Ollama client
        
        Args:
            base_url: URL của Ollama server (default: http://localhost:11434)
            model: Tên model (default: deepseek-r1:8b)
            silent: Không hiển thị init message (default: False)
        """
        self.base_url = base_url
        self.model = model
        self.client = ChatOllama(base_url=base_url, model=model)
        if not silent:
            print(f"✓ Đã kết nối Ollama: {model} @ {base_url}")
    
    def ask(self, prompt: str, verbose: bool = True, stream: bool = True, display_format: bool = True, show_thinking: bool = True) -> str:
        """
        Hỏi Ollama một câu hỏi
        
        Args:
            prompt: Câu hỏi hoặc prompt
            verbose: Hiển thị thông tin thời gian xử lý
            stream: Hiển thị output theo kiểu streaming (default: True)
            display_format: Hiển thị đẹp với Markdown/LaTeX (default: True)
            show_thinking: Hiển thị chain-of-thought cho models hỗ trợ (default: True)
            
        Returns:
            Câu trả lời từ model
            
        Note:
            Với models như deepseek-r1, show_thinking=True sẽ hiển thị quá trình suy nghĩ
        """
        if stream:
            # Kiểm tra nếu model có chain-of-thought capability
            if show_thinking and any(keyword in self.model.lower() for keyword in ['deepseek-r1', 'qwen', 'r1']):
                return self._ask_stream_with_thinking(prompt, verbose, display_format)
            else:
                return self._ask_stream(prompt, verbose, display_format)
        
        if verbose:
            print(f"🤔 Đang suy nghĩ với {self.model}...", end=" ", flush=True)
        
        start_time = time.time()
        response = self.client.invoke(prompt)
        elapsed = time.time() - start_time
        
        if verbose:
            print(f"(mất {elapsed:.1f}s)")
        
        content = response.content
        
        if display_format:
            self._display_formatted(content)
            return content
        
        return content
    
    def _ask_stream_with_thinking(self, prompt: str, verbose: bool = True, display_format: bool = True) -> str:
        """
        Stream với hiển thị thinking tokens (chain-of-thought) cho models như deepseek-r1
        
        Args:
            prompt: Câu hỏi
            verbose: Hiển thị timing info
            display_format: Format output sau khi stream xong
            
        Returns:
            Full response text (không bao gồm thinking)
        """
        if verbose:
            print(f"🤔 {self.model} đang suy nghĩ:\n", flush=True)
        
        start_time = time.time()
        full_thinking = ""
        full_response = ""
        thinking_phase = True
        
        try:
            # Call Ollama API trực tiếp để lấy thinking tokens
            response = requests.post(
                f"{self.base_url}/api/chat",
                json={
                    "model": self.model,
                    "messages": [{"role": "user", "content": prompt}],
                    "stream": True
                },
                stream=True
            )
            
            for line in response.iter_lines():
                if line:
                    data = json.loads(line)
                    message = data.get("message", {})
                    
                    # Thinking tokens (chain-of-thought) - màu xám italic
                    if "thinking" in message:
                        thinking_text = message["thinking"]
                        if thinking_text and thinking_phase:
                            # ANSI escape code: gray (90) + italic (3)
                            print(f"\033[90;3m{thinking_text}\033[0m", end="", flush=True)
                            full_thinking += thinking_text
                    
                    # Actual content
                    if "content" in message:
                        content = message["content"]
                        if content:
                            if thinking_phase and content:
                                # Chuyển sang phase content
                                thinking_phase = False
                                print(f"\n\n💡 Kết luận:\n", flush=True)
                            print(content, end="", flush=True)
                            full_response += content
                    
                    if data.get("done"):
                        break
                        
        except KeyboardInterrupt:
            print("\n\n⚠️ Bị ngắt giữa chừng!")
            if display_format and full_response:
                self._display_formatted(full_response)
            return full_response
        except Exception as e:
            print(f"\n❌ Lỗi: {e}")
            print("Falling back to standard streaming...")
            return self._ask_stream(prompt, verbose, display_format)
        
        elapsed = time.time() - start_time
        
        if verbose:
            print(f"\n\n⏱️  Tổng thời gian: {elapsed:.1f}s")
            if full_thinking:
                thinking_words = len(full_thinking.split())
                response_words = len(full_response.split())
                print(f"   (Thinking: ~{thinking_words} words, Response: ~{response_words} words)")
        
        # Display formatted version
        if display_format and full_response:
            print("\n" + "="*60)
            print("📝 Phiên bản định dạng:")
            print("="*60)
            self._display_formatted(full_response)
        
        return full_response
    
    def _ask_stream(self, prompt: str, verbose: bool = True, display_format: bool = True) -> str:
        """
        Hỏi Ollama với streaming output
        
        Args:
            prompt: Câu hỏi
            verbose: Hiển thị timing info
            display_format: Format output sau khi stream xong
            
        Returns:
            Full response text
        """
        if verbose:
            print(f"🤔 {self.model} đang trả lời:\n", flush=True)
        
        start_time = time.time()
        full_response = ""
        
        try:
            for chunk in self.client.stream(prompt):
                content = chunk.content
                print(content, end="", flush=True)
                full_response += content
        except KeyboardInterrupt:
            print("\n\n⚠️ Bị ngắt giữa chừng!")
            if display_format:
                self._display_formatted(full_response)
            return full_response
        
        elapsed = time.time() - start_time
        
        if verbose:
            print(f"\n\n⏱️  Tổng thời gian: {elapsed:.1f}s")
        
        # Display formatted version sau khi stream xong
        if display_format:
            print("\n" + "="*60)
            print("📝 Phiên bản định dạng:")
            print("="*60)
            self._display_formatted(full_response)
        
        return full_response
    
    def solve_math(self, problem: str, stream: bool = True) -> str:
        """
        Giải bài toán học
        
        Args:
            problem: Đề bài toán
            stream: Streaming output (default: True)
            
        Returns:
            Lời giải chi tiết
        """
        prompt = f"""Hãy giải bài toán sau bằng tiếng Việt, giải thích từng bước rõ ràng:

{problem}

Lời giải:"""
        return self.ask(prompt, stream=stream)
    
    def explain_concept(self, concept: str, level: str = "trung học", stream: bool = True) -> str:
        """
        Giải thích một khái niệm toán học
        
        Args:
            concept: Khái niệm cần giải thích (VD: "định lý Pythagoras")
            level: Mức độ (tiểu học, trung học, đại học)
            stream: Streaming output (default: True)
            
        Returns:
            Giải thích chi tiết
        """
        prompt = f"""Hãy giải thích khái niệm "{concept}" cho học sinh {level}, 
sử dụng tiếng Việt đơn giản, dễ hiểu, có ví dụ cụ thể."""
        return self.ask(prompt, stream=stream)
    
    def _display_formatted(self, content: str):
        """
        Hiển thị content với formatting đẹp (Markdown + LaTeX)
        
        Args:
            content: Text cần format
        """
        try:
            # Try to use IPython display (best for notebooks)
            from IPython import get_ipython
            if get_ipython() is not None:
                display(Markdown(content))
            else:
                # Fallback to plain print if not in IPython
                print(content)
        except Exception as e:
            # If display fails, just print
            print(content)
    
    def generate_code(self, description: str, language: str = "python", stream: bool = True) -> str:
        """
        Tạo code từ mô tả
        
        Args:
            description: Mô tả chức năng cần code
            language: Ngôn ngữ lập trình
            stream: Streaming output (default: True)
            
        Returns:
            Code được sinh ra
        """
        prompt = f"""Generate {language} code for: {description}

Only return the code, no explanation."""
        return self.ask(prompt, verbose=True, stream=stream, display_format=False)
    
    def check_answer(self, question: str, student_answer: str, stream: bool = True) -> str:
        """
        Kiểm tra đáp án của học sinh
        
        Args:
            question: Câu hỏi/bài toán
            student_answer: Đáp án của học sinh
            stream: Streaming output (default: True)
            
        Returns:
            Nhận xét và đánh giá
        """
        prompt = f"""Câu hỏi: {question}

Đáp án của học sinh: {student_answer}

Hãy đánh giá đáp án của học sinh bằng tiếng Việt:
- Đúng hay sai?
- Nếu sai, sai ở đâu?
- Gợi ý cách làm đúng (nếu cần)"""
        return self.ask(prompt, stream=stream)
    
    def change_model(self, model: str):
        """
        Đổi sang model khác
        
        Args:
            model: Tên model mới
        """
        self.model = model
        self.client = ChatOllama(base_url=self.base_url, model=model)
        print(f"✓ Đã chuyển sang model: {model}")


# Convenience functions
def quick_ask(prompt: str, model: str = "deepseek-r1:8b", stream: bool = True) -> str:
    """Hỏi nhanh một câu"""
    helper = OllamaHelper(model=model, silent=True)
    return helper.ask(prompt, verbose=True, stream=stream)


def solve(problem: str, model: str = "deepseek-r1:8b", stream: bool = True) -> str:
    """Giải toán nhanh"""
    helper = OllamaHelper(model=model, silent=True)
    return helper.solve_math(problem, stream=stream)


def explain(concept: str, level: str = "trung học", model: str = "deepseek-r1:8b", stream: bool = True) -> str:
    """Giải thích khái niệm nhanh"""
    helper = OllamaHelper(model=model, silent=True)
    return helper.explain_concept(concept, level, stream=stream)


# Demo usage
if __name__ == "__main__":
    # Example 1: Basic usage
    print("=" * 60)
    print("Example 1: Sử dụng cơ bản")
    print("=" * 60)
    
    ai = OllamaHelper(model="deepseek-r1:8b")
    answer = ai.ask("Định lý Pythagoras là gì?")
    print(answer)
    
    # Example 2: Solve math
    print("\n" + "=" * 60)
    print("Example 2: Giải toán")
    print("=" * 60)
    
    solution = ai.solve_math("Tính đạo hàm của hàm số y = x² + 3x - 5")
    print(solution)
    
    # Example 3: Quick functions
    print("\n" + "=" * 60)
    print("Example 3: Functions nhanh")
    print("=" * 60)
    
    result = quick_ask("What is 2+2?", model="glm-4.7:cloud")
    print(result)

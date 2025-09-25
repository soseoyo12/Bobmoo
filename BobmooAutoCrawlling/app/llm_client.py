# -*- coding: utf-8 -*-
from __future__ import annotations

import os
from typing import Any, Dict
import json
import google.generativeai as genai
import re

PROMPT_CONTRACT_PATH = (
    os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            "..",
            "specs",
            "001-specify-json-html",
            "contracts",
            "gemini-prompt.md",
        )
    )
)


def _load_contract_text() -> str:
    if os.path.exists(PROMPT_CONTRACT_PATH):
        with open(PROMPT_CONTRACT_PATH, "r", encoding="utf-8") as f:
            return f.read()
    return ""


def setup_genai() -> None:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY not set")
    genai.configure(api_key=api_key)


def _extract_json(text: str) -> Dict[str, Any]:
    # Remove code fences and surrounding noise
    s = (text or "").strip()
    s = s.strip("` ")
    # Fast path
    try:
        return json.loads(s)
    except Exception:
        pass
    # Try to find the first top-level JSON object via bracket matching
    start_idx = s.find("{")
    if start_idx == -1:
        raise ValueError("No JSON object start found in response")
    depth = 0
    for i in range(start_idx, len(s)):
        ch = s[i]
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                candidate = s[start_idx:i+1]
                return json.loads(candidate)
    raise ValueError("Unbalanced JSON braces in response")


def call_gemini_25_flash(system_prompt: str, input_payload: Dict[str, Any], *, max_retries: int = 2) -> Dict[str, Any]:
    setup_genai()
    model = genai.GenerativeModel(
        "gemini-2.5-flash",
        generation_config={
            # 강제로 JSON으로 응답을 유도 (모델이 지원하는 경우)
            "response_mime_type": "application/json",
            "temperature": 0.2,
        },
    )

    contract = _load_contract_text()
    user_prompt = (
        f"{system_prompt}\n\n"
        f"CONTRACT:\n{contract}\n\n"
        f"INPUT(JSON):\n{json.dumps(input_payload, ensure_ascii=False)}\n\n"
        "Output strictly as JSON only, no code fences."
    )

    last_error = None
    for _ in range(max_retries + 1):
        try:
            resp = model.generate_content(user_prompt)
            # Prefer structured parts if available
            text = None
            try:
                if getattr(resp, "candidates", None):
                    parts = resp.candidates[0].content.parts
                    if parts:
                        text = getattr(parts[0], "text", None)
            except Exception:
                text = None
            if not text:
                text = getattr(resp, "text", None) or ""
            return _extract_json(text)
        except Exception as e:
            last_error = e
            continue
    raise RuntimeError(f"Gemini call failed: {last_error}")


from __future__ import annotations

import json
import random
import time
from typing import Any

from google import genai
from google.genai import errors as genai_errors
from google.genai import types

from config import ApiProvider, getAPIkey
from schemas import Meals

from ai_providers.base import AIProvider


class GeminiProvider(AIProvider):
    """
    Google Gemini API를 사용하는 AI Provider 구현.
    
    이미지 분석 및 재시도 로직을 포함합니다.
    """
    
    def __init__(self, api_key: str | None = None, model: str = "gemini-2.5-flash"):
        """
        GeminiProvider 초기화.
        
        Args:
            api_key: Gemini API 키. None이면 config에서 가져옵니다.
            model: 사용할 Gemini 모델명 (기본값: "gemini-2.5-flash")
        """
        self.api_key = api_key or getAPIkey(ApiProvider.GEMINI)
        self.model = model
        self.client = genai.Client(api_key=self.api_key)
        
        # 재시도 설정
        self.max_attempts = 5
        self.base_delay_sec = 1.0
    
    def analyze(self, image_path: str) -> str:
        """
        이미지를 분석하여 Gemini API를 호출하고 원시 응답(JSON 문자열)을 반환합니다.
        
        503/429 등 일시적 오류 시 지수 백오프 + 지터로 재시도합니다.
        
        Args:
            image_path: 분석할 이미지 파일 경로
            
        Returns:
            JSON 문자열 형태의 원시 응답
            
        Raises:
            RuntimeError: 모든 재시도 실패 시
        """
        # 이미지 파일 읽기
        with open(image_path, 'rb') as f:
            image_bytes = f.read()
        
        last_err = None
        for attempt in range(1, self.max_attempts + 1):
            try:
                # Gemini API 호출
                response = self.client.models.generate_content(
                    model=self.model,
                    contents=[
                        types.Part.from_bytes(
                            data=image_bytes,
                            mime_type='image/png'
                        ),
                        """다음은 하루치 식단이 포함된 이미지입니다. 이미지를 분석하여 하루치 식단을 추출하세요.
                        course 가격은 5600원으로 고정합니다.
                        """,
                    ],
                    config={
                        "response_mime_type": "application/json",
                        "response_schema": list[Meals],
                    },
                )
                return response.text
                
            except genai_errors.ServerError as e:
                # 503/UNAVAILABLE, 429/TOO_MANY_REQUESTS 등에서 재시도
                print(f"Gemini API 호출 오류 발생... 재시도중... ({attempt}/{self.max_attempts}): {e}")
                message = getattr(e, "message", str(e))
                should_retry = any(code in message for code in ["503", "UNAVAILABLE", "429", "TOO_MANY_REQUESTS"]) or True
                last_err = e
                if attempt >= self.max_attempts or not should_retry:
                    break
                # 지수 백오프 + 지터
                sleep_sec = (self.base_delay_sec * (2 ** (attempt - 1))) + random.uniform(0, 0.5)
                time.sleep(sleep_sec)
                
            except Exception as e:
                # 기타 예외는 한 번 더 시도 후 중단
                print(f"Gemini API 호출 오류 발생... 재시도중... ({attempt}/{self.max_attempts}): {e}")
                last_err = e
                if attempt >= self.max_attempts:
                    break
                sleep_sec = (self.base_delay_sec * (2 ** (attempt - 1))) + random.uniform(0, 0.5)
                time.sleep(sleep_sec)
        
        # 모든 시도 실패 시 마지막 에러 재발생
        raise last_err if last_err else RuntimeError("Gemini 호출 실패: 원인 불명")
    
    def normalize_response(self, raw_response: Any) -> Meals:
        """
        Gemini API의 원시 응답을 Meals 스키마로 정규화합니다.
        
        Gemini는 list[Meals] 형태로 반환할 수 있으므로, 이를 병합하여 단일 Meals로 변환합니다.
        
        Args:
            raw_response: analyze()에서 반환된 원시 응답 (JSON 문자열 또는 파싱된 객체)
            
        Returns:
            정규화된 Meals 인스턴스
            
        Raises:
            ValueError: 응답 형식이 예상과 다를 때
        """
        try:
            # 문자열이면 JSON 파싱
            raw = raw_response
            if isinstance(raw, str):
                raw = json.loads(raw)
            
            # 리스트인 경우 병합 (여러 Meals가 배열로 올 경우)
            if isinstance(raw, list):
                merged = {"breakfast": [], "lunch": [], "dinner": []}
                for el in raw:
                    # 문자열인 경우 다시 파싱 시도
                    if isinstance(el, str):
                        try:
                            el = json.loads(el)
                        except Exception:
                            continue
                    # Meals 인스턴스면 dict로 변환
                    if isinstance(el, Meals):
                        el = el.model_dump()
                    # dict면 병합
                    if isinstance(el, dict):
                        for key in ("breakfast", "lunch", "dinner"):
                            if isinstance(el.get(key), list):
                                merged[key].extend(el[key])
                raw = merged
            
            # dict면 Meals로 변환
            if isinstance(raw, dict):
                return Meals(**raw)
            elif isinstance(raw, Meals):
                return raw
            else:
                raise ValueError(f"Unexpected response type: {type(raw)}")
                
        except Exception as e:
            raise ValueError(f"Failed to normalize Gemini response: {e}")
    
    def get_provider_name(self) -> str:
        """Provider 이름 반환."""
        return "Gemini"


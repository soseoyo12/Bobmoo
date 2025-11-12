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
    
    def analyze(self, image_path: str, fixed_price: int) -> str:
        """
        이미지를 분석하여 Gemini API를 호출하고 원시 응답(JSON 문자열)을 반환합니다.
        
        503/429 등 일시적 오류 시 지수 백오프 + 지터로 재시도합니다.
        
        Args:
            image_path: 분석할 이미지 파일 경로
            fixed_price: 고정 가격(원)
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
                        f"""다음은 하루치 식단이 포함된 이미지입니다. 이미지를 분석하여 하루치 식단을 추출하세요.
                        course 가격은 {fixed_price}원으로 고정합니다.
                        course 종류는 A/B 중 하나입니다.
                        
                        메뉴가 *로 묶여있는 경우 *를 &로 대체합니다.
                        예시)
                        모닝브레드2종*잼 -> 모닝브레드2종&잼
                        그린샐러드*드레싱 -> 그린샐러드&드레싱
                        시리얼*우유 -> 시리얼&우유
                        
                        간편식, 플러스바, 후식은 따로 추가하지 않습니다.
                        특히 '식간 라면'도 따로 추가하지 않습니다.
                        
                        American style, 직화, 뚝), 일품, 누들 과 같은 메뉴가 아닌 불필요한 텍스트는 메뉴에 포함하지 않습니다.
                        만일 메뉴와 상관없는 불필요한 텍스트가 있다면 메뉴에 포함하지 않습니다.
                        ex)
                        메뉴: 직화 뚝)나주곰탕 OR 뚝)참치김치찌개, 쌀밥, 두부구이&양념장, 멸치청양볶음, 도시락김, 깍두기, 비빔코너"
                        불필요한 텍스트: 직화, 뚝)
                        원하는 결과물: 나주곰탕 or 참치김치찌개, 쌀밥, 두부구이&양념장, 멸치청양볶음, 도시락김, 깍두기, 비빔코너
                        
                        토, 일 주말같은 경우에는 아침은 없고 점심, 저녁만 있습니다.
                        각각 모두 코스는 하나만 있습니다.
                        주말 점심에는 '주말 점심 간편식'이 표 구조에 맞지 않게 B 코스에 존재하고 있습니다.
                        이를 무시해주시고 오직 한 코스(A)만 나오도록 해주세요.
                        
                        대신 course 메뉴뒤에 후식 또는 플러스바의 메뉴 이름을 이어 붙입니다.
                        단, 간편식은 메뉴뒤에 이어 붙이지 않습니다.
                        
                        ex1)
                        A: 부대덮밥, 바지락살미역국, 생크림초코와플, 궁채절임
                        후식: 요구르트
                        
                        원하는 결과물: 부대덮밥, 바지락살미역국, 생크림초코와플, 궁채절임, 요구르트
                        
                        ex2)
                        A: 마제소바, 추가밥, 가쓰오우동국, 야채튀김, 단무지
                        플러스바: 오이소바
                        
                        원하는 결과물: 마제소바, 추가밥, 가쓰오우동국, 야채튀김, 단무지, 오이소바
                        
                        
                        점심에 코스가 2개 있을때 플러스바가 하나만 있다면,
                        플러스바는 두 메뉴 모두에 추가되어야 합니다.
                        
                        ex3)
                        A: 찜닭, 쌀밥, 얼갈이된장국, 미역줄기볶음, 무말랭이무침, 파김치
                        B: 누들떡볶이, 김가루볶음밥, 핫도그&케찹, 순대찜&소금, 단무지
                        플러스바: 비빔코너
                        
                        원하는 결과물 -> 두 코스 모두 플러스바를 추가합니다.
                        A: 찜닭, 쌀밥, 얼갈이된장국, 미역줄기볶음, 무말랭이무침, 파김치, 비빔코너
                        B: 누들떡볶이, 김가루볶음밥, 핫도그&케찹, 순대찜&소금, 단무지, 비빔코너
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
                if e.code == 503:
                    print(f"Gemini API 호출 모델 과부화 발생... 재시도중... ({attempt}/{self.max_attempts}): {e}")
                else:
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
    
    def analyze_and_normalize(self, image_path: str, fixed_price: int) -> Meals:
        """
        이미지를 분석하고 정규화된 Meals를 반환하는 편의 메서드.
        
        Args:
            image_path: 분석할 이미지 파일 경로
            fixed_price: 고정 가격(원)
        Returns:
            정규화된 Meals 인스턴스
        """
        raw_response = self.analyze(image_path, fixed_price)
        return self.normalize_response(raw_response)


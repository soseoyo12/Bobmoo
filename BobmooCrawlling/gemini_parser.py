import google.generativeai as genai
import json
import logging
from typing import Dict, Any
from config import GEMINI_API_KEY

class GeminiParser:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        genai.configure(api_key=GEMINI_API_KEY)
        self.model = genai.GenerativeModel('gemini-2.0-flash')
        self.pro_model = genai.GenerativeModel('gemini-2.5-pro')
        
    def parse_html_to_json(self, content_text: str, school_name: str = "인하대학교", is_pdf: bool = False) -> list:
        """
        HTML 또는 PDF 텍스트를 분석하여 JSON 형태로 변환합니다.
        
        Args:
            content_text (str): 분석할 텍스트 (HTML 또는 PDF)
            school_name (str): 학교 이름
            is_pdf (bool): PDF 텍스트 여부 (True면 2.5 Pro 모델 사용)
            
        Returns:
            list: 변환된 JSON 데이터 리스트 (각 날짜별로 하나의 딕셔너리)
        """
        try:
            prompt = f"""
다음 텍스트(HTML 또는 PDF)를 분석하여 식당 메뉴 정보를 추출해주세요. 
웹사이트에 여러 날짜의 식단이 있다면 각 날짜별로 JSON 배열을 반환해주세요.

정확한 JSON 형태 (jsonExample.json 형식 준수):
{{
    "date": "YYYY-MM-DD",
    "school": "{school_name}",
    "cafeterias": [
        {{
            "name": "식당명",
            "hours": {{
                "breakfast": "07:30-09:00",
                "lunch": "11:30-13:30", 
                "dinner": "17:30-19:00"
            }},
            "meals": {{
                "lunch": [
                    {{
                        "course": "A",
                        "mainMenu": "돼지국밥, 동그랑땡조림, 청양감자채전",
                        "price": 5300
                    }},
                    {{
                        "course": "B",
                        "mainMenu": "휴게소꼬치어묵우동, 후리가케밥, 꼬마물만두찜",
                        "price": 5300
                    }}
                ],
                "breakfast": [
                    {{
                        "course": "A",
                        "mainMenu": "모닝브래드, 스크램블에그, 계절과일",
                        "price": 5300
                    }}
                ],
                "dinner": [
                    {{
                        "course": "A",
                        "mainMenu": "참치마요덮밥, 오징어링, 팽이장국",
                        "price": 5300
                    }}
                ]
            }}
        }}
    ]
}}

여러 날짜가 있다면 다음과 같이 배열로 반환:
[
    {{"date": "2024-09-29", "school": "{school_name}", "cafeterias": [...]}},
    {{"date": "2024-09-30", "school": "{school_name}", "cafeterias": [...]}},
    {{"date": "2024-10-01", "school": "{school_name}", "cafeterias": [...]}}
]

텍스트 내용:
{content_text[:12000]}

중요한 형식 규칙 (jsonExample.json과 정확히 동일하게):
1. 시간은 반드시 "07:30-09:00" 형식으로 표기 (하이픈 사용, ~ 사용 금지)
2. 메뉴는 반드시 "메뉴1, 메뉴2, 메뉴3" 형식으로 표기 (쉼표와 띄어쓰기로 구분)
3. course는 반드시 "A", "B", "C" 등 단순한 알파벳으로만 표기 (한글 코스명 사용 금지)
4. 가격은 숫자만 표기 (문자 없이)
5. 웹사이트의 실제 날짜 사용 (2024-09-29 ~ 2024-10-03)
6. 각 날짜별로 별도의 JSON 객체 생성
7. JSON 배열 형태로 반환하고 다른 설명 포함 금지
8. 한국어 메뉴명 그대로 유지
9. 메뉴명은 쉼표와 띄어쓰기로 구분: "돼지국밥, 동그랑땡조림, 청양감자채전"
"""

            # PDF인 경우 2.5 Pro 모델 사용, HTML인 경우 2.0 Flash 모델 사용
            selected_model = self.pro_model if is_pdf else self.model
            model_name = "Gemini 2.5 Pro" if is_pdf else "Gemini 2.0 Flash"
            
            self.logger.info(f"Gemini API로 텍스트 분석 시작 ({model_name})")
            response = selected_model.generate_content(prompt)
            
            # 응답에서 JSON 추출
            json_text = self._extract_json_from_response(response.text)
            
            # JSON 파싱
            json_data = json.loads(json_text)
            
            # 배열이 아닌 경우 배열로 변환
            if isinstance(json_data, dict):
                json_data = [json_data]
            
            self.logger.info(f"Gemini API 분석 완료 - {len(json_data)}개 날짜의 데이터 추출")
            return json_data
            
        except Exception as e:
            self.logger.error(f"Gemini API 분석 중 오류 발생: {str(e)}")
            # 오류 발생 시 기본 구조 반환
            return [self._get_default_json_structure(school_name)]
    
    def _extract_json_from_response(self, response_text: str) -> str:
        """
        Gemini 응답에서 JSON 부분만 추출합니다.
        
        Args:
            response_text (str): Gemini 응답 텍스트
            
        Returns:
            str: 추출된 JSON 문자열
        """
        try:
            # JSON 배열 시작과 끝 찾기
            start_idx = response_text.find('[')
            if start_idx == -1:
                # 배열이 없으면 객체 시작 찾기
                start_idx = response_text.find('{')
            
            if start_idx == -1:
                raise ValueError("JSON을 찾을 수 없습니다.")
            
            # 중괄호나 대괄호의 균형을 맞춰서 끝 찾기
            bracket_count = 0
            end_idx = start_idx
            
            for i, char in enumerate(response_text[start_idx:], start_idx):
                if char in '[{':
                    bracket_count += 1
                elif char in ']}':
                    bracket_count -= 1
                    if bracket_count == 0:
                        end_idx = i + 1
                        break
            
            if bracket_count != 0:
                raise ValueError("JSON 구조가 완전하지 않습니다.")
            
            return response_text[start_idx:end_idx]
                
        except Exception as e:
            self.logger.error(f"JSON 추출 중 오류: {str(e)}")
            raise
    
    def _get_default_json_structure(self, school_name: str) -> Dict[str, Any]:
        """
        오류 발생 시 기본 JSON 구조를 반환합니다.
        
        Args:
            school_name (str): 학교 이름
            
        Returns:
            Dict[str, Any]: 기본 JSON 구조
        """
        from datetime import datetime
        
        return {
            "date": datetime.now().strftime("%Y-%m-%d"),
            "school": school_name,
            "cafeterias": []
        }

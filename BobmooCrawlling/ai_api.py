import json
import time
import random
import requests
from config import ApiProvider, getAPIkey
from openai import OpenAI
from google import genai
from google.genai import types
from google.genai import errors as genai_errors

from schemas import Meals

def call_document_parse(input_file) -> dict:
    API_KEY = getAPIkey()
    
    # Send request
    response = requests.post(
        "https://api.upstage.ai/v1/document-digitization",
        headers={"Authorization": f"Bearer {API_KEY}"},
        data={"base64_encoding": "", "model": "document-parse", "ocr":"force"},
        files={"document": open(input_file, "rb")})
    
    # Save response
    if response.status_code == 200:
        return response.json()
    else:
        try:
            detail = response.json()
        except Exception:
            detail = response.text

        raise ValueError(f"Unexpected status code {response.status_code}: {detail}")

def ocr_image_text(input_file: str) -> str:
    """Upstage document-parse를 호출해 원문 텍스트 또는 HTML을 평문화하여 반환한다."""
    result = call_document_parse(input_file)
    content = result.get("content", {}) if isinstance(result, dict) else {}
    text = content.get("text") or ""
    # text가 없으면 html을 평문화하여 반환
    if not text:
        html = content.get("html") or ""
        # HTML에서 태그 제거 없이도 모델이 처리 가능하므로 그대로 반환
        # 후단 파서에서 라인 단위 전처리 수행
        text = html

    return text or ""

def analyze_text_with_upstage_ai(text: str):
    """하루치 텍스트를 분석하여 Upstage AI를 호출하여 결과를 반환"""
    API_KEY = getAPIkey(ApiProvider.UPSTAGE)
    
    client = OpenAI(
        api_key=API_KEY,
        base_url="https://api.upstage.ai/v1"
    )

    response = client.chat.completions.create(
        model="solar-pro2",
        messages=[
            {
                "role": "system",
                "content": (
                    "You extract cafeteria menus from HTML. "
                    "입력 HTML에서 하루치 식단을 분석하여 아침/점심/저녁을 정확히 구분하고, "
                    "반드시 response_format(MealsOnly) 스키마에 맞춘 JSON만 출력하세요. "
                    "각 끼니는 코스 배열이며, 각 코스는 {course, mainMenu, price}로 구성됩니다. "
                    "course는 반드시 'A'/'B' 중 하나로 표기하고, mainMenu는 한글 문자열로 결합하되 각 음식 이름을 ','로 구분하세요."
                    "단 간편식은 '간편식'으로 표기하세요. 예시) 마제소바, 추가밥, 가쓰오우동국, 야채튀김, 단무지"
                    #"또한 후식은 메인코스 뒤에 이어 붙여주세요! 코스를 하나 더 만들지 마세요!"
                    "메인 코스(A, B)에만 집중해주세요! 간편식, 후식, 플러스바는 응답에 넣지마세요!"
                    "price는 5600원으로 고정합니다. 반드시 지켜주세요!"
                    "음식 이름이 모닝브래드2종*잼 이런식으로 되어있다면, '*'를 '&'로 변경하세요!"
                    "다음 키워드들은 메뉴 이름에서 발견시 제거해주세요! 불필요한 단어입니다."
                    "제거해야 할 단어: American style, 직화, 뚝), 일품, 누들"
                )
            },
            {
                "role": "user",
                "content": (
                    "다음은 하루치 식단이 포함된 HTML입니다. 태그/표 구조를 해석하여, "
                    "meals.breakfast/lunch/dinner 각각에 해당하는 코스들을 추출하세요. "
                    "출력은 오직 response_format(MealsOnly) 스키마에 맞춘 JSON 한 덩어리만 제공합니다."
                    "### 식단이 포함된 HTML 코드 ###\n\n" + text
                )
            },
        ],
        stream=False,
        response_format=response_format
    )
    
    # 모델 응답이 문자열(JSON)일 수도 있고, 이미 dict/list일 수도 있음에 대비
    content = response.choices[0].message.content
    try:
        data = json.loads(content) if isinstance(content, str) else content
    except Exception:
        data = content
    
    return data
    
def analyze_image_with_gemini(image_path: str):
    """
    하루치 이미지를 분석하여 Gemini API를 호출하여 결과를 반환합니다.
    
    503/429 등 일시적 오류 시 지수 백오프 + 지터로 재시도한다.
    
    Args:
        image_path: 하루치 이미지 경로
    Returns:
        dict: 하루치 식단 결과
    """
    
    # API Key 가져오기
    API_KEY = getAPIkey(ApiProvider.GEMINI)

    # Gemini Client 생성
    client = genai.Client(api_key=API_KEY)
    
    # 이미지 파일 읽기
    with open(image_path, 'rb') as f:
        image_bytes = f.read()

    # 최대 시도 횟수와 지연 시간 설정
    max_attempts = 5
    base_delay_sec = 1.0

    # 오류 저장
    last_err = None
    for attempt in range(1, max_attempts + 1):
        try:
            # Gemini API 호출
            response = client.models.generate_content(
                model="gemini-2.5-flash",
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
            print(f"Gemini API 호출 오류 발생... 재시도중...: {e}")
            message = getattr(e, "message", str(e))
            should_retry = any(code in message for code in ["503", "UNAVAILABLE", "429", "TOO_MANY_REQUESTS"]) or True
            last_err = e
            if attempt >= max_attempts or not should_retry:
                break
            # 지수 백오프 + 지터
            sleep_sec = (base_delay_sec * (2 ** (attempt - 1))) + random.uniform(0, 0.5)
            time.sleep(sleep_sec)
        except Exception as e:
            # 기타 예외는 한 번 더 시도 후 중단
            print(f"Gemini API 호출 오류 발생... 재시도중...: {e}")
            last_err = e    
            if attempt >= max_attempts:
                break
            sleep_sec = (base_delay_sec * (2 ** (attempt - 1))) + random.uniform(0, 0.5)
            time.sleep(sleep_sec)

    # 모든 시도 실패 시 마지막 에러 재발생
    raise last_err if last_err else RuntimeError("Gemini 호출 실패: 원인 불명")
import json
import requests
from config import getAPIkey
from openai import OpenAI
from constants import response_format

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
    API_KEY = getAPIkey()
    
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
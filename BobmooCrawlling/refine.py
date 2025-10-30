import os
import json
from openai import OpenAI
from ai_api import call_document_parse

response_format = {
    "type": "json_schema",
    "json_schema": {
        "name": "CafeteriaMenuWeekly",
        "strict": True,
        "schema": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "school": {"type": "string"},
                "dates": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "additionalProperties": False,
                        "properties": {
                            "date": {"type": "string"},
                            "cafeterias": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "additionalProperties": False,
                                    "properties": {
                                        "name": {"type": "string"},
                                        "hours": {"type": "string"},
                                        "meals": {
                                            "type": "object",
                                            "additionalProperties": False,
                                            "properties": {
                                                "breakfast": {"type": "object"},
                                                "lunch": {"type": "object"},
                                                "dinner": {"type": "object"}
                                            },
                                            "required": ["breakfast", "lunch", "dinner"]
                                        }
                                    },
                                    "required": ["name", "hours", "meals"]
                                }
                            }
                        },
                        "required": ["date", "cafeterias"]
                    }
                }
            },
            "required": ["school", "dates"]
        }
    }
}

def AnalyzeAndRefine(input_file):
    """
    문서 분석 결과를 받아 식단 정보를 주간 JSON 형태로 변환하고 파일로 저장
    Args:
        input_file (str): 분석할 원본 파일 경로
    """
    from config import getAPIkey
    API_KEY = getAPIkey()

    parsed_result = call_document_parse(input_file)

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
                    "You are a helpful assistant that analyzes and refines the input file. "
                    "입력으로 주어지는 HTML에는 7일치(일주일)의 식단이 포함되어 있습니다. 날짜별로 정확히 분리/매칭하여 분석하고, "
                    "반드시 제공된 response_format의 주간 스키마(CafeteriaMenuWeekly: school + dates[])에 맞춰 JSON만 출력하세요. "
                    "코스 이름은 'A', 'B' 등 대문자 영단어 한 글자로 표시하고, 메뉴 이름은 한글로 표시하세요."
                )
            },
            {
                "role": "user",
                "content": (
                    "다음 HTML에는 7일치 식단이 날짜별 구간으로 포함되어 있습니다. 날짜(YYYY-MM-DD) 단위로 정확히 식단을 분리하고, "
                    "각 날짜별로 식당별 운영시간(hours)과 끼니별(meals.breakfast/lunch/dinner) 코스/메뉴/가격을 추출하세요. "
                    "출력은 오직 response_format 스키마(CafeteriaMenuWeekly)에 맞춘 JSON 한 덩어리만 제공합니다."
                )
            },
            {
                "role": "user",
                "content": "### 식단 분석 HTML 코드 ###\n\n" + parsed_result["content"]["html"]
            }
        ],
        stream=False,
        response_format=response_format
    )

    # 입력 파일명에서 확장자를 json으로 변경하여 저장 경로 생성
    output_file = os.path.splitext(input_file)[0] + ".json"

    # 모델 응답이 문자열(JSON)일 수도 있고, 이미 dict/list일 수도 있음에 대비
    content = response.choices[0].message.content
    try:
        data = json.loads(content) if isinstance(content, str) else content
    except Exception:
        data = content

    with open(output_file, "w", encoding="utf-8") as f:
        if isinstance(data, (dict, list)):
            json.dump(data, f, ensure_ascii=False, indent=4)
        else:
            f.write(str(data))

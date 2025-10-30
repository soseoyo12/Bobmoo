import requests
from config import getAPIkey

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
    if not text:
        html = content.get("html") or ""
        # HTML에서 태그 제거 없이도 모델이 처리 가능하므로 그대로 반환
        # 후단 파서에서 라인 단위 전처리 수행
        text = html
    return text or ""
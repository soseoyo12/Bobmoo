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

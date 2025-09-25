## Quickstart

### Requirements
- Python 3.11+
- pip packages: requests, beautifulsoup4, lxml, charset-normalizer, google-generativeai, jsonschema, selenium, webdriver-manager
- Env: `GEMINI_API_KEY`

### Install
```bash
pip install -r requirements.txt
```

### Usage (Library)
```python
from app.pipeline import transform_from_url
result = transform_from_url("<menu_url>")
```

### Usage (CLI)
```bash
python -m app.cli "<menu_url>" --out out/
```

### Selenium Fallback
- 트리거: (1) 추출 결과 비어있음, (2) 스키마 검증 실패/비정상 데이터
- Headless Chrome 사용, 명시적 대기 후 재파싱
